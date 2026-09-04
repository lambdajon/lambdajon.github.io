module Website.Components.Base (Base) where

import Clay hiding (filter, (?))
import Clay.Media qualified as Media
import Website.Component (Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBg
  , cFg
  , cFgBright
  , cFontMono
  , cGbBg0
  , cGbYellow
  , cLg
  , cLink
  , cLinkHover
  , cMd
  , cSm
  , cXl
  , cXs
  , ref
  )
import Prelude hiding (rem)

data Base

instance Styled Base where
  style_ = do
    "*, *::before, *::after" %?% do
      boxSizing borderBox
      margin (px 0) (px 0) (px 0) (px 0)
      padding (px 0) (px 0) (px 0) (px 0)

    html %?% do
      fontSize (px 17)
      "scroll-behavior" -: "smooth"

    ":root" %?% do
      "transition" -: "background 0.2s ease, color 0.2s ease"

    body %?% do
      "background" -: ref cBg
      "color" -: ref cFg
      "font-family" -: ref cFontMono
      fontWeight (weight 400)
      lineHeight (unitless 1.75)
      minHeight (vh 100)

    "::selection" %?% do
      "background" -: ref cGbYellow
      "color" -: ref cGbBg0

    a %?% do
      "color" -: ref cLink
      textDecoration none
      "transition" -: "color 0.15s ease"

    (a # hover) %?% do
      "color" -: ref cLinkHover
      textDecoration underline
      "text-underline-offset" -: "3px"

    img %?% do
      maxWidth (pct 100)
      height auto

    ".hidden" %?% do "display" -: "none !important"
    ".text-center" %?% textAlign center
    ".text-muted" %?% do "color" -: ref cFgBright
    ".text-accent" %?% do "color" -: ref cAccent
    ".mt-sm" %?% do "margin-top" -: ref cSm
    ".mt-md" %?% do "margin-top" -: ref cMd
    ".mt-lg" %?% do "margin-top" -: ref cLg
    ".mt-xl" %?% do "margin-top" -: ref cXl

    query Media.screen [Media.maxWidth (px 640)] $ do
      ".note-item" %?% do
        flexDirection column
        "gap" -: ref cXs
      ".note-item__date" %?% do "min-width" -: "auto"
