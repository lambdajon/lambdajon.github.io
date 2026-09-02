module Website.Context
  ( SiteCtx (..)
  , Ctx
  , mkCtx
  ) where

import Data.Kind (Constraint)
import Data.Map.Strict (Map)
import Data.Text (Text)
import Website.Config (SiteConfig (..))

data SiteCtx = SiteCtx
  { ctxSiteTitle :: !Text
  , ctxDefaultLang :: !Text
  , ctxSiteUrl :: !Text
  , ctxTranslations :: Map Text (Map Text Text)
  , ctxI18n :: Map Text (Map Text Text)
  }

type Ctx :: Constraint
type Ctx = (?ctx :: SiteCtx)

mkCtx :: SiteConfig -> Map Text (Map Text Text) -> Map Text (Map Text Text) -> SiteCtx
mkCtx cfg translations i18n =
  SiteCtx
    { ctxSiteTitle = cfgSiteTitle cfg
    , ctxDefaultLang = cfgDefaultLang cfg
    , ctxSiteUrl = cfgSiteUrl cfg
    , ctxTranslations = translations
    , ctxI18n = i18n
    }
