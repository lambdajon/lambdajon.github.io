module Website.Components.Hero (Hero (..)) where

import Clay hiding (filter, span_, (?))
import Data.Text qualified as T
import Lucid
import Lucid.Base (makeAttribute)
import Website.Component (Render (..), Styled (..))
import Website.Context (SiteCtx (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBorder
  , cFgBright
  , cFgDim
  , cFgMuted
  , cFontMono
  , cFontSerif
  , cGbYellow
  , cLg
  , cMaxW
  , cMd
  , cXl
  , cXs
  , cXxl
  , ref
  )
import Prelude hiding (rem)

data Hero = Hero

instance Render Hero where
  render Hero =
    header_ [class_ "hero"] $ do
      h1_ [class_ "hero__title"] $ do
        toHtml (T.toLower ?ctx.ctxSiteTitle)
        br_ []
        span_ [class_ "hero__title-accent"] "research & work"
      p_
        [class_ "hero__tagline", makeAttribute "data-i18n" "hero.tagline"]
        "// type theory \xb7 compilers \xb7 systems \xb7 functional programming"

instance Styled Hero where
  style_ = do
    ".hero" %?% do
      "max-width" -: ref cMaxW
      margin (px 0) auto (px 0) auto
      "padding" -: ref cXxl <> " clamp(1.5rem, 5vw, 3rem)"
      "border-bottom" -: "1px solid " <> ref cBorder

    ".hero__title" %?% do
      "font-family" -: ref cFontSerif
      "font-size" -: "clamp(2rem, 5vw, 3rem)"
      fontWeight bold
      lineHeight (unitless 1.2)
      "letter-spacing" -: "-0.02em"
      "color" -: ref cFgBright

    ".hero__title-accent" %?% do "color" -: ref cAccent

    ".hero__tagline" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.8)
      "color" -: ref cFgMuted
      "margin-top" -: ref cMd
      "letter-spacing" -: "0.02em"

    ".hero__links" %?% do
      display flex
      "gap" -: ref cMd
      "flex-wrap" -: "wrap"
      "margin-top" -: ref cLg

    ".hero__link" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.8)
      "color" -: ref cFgDim
      "padding-bottom" -: "2px"
      "border-bottom" -: "1px solid " <> ref cBorder

    ".hero__link:hover" %?% do
      "color" -: ref cAccent
      "border-color" -: ref cAccent
      textDecoration none

    ".hero__meta" %?% do
      display flex
      "gap" -: ref cXl
      "flex-wrap" -: "wrap"
      "margin-top" -: ref cXl
      "padding-top" -: ref cLg
      "border-top" -: "1px dashed " <> ref cBorder
      "font-family" -: ref cFontMono
      fontSize (rem 0.75)
      "color" -: ref cFgMuted

    ".hero__meta-label" %?% do
      display block
      "color" -: ref cGbYellow
      fontWeight (weight 500)
      "margin-bottom" -: ref cXs
