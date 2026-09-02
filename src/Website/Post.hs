{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Website.Post
  ( Post (..)
  , PostKind (..)
  , Frontmatter (..)
  , parsePost
  , kindUrlPrefix
  , postUrl
  ) where

import Control.Exception (throwIO)
import Data.Map.Strict qualified as Map
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Data.Time (Day)
import GHC.Generics (Generic)
import System.FilePath (takeBaseName, takeDirectory, takeFileName)
import Text.Pandoc hiding (Note)

data PostKind = Article | Note | Project deriving (Eq, Show)

data Frontmatter = Frontmatter
  { fmTitle :: !Text
  , fmDate :: !(Maybe Day)
  , fmTags :: [Text]
  , fmSummary :: !(Maybe Text)
  , fmDraft :: Bool
  , fmToc :: Bool
  , fmLang :: Text
  }
  deriving (Eq, Generic, Show)

data Post = Post
  { postSlug :: !Text
  , postKind :: !PostKind
  , postFrontmatter :: !Frontmatter
  , postBody :: !Pandoc
  , postSourcePath :: !FilePath
  }
  deriving (Show)

-- Pandoc exposes metadata via the Meta type
-- Extract it manually from the parsed Pandoc document.
extractFrontmatter :: FilePath -> Meta -> Either String Frontmatter
extractFrontmatter path meta = do
  title <-
    maybe
      (Left $ path <> ": missing 'title' field")
      Right
      (lookupMetaText "title" meta)
  let date = lookupMetaDay "date" meta
      tags = lookupMetaList "tags" meta
      summary = lookupMetaText "summary" meta
      draft = fromMaybe False (lookupMetaBool "draft" meta)
      toc = fromMaybe False (lookupMetaBool "toc" meta)
      lang = fromMaybe "en" (lookupMetaText "lang" meta)
  Right
    Frontmatter
      { fmTitle = title
      , fmDate = date
      , fmTags = tags
      , fmSummary = summary
      , fmDraft = draft
      , fmToc = toc
      , fmLang = lang
      }

-- Helper: extract a Text value from Pandoc Meta
lookupMetaText :: Text -> Meta -> Maybe Text
lookupMetaText key (Meta m) = case Map.lookup key m of
  Just (MetaInlines inlines) -> Just (inlinesToText inlines)
  Just (MetaString s) -> Just s
  _ -> Nothing

lookupMetaBool :: Text -> Meta -> Maybe Bool
lookupMetaBool key (Meta m) = case Map.lookup key m of
  Just (MetaBool b) -> Just b
  _ -> Nothing

lookupMetaList :: Text -> Meta -> [Text]
lookupMetaList key (Meta m) = case Map.lookup key m of
  Just (MetaList xs) -> [t | MetaInlines is <- xs, let t = inlinesToText is]
  Just (MetaInlines is) -> map T.strip $ T.splitOn "," (inlinesToText is)
  Just (MetaString s) -> map T.strip $ T.splitOn "," s
  _ -> []

lookupMetaDay :: Text -> Meta -> Maybe Day
lookupMetaDay key meta = do
  txt <- lookupMetaText key meta
  case reads (T.unpack txt) of
    [(d, "")] -> Just d
    _ -> Nothing

inlinesToText :: [Inline] -> Text
inlinesToText = T.concat . map inlineToText

inlineToText :: Inline -> Text
inlineToText (Str t) = t
inlineToText Space = " "
inlineToText SoftBreak = " "
inlineToText (Code _ t) = t
inlineToText _ = ""

-- Reader options 
readerOpts :: ReaderOptions
readerOpts =
  def
    { readerExtensions =
        pandocExtensions
          <> extensionsFromList
            [ Ext_yaml_metadata_block
            , Ext_fenced_code_attributes
            , Ext_tex_math_dollars
            , Ext_implicit_figures
            , Ext_footnotes
            ]
    }

kindUrlPrefix :: PostKind -> Text
kindUrlPrefix Article = "posts"
kindUrlPrefix Note = "notes"
kindUrlPrefix Project = "projects"

-- | URL format: /{lang}/{kind}/{slug}/
postUrl :: Post -> Text
postUrl p = "/" <> lang <> "/" <> kindUrlPrefix (postKind p) <> "/" <> postSlug p <> "/"
 where
  lang = fmLang (postFrontmatter p)


{- | Read and fully parse a post from disk.
Lang is taken from the immediate parent directory name (e.g. data/posts/en/post.md → "en").
-}
parsePost :: PostKind -> FilePath -> IO Post
parsePost kind path = do
  src <- TIO.readFile path
  Pandoc meta blocks <- runIOorExplode $ do
    setVerbosity ERROR
    readMarkdown readerOpts src
  fm0 <- either (throwIO . userError) pure (extractFrontmatter path meta)
  let slug = T.pack (takeBaseName path)
      lang = T.pack (takeFileName (takeDirectory path))
      fm = fm0{fmLang = lang}
  pure
    Post
      { postSlug = slug
      , postKind = kind
      , postFrontmatter = fm
      , postBody = Pandoc meta blocks
      , postSourcePath = path
      }
