{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Website.Config (SiteConfig (..), loadConfig) where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Yaml qualified as Y
import GHC.Generics (Generic)

data SiteConfig = SiteConfig
  { cfgSiteTitle :: !Text
  , cfgSiteUrl :: !Text
  , cfgDefaultLang :: !Text
  , cfgPostsDir :: !FilePath
  , cfgNotesDir :: !FilePath
  , cfgProjectsDir :: !FilePath
  , cfgOutputDir :: !FilePath
  , cfgAssetsDir :: !FilePath
  }
  deriving (Eq, Generic, Show)

deriving instance FromJSON SiteConfig

loadConfig :: FilePath -> IO SiteConfig
loadConfig path = Y.decodeFileThrow path
