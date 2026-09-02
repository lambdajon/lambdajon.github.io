module Website.Components.PageHeader (PageHeader (..)) where

import Clay hiding (filter, (?))
import Data.Text (Text)
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cBorder
  , cFgBright
  , cFgMuted
  , cFontMono
  , cFontSerif
  , cLg
  , cMaxW
  , cMd
  , cSm
  , cXxl
  , ref
  )
import Prelude hiding (rem)

data PageHeader = PageHeader
  { phTitle :: Text
  , phSubtitle :: Text
  }

instance Render PageHeader where
  render ph =
    header_ [class_ "page-header"] $ do
      h1_ [class_ "page-header__title"] (toHtml ph.phTitle)
      p_ [class_ "page-header__subtitle"] (toHtml ph.phSubtitle)

instance Styled PageHeader where
  style_ = do
    ".page-header" %?% do
      "max-width" -: ref cMaxW
      margin (px 0) auto (px 0) auto
      "padding" -: ref cXxl <> " clamp(1.5rem, 5vw, 3rem) " <> ref cLg

    ".page-header__title" %?% do
      "font-family" -: ref cFontSerif
      "font-size" -: "clamp(1.6rem, 4vw, 2.2rem)"
      fontWeight bold
      "letter-spacing" -: "-0.02em"
      "color" -: ref cFgBright

    ".page-header__subtitle" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.78)
      "color" -: ref cFgMuted
      "margin-top" -: ref cSm

    ".error-code" %?% do
      "font-family" -: ref cFontMono
      "font-size" -: "clamp(5rem, 20vw, 10rem)"
      fontWeight bold
      "color" -: ref cBorder
      lineHeight (unitless 1)
      "margin-bottom" -: ref cMd
      "letter-spacing" -: "-0.05em"
