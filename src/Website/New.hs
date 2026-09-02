module Website.New (NewOpts (..), runNew) where

import Data.Char (isAlphaNum, toLower)
import Data.List (intercalate)
import Data.Time (getCurrentTime, utctDay)
import System.Directory (createDirectoryIfMissing, doesFileExist)
import System.Exit (exitFailure)
import System.FilePath ((</>))
import Website.Config (SiteConfig (..), loadConfig)
import Website.Post (PostKind (..))

data NewOpts = NewOpts
  { newKind :: !PostKind
  , newTitle :: !String
  , newLang :: !String
  , newTags :: ![String]
  , newSummary :: Maybe String
  , newDraft :: !Bool
  , newToc :: !Bool
  }

runNew :: NewOpts -> IO ()
runNew opts = do
  cfg <- loadConfig "config.yaml"
  today <- utctDay <$> getCurrentTime
  let slug = slugify opts.newTitle
      dir = kindDir cfg opts.newKind </> opts.newLang
      path = dir </> slug <> ".md"
  exists <- doesFileExist path
  if exists
    then putStrLn ("Error: " <> path <> " already exists") >> exitFailure
    else do
      createDirectoryIfMissing True dir
      writeFile path (buildFrontmatter today opts slug)
      putStrLn $ "Created: " <> path

-- Helpers

slugify :: String -> String
slugify = intercalate "-" . words . map (\c -> if isAlphaNum c || c == ' ' then toLower c else ' ')

kindDir :: SiteConfig -> PostKind -> FilePath
kindDir cfg Article = cfg.cfgPostsDir
kindDir cfg Note = cfg.cfgNotesDir
kindDir cfg Project = cfg.cfgProjectsDir

buildFrontmatter :: (Show d) => d -> NewOpts -> String -> String
buildFrontmatter date opts _slug =
  unlines
    $ ["---", "title: " <> opts.newTitle, "date: " <> show date]
      <> tagLines
      <> summaryLines
      <> draftLine
      <> tocLine
      <> ["---", ""]
 where
  tagLines
    | null opts.newTags = []
    | otherwise = "tags:" : map ("  - " <>) opts.newTags
  summaryLines = maybe [] (\s -> ["summary: " <> s]) opts.newSummary
  draftLine = ["draft: true" | opts.newDraft]
  tocLine = ["toc: true" | opts.newToc]
