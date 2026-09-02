module Website.Pages.Listing
  ( buildListingPages
  ) where

import Data.List (nub, sort, sortOn)
import Data.Ord (Down (..))
import Data.Text (Text)
import Data.Text qualified as T
import Lucid
import System.FilePath ((</>))
import Website.Component (render)
import Website.Components.Card (ProjectCard (..))
import Website.Components.NoteList (NoteItem (..))
import Website.Context (Ctx, SiteCtx (..))
import Website.Layout (page, writePage)
import Website.Post (Frontmatter (..), Post (..), PostKind (..))

buildListingPages :: (Ctx) => FilePath -> [Post] -> IO ()
buildListingPages outDir posts = do
  let sorted = sortOn (Down . fmDate . postFrontmatter) posts
      langs = sort $ nub $ map (fmLang . postFrontmatter) sorted
  mapM_ (buildForLang sorted) langs
  putStrLn $ "Listings: wrote pages for " <> show langs
 where
  buildForLang sorted lang = do
    let langPosts = filter ((== lang) . fmLang . postFrontmatter) sorted
        articles = filter ((== Article) . postKind) langPosts
        notes = filter ((== Note) . postKind) langPosts
        projects = filter ((== Project) . postKind) langPosts
        _research = filter (("research" `elem`) . fmTags . postFrontmatter) articles
        prefix = if lang == ?ctx.ctxDefaultLang then outDir else outDir </> T.unpack lang
    buildCardList prefix lang "articles" "Posts" articles
    buildNoteList prefix lang "notes" "Notes" notes
    -- buildNoteList prefix lang "research" "Research" research
    buildCardList prefix lang "projects" "Projects" projects

buildNoteList :: (Ctx) => FilePath -> Text -> FilePath -> Text -> [Post] -> IO ()
buildNoteList base lang slug heading posts =
  writePage (base </> slug)
    $ page heading lang (noteListBody heading posts)

buildCardList :: (Ctx) => FilePath -> Text -> FilePath -> Text -> [Post] -> IO ()
buildCardList base lang slug heading posts =
  writePage (base </> slug)
    $ page heading lang (cardListBody heading posts)

noteListBody :: (Ctx) => Text -> [Post] -> Html ()
noteListBody heading posts = do
  header_ [class_ "page-header"] $ do
    h1_ [class_ "page-header__title"] (toHtml (T.toLower heading))
    p_ [class_ "page-header__subtitle"]
      $ toHtml (T.pack (show (length posts)) <> " articles")
  section_ [class_ "section"]
    $ div_ [class_ "note-list"]
    $ mapM_ (render . NoteItem) posts

cardListBody :: (Ctx) => Text -> [Post] -> Html ()
cardListBody heading posts = do
  header_ [class_ "page-header"] $ do
    h1_ [class_ "page-header__title"] (toHtml (T.toLower heading))
    p_ [class_ "page-header__subtitle"]
      $ toHtml (T.pack (show (length posts)) <> " items")
  section_ [class_ "section"]
    $ div_ [class_ "card-list"]
    $ mapM_ (render . ProjectCard) posts
