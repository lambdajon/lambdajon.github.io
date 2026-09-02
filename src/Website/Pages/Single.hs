{-# OPTIONS_GHC -Wno-type-defaults #-}

module Website.Pages.Single
  ( buildSingle
  ) where

import Control.Monad (unless)
import Data.Aeson (encode)
import Data.ByteString.Lazy qualified as BL
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.Encoding qualified as TE
import Data.Text.IO qualified as TIO
import Lucid
import Lucid.Base (makeAttribute)
import Skylighting.Format.HTML (styleToCss)
import Skylighting.Types (Style)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Text.Pandoc
import Website.Component (render)
import Website.Components.Tag (TagBadge (..))
import Website.Context (Ctx, SiteCtx (..))
import Website.Layout (Page (..), defPage, fullPage, renderPageText)
import Website.Post (Frontmatter (..), Post (..), kindUrlPrefix)
import Website.Theme (gruvboxDark, paletteStyle)

-- Writer options

gruvboxStyle :: Style
gruvboxStyle = paletteStyle gruvboxDark

writerOpts :: Bool -> Maybe (Template Text) -> WriterOptions
writerOpts toc tmpl =
  def
    { writerHighlightStyle = Just gruvboxStyle
    , writerHtmlQTags = True
    , writerSectionDivs = True
    , writerTableOfContents = toc
    , writerTOCDepth = 3
    , writerTemplate = tmpl
    , writerEmailObfuscation = ReferenceObfuscation
    }

tocTemplate :: IO (Template Text)
tocTemplate = do
  result <- compileTemplate "" "<nav role=\"doc-toc\">$table-of-contents$</nav>\n$body$"
  case result of
    Left err -> fail $ "TOC template compile error: " <> err
    Right t -> pure t

-- Helpers

langUrlsJson :: Map.Map Text Text -> Text
langUrlsJson = TE.decodeUtf8 . BL.toStrict . encode

-- Page 

singlePage :: (Ctx) => Post -> Text -> Html ()
singlePage post bodyHtml =
  let fm = post.postFrontmatter
      lang = fm.fmLang
      title = fm.fmTitle
      dateStr = maybe "" (T.pack . show) fm.fmDate
      tags = fm.fmTags
      allTrans = Map.findWithDefault Map.empty post.postSlug ?ctx.ctxTranslations
      hlCss = T.pack (styleToCss gruvboxStyle)

      extraHead = do
        meta_ [name_ "description", content_ title]
        unless (T.null dateStr)
          $ meta_ [name_ "date", content_ dateStr]
        mapM_ hreflang (Map.toList allTrans)
        style_ hlCss

      postBody = do
        header_ [class_ "page-header"] $ do
          h1_ [class_ "page-header__title"] $ toHtml title
          div_ [class_ "page-header__subtitle"] $ do
            unless (T.null dateStr)
              $ span_ (toHtml dateStr)
            unless (null tags)
              $ div_ [class_ "card__tags"]
              $ mapM_ (render . TagBadge) tags
        article_ [class_ "content"] (toHtmlRaw bodyHtml)

      extraScripts =
        unless (Map.null allTrans)
          $ script_ [id_ "lang-urls", type_ "application/json"] (langUrlsJson allTrans)
   in fullPage
        defPage
          { pageTitle = title
          , pageLang = lang
          , pageHead = extraHead
          , pageBody = postBody
          , pageScripts = extraScripts
          }
 where
  hreflang (l, u) =
    link_ [rel_ "alternate", makeAttribute "hreflang" l, href_ u]

-- Build 

buildSingle :: (Ctx) => FilePath -> Post -> IO ()
buildSingle outDir post = do
  let toc = post.postFrontmatter.fmToc
  tmpl <- if toc then Just <$> tocTemplate else pure Nothing
  bodyHtml <- runIOorExplode $ writeHtml5String (writerOpts toc tmpl) post.postBody
  let html = renderPageText (singlePage post bodyHtml)
      lang = T.unpack post.postFrontmatter.fmLang
      kindDir = T.unpack (kindUrlPrefix post.postKind)
      slug = T.unpack post.postSlug
      dir = outDir </> lang </> kindDir </> slug
  createDirectoryIfMissing True dir
  TIO.writeFile (dir </> "index.html") html
