module Website.Pages.About
  ( buildAboutPages
  ) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Data.Yaml qualified as Y
import Lucid
import Text.Pandoc
import Website.Context (Ctx, SiteCtx (..))
import Website.Layout (page, writePage)

buildAboutPages :: (Ctx) => FilePath -> IO ()
buildAboutPages outDir = do
  dict <- Y.decodeFileThrow "i18n.yaml" :: IO (Map Text (Map Text Text))
  mapM_ (buildOne dict) (Map.keys dict)
  putStrLn "Pages: wrote /about/"
 where
  buildOne dict lang = do
    let content =
          Map.findWithDefault "" "about.content"
            $ Map.findWithDefault Map.empty lang dict
        dir =
          if lang == ?ctx.ctxDefaultLang
            then outDir <> "/about"
            else outDir <> "/" <> T.unpack lang <> "/about"
    bodyHtml <- runIOorExplode $ readMarkdown def content >>= writeHtml5String def
    writePage dir $ page "About" lang (aboutPage bodyHtml)

aboutPage :: Text -> Html ()
aboutPage bodyHtml = do
  header_ [class_ "page-header"]
    $ h1_ [class_ "page-header__title"] "about"
  article_ [class_ "content"] (toHtmlRaw bodyHtml)
