module Website.Pages.Tag
  ( tagPage
  , buildTagPages
  , buildTagIndex
  ) where

import Data.List (nub, sort, sortOn)
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Ord (Down (..))
import Data.Text (Text)
import Data.Text qualified as T
import Lucid
import System.FilePath ((</>))
import Website.Component (render)
import Website.Components.Card (ProjectCard (..))
import Website.Components.Tag (tagSlug)
import Website.Context (Ctx)
import Website.Layout (page, writePage)
import Website.Post (Frontmatter (..), Post (..))

tagPage :: (Ctx) => Text -> [Post] -> Html ()
tagPage tag posts = do
  header_ [class_ "page-header"] $ do
    h1_ [class_ "page-header__title"] $ do
      "Posts tagged: "
      span_ [class_ "text-accent"] (toHtml tag)
    p_ [class_ "page-header__subtitle"]
      $ toHtml (T.pack (show (length posts)) <> " posts")
  section_ [class_ "section"]
    $ div_ [class_ "card-list"]
    $ mapM_ (render . ProjectCard) posts

buildTagPages :: (Ctx) => FilePath -> [Post] -> IO ()
buildTagPages outDir posts = do
  let allTags = nub $ concatMap (fmTags . postFrontmatter) posts
      tagMap = Map.fromListWith (<>) [(t, [p]) | p <- posts, t <- fmTags (postFrontmatter p)]
  mapM_ (buildTagPage outDir tagMap) allTags
  buildTagIndex outDir tagMap
  putStrLn $ "Tags: wrote " <> show (length allTags) <> " tag pages."

buildTagIndex :: (Ctx) => FilePath -> Map Text [Post] -> IO ()
buildTagIndex outDir tagMap =
  writePage (outDir </> "tags")
    $ page "Tags" "en" body
 where
  tags = sort $ Map.keys tagMap
  body = do
    header_ [class_ "page-header"] $ do
      h1_ [class_ "page-header__title"] "tags"
      p_ [class_ "page-header__subtitle"]
        $ toHtml (T.pack (show (length tags)) <> " tags")
    section_ [class_ "section"]
      $ div_ [class_ "tag-index"]
      $ mapM_ tagRow tags
  tagRow tag =
    a_ [href_ ("/tags/" <> tagSlug tag <> "/"), class_ "tag-index__item"] $ do
      span_ [class_ "tag-index__name"] (toHtml tag)
      span_ [class_ "tag-index__count"]
        $ toHtml (T.pack (show (length (Map.findWithDefault [] tag tagMap))))

buildTagPage :: (Ctx) => FilePath -> Map Text [Post] -> Text -> IO ()
buildTagPage outDir tagMap tag =
  writePage (outDir </> "tags" </> T.unpack slug)
    $ page pageTitle "en" body
 where
  tagPosts = sortOn (Down . fmDate . postFrontmatter) $ Map.findWithDefault [] tag tagMap
  slug = tagSlug tag
  pageTitle = "Posts tagged: " <> tag
  body = tagPage tag tagPosts
