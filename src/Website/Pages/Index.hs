module Website.Pages.Index
  ( indexPage
  , buildIndexHtml
  ) where

import Data.List (nub, sort, sortOn)
import Data.Ord (Down (..))
import Data.Text qualified as T
import Lucid
import Lucid.Base (makeAttribute)
import System.FilePath ((</>))
import Website.Component (render)
import Website.Components.Card (ProjectCard (..))
import Website.Components.NoteList (NoteItem (..))
import Website.Context (Ctx, SiteCtx (..))
import Website.Layout (Page (..), defPage, fullPage, writePage)
import Website.Post (Frontmatter (..), Post (..), PostKind (..))

-- index.html

indexPage :: (Ctx) => [Post] -> [Post] -> Html ()
indexPage research notes = do
  header_ [class_ "hero"] $ do
    h1_ [class_ "hero__title"] $ do
      toHtml (T.toLower ?ctx.ctxSiteTitle)
      br_ []
      span_ [class_ "hero__title-accent"] "articles & work"
    p_
      [class_ "hero__tagline", makeAttribute "data-i18n" "hero.tagline"]
      "// type theory \xb7 compilers \xb7 systems porogramming \xb7 functional programming"
  section_ [class_ "section", id_ "research"] $ do
    div_ [class_ "section__label"] "articles"
    div_ [class_ "card-list"] $ mapM_ (render . ProjectCard) research
  section_ [class_ "section", id_ "notes"] $ do
    div_ [class_ "section__label"] "notes"
    div_ [class_ "note-list"] $ mapM_ (render . NoteItem) notes

buildIndexHtml :: (Ctx) => FilePath -> [Post] -> IO ()
buildIndexHtml outDir posts = do
  let sorted = sortOn (Down . fmDate . postFrontmatter) posts
      langs = sort $ nub $ map (fmLang . postFrontmatter) sorted
  mapM_ (buildForLang sorted) langs
  putStrLn $ "Index: wrote index pages for " <> show langs
 where
  buildForLang sorted lang = do
    let langPosts = filter ((== lang) . fmLang . postFrontmatter) sorted
        article = take 4 $ filter ((== Article) . postKind) langPosts
        notes = take 4 $ filter ((== Note) . postKind) langPosts
        dir = if lang == ?ctx.ctxDefaultLang then outDir else outDir </> T.unpack lang
    writePage dir
      $ fullPage defPage{pageTitle = ?ctx.ctxSiteTitle, pageLang = lang, pageBody = indexPage article notes}
