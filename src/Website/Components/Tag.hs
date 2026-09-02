module Website.Components.Tag
  ( TagBadge (..)
  , TagIndex
  , tagSlug
  ) where

import Clay hiding (filter, (?))
import Data.Char (isAlphaNum)
import Data.Text (Text)
import Data.Text qualified as T
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBgHighlight
  , cBgPanel
  , cBorder
  , cFgBright
  , cFgDim
  , cFgMuted
  , cFontMono
  , cGbAqua
  , cMd
  , cRadius
  , cSm
  , ref
  )
import Prelude hiding (rem)

newtype TagBadge = TagBadge Text

tagSlug :: Text -> Text
tagSlug = T.intercalate "-" . T.words . T.toLower . T.filter (\c -> isAlphaNum c || c == ' ')

instance Render TagBadge where
  render (TagBadge tag) =
    a_ [href_ ("/tags/" <> tagSlug tag <> "/"), class_ "tag"] (toHtml tag)

instance Styled TagBadge where
  style_ =
    ".tag" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.68)
      "padding" -: "2px 8px"
      "background" -: ref cBgHighlight
      "color" -: ref cFgDim
      "border-radius" -: ref cRadius
      "letter-spacing" -: "0.02em"

data TagIndex

instance Styled TagIndex where
  style_ = do
    ".tag-index" %?% do
      display flex
      flexDirection column
      "gap" -: ref cSm

    ".tag-index__item" %?% do
      display flex
      alignItems center
      justifyContent spaceBetween
      "padding" -: ref cMd
      "background" -: ref cBgPanel
      "border" -: "1px solid " <> ref cBorder
      "border-left" -: "3px solid " <> ref cAccent
      "border-radius" -: "0 " <> ref cRadius <> " " <> ref cRadius <> " 0"
      "transition" -: "transform 0.15s ease, border-color 0.15s ease"
      textDecoration none

    ".tag-index__item:hover" %?% do
      "transform" -: "translateX(4px)"
      "border-left-color" -: ref cGbAqua

    ".tag-index__name" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.9)
      "color" -: ref cFgBright

    ".tag-index__count" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.75)
      "color" -: ref cFgMuted
