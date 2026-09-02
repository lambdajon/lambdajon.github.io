module Website.Pages.Feed (buildFeed) where

import Data.List (nub, sortOn)
import Data.Ord (Down (..))
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Data.Time (Day, defaultTimeLocale, formatTime)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Website.Context (Ctx, SiteCtx (..))
import Website.Post (Frontmatter (..), Post (..), PostKind (..), postUrl)

buildFeed :: (Ctx) => FilePath -> [Post] -> IO ()
buildFeed outDir posts = do
  let articles = sortOn (Down . fmDate . postFrontmatter) $ filter ((== Article) . postKind) posts
      langs = nub $ map (fmLang . postFrontmatter) articles
  mapM_ (buildForLang articles) langs
  putStrLn $ "Feed: wrote feed.xml for " <> show langs
 where
  buildForLang articles lang = do
    let langArticles = filter ((== lang) . fmLang . postFrontmatter) articles
        dir = if lang == ?ctx.ctxDefaultLang then outDir else outDir </> T.unpack lang
    createDirectoryIfMissing True dir
    TIO.writeFile (dir </> "feed.xml") (renderFeed lang langArticles)

renderFeed :: (Ctx) => Text -> [Post] -> Text
renderFeed lang posts =
  T.intercalate "\n"
    [ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    , "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">"
    , "  <channel>"
    , "    <title>" <> escXml ?ctx.ctxSiteTitle <> "</title>"
    , "    <link>" <> ?ctx.ctxSiteUrl <> "</link>"
    , "    <atom:link href=\"" <> selfUrl <> "\" rel=\"self\" type=\"application/rss+xml\"/>"
    , "    <description>" <> escXml ?ctx.ctxSiteTitle <> "</description>"
    , "    <language>" <> lang <> "</language>"
    , T.concat (map renderItem posts)
    , "  </channel>"
    , "</rss>"
    ]
 where
  selfUrl =
    ?ctx.ctxSiteUrl
      <> (if lang == ?ctx.ctxDefaultLang then "" else "/" <> lang)
      <> "/feed.xml"

renderItem :: (Ctx) => Post -> Text
renderItem p =
  T.intercalate "\n"
    [ "    <item>"
    , "      <title>" <> escXml (fmTitle fm) <> "</title>"
    , "      <link>" <> url <> "</link>"
    , "      <guid>" <> url <> "</guid>"
    , maybe "" (\d -> " <pubDate>" <> rfc822 d <> "</pubDate>\n") (fmDate fm)
    , maybe "" (\s -> " <description>" <> escXml s <> "</description>\n") (fmSummary fm)
    , "    </item>"
    ]
 where
  fm = postFrontmatter p
  url = ?ctx.ctxSiteUrl <> postUrl p

rfc822 :: Day -> Text
rfc822 = T.pack . formatTime defaultTimeLocale "%a, %d %b %Y 00:00:00 GMT"

escXml :: Text -> Text
escXml =
  T.replace "&" "&amp;"
    . T.replace "<" "&lt;"
    . T.replace ">" "&gt;"
    . T.replace "\"" "&quot;"
