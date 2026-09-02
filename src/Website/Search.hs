{-# LANGUAGE OverloadedStrings #-}

module Website.Search (buildIndex) where

import Data.Aeson (Options (..), ToJSON (..), defaultOptions, encode, genericToJSON)
import Data.ByteString.Lazy qualified as BL
import Data.Char
import Data.Text (Text)
import Data.Time (Day)
import GHC.Generics (Generic)
import System.FilePath ((</>))
import Website.Post (Frontmatter (..), Post (..), postUrl)

data PostMeta = PostMeta
  { pmSlug :: !Text
  , pmTitle :: !Text
  , pmDate :: Maybe Day
  , pmTags :: ![Text]
  , pmLang :: !Text
  , pmUrl :: !Text
  }
  deriving (Generic, Show)

pmOptions :: Options
pmOptions = defaultOptions{fieldLabelModifier = map toLower . drop 2}

instance ToJSON PostMeta where
  toJSON = genericToJSON pmOptions

buildIndex :: FilePath -> [Post] -> IO ()
buildIndex outDir posts = do
  BL.writeFile (outDir </> "index.json") $ encode (map toMeta posts)
  putStrLn $ "Search: wrote index.json with " <> show (length posts) <> " entries."
 where
  toMeta p =
    let fm = p.postFrontmatter
     in PostMeta
          { pmSlug = p.postSlug
          , pmTitle = fm.fmTitle
          , pmDate = fm.fmDate
          , pmTags = fm.fmTags
          , pmLang = fm.fmLang
          , pmUrl = postUrl p
          }
