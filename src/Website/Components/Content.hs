module Website.Components.Content (Content) where

import Clay hiding (Content, filter, (?))
import Website.Component (Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBgHighlight
  , cBgPanel
  , cBorder
  , cBorderStrong
  , cFg
  , cFgBright
  , cFgDim
  , cFontMono
  , cFontSerif
  , cGbAqua
  , cGbBg0H
  , cGbOrange
  , cLg
  , cMaxW
  , cMd
  , cRadius
  , cRadiusLg
  , cSm
  , cXl
  , cXs
  , cXxl
  , ref
  )
import Prelude hiding (rem)

data Content

instance Styled Content where
  style_ = do
    ".content" %?% do
      "max-width" -: ref cMaxW
      margin (px 0) auto (px 0) auto
      "padding" -: "0 clamp(1.5rem, 5vw, 3rem) " <> ref cXxl
      "font-family" -: ref cFontSerif
      fontSize (rem 1.05)
      lineHeight (unitless 1.75)

    ".content nav[role=doc-toc]" %?% do
      "background" -: ref cBgPanel
      "border" -: "1px solid " <> ref cBorder
      "border-left" -: "3px solid " <> ref cAccent
      "border-radius" -: "0 " <> ref cRadius <> " " <> ref cRadius <> " 0"
      "padding" -: ref cMd <> " " <> ref cLg
      "margin-bottom" -: ref cXl
      fontSize (rem 0.88)

    ".content nav[role=doc-toc]::before" %?% do
      "content" -: "\"Table of contents\""
      display block
      "font-family" -: ref cFontMono
      fontSize (rem 0.72)
      "letter-spacing" -: "0.06em"
      textTransform uppercase
      "color" -: ref cAccent
      "margin-bottom" -: ref cSm

    ".content nav[role=doc-toc] ul" %?% do
      "padding-left" -: ref cLg
      "margin" -: "0"
      "list-style" -: "none"

    ".content nav[role=doc-toc] > ul" %?% do "padding-left" -: "0"

    ".content nav[role=doc-toc] li" %?% do
      "margin-bottom" -: ref cXs
      lineHeight (unitless 1.5)

    ".content nav[role=doc-toc] a" %?% do
      "font-family" -: ref cFontMono
      "color" -: ref cFgDim
      textDecoration none

    ".content nav[role=doc-toc] a:hover" %?% do
      "color" -: ref cGbAqua
      textDecoration none

    ".content h2" %?% do
      "font-family" -: ref cFontSerif
      fontSize (rem 1.3)
      fontWeight bold
      "margin" -: ref cXl <> " 0 " <> ref cMd
      "color" -: ref cFgBright
      "border-bottom" -: "1px solid " <> ref cBorder
      "padding-bottom" -: ref cSm

    ".content h2:first-child" %?% marginTop (px 0)

    ".content h3" %?% do
      "font-family" -: ref cFontSerif
      fontSize (rem 1.1)
      fontWeight bold
      "margin" -: ref cLg <> " 0 " <> ref cSm
      "color" -: ref cFgBright

    ".content p" %?% do
      "color" -: ref cFg
      "margin-bottom" -: ref cMd

    (".content ul" <> ".content ol") %?% do
      "padding-left" -: ref cLg
      "color" -: ref cFg
      "margin-bottom" -: ref cMd

    ".content li" %?% do "margin-bottom" -: ref cXl

    ".content strong" %?% do
      "color" -: ref cFgBright
      fontWeight (weight 600)

    ".content a" %?% do "color" -: ref cFgBright

    ".content blockquote" %?% do
      "border-left" -: "3px solid " <> ref cGbAqua
      "padding" -: ref cSm <> " " <> ref cLg
      "margin" -: ref cLg <> " 0"
      "background" -: ref cBgPanel
      "color" -: ref cFgDim
      fontStyle italic
      "border-radius" -: "0 " <> ref cRadius <> " " <> ref cRadius <> " 0"

    ".content code" %?% do
      "font-family" -: ref cFontMono
      "font-size" -: "0.85em"
      "background" -: ref cBgHighlight
      "color" -: ref cGbOrange
      "padding" -: "2px 6px"
      "border-radius" -: ref cRadius

    ".content pre" %?% do
      position relative
      "background" -: ref cGbBg0H
      "border" -: "1px solid " <> ref cBorder
      "padding" -: ref cLg
      "border-radius" -: ref cRadiusLg
      overflowX auto
      "margin" -: ref cLg <> " 0"
      "font-family" -: ref cFontMono
      fontSize (rem 0.85)
      lineHeight (unitless 1.6)

    ".content pre code" %?% do
      background transparent
      "color" -: ref cFg
      "padding" -: "0"

    ".content table" %?% do
      width (pct 100)
      borderCollapse collapse
      "margin" -: ref cLg <> " 0"
      fontSize (rem 0.9)

    ".content th" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.75)
      "letter-spacing" -: "0.05em"
      textTransform uppercase
      "padding" -: ref cSm <> " " <> ref cMd
      "background" -: ref cBgPanel
      "border-bottom" -: "2px solid " <> ref cBorderStrong
      textAlign (alignSide sideLeft)
      "color" -: ref cFgBright

    ".content td" %?% do
      "padding" -: ref cSm <> " " <> ref cMd
      "border-bottom" -: "1px solid " <> ref cBorder
      "color" -: ref cFg

    ".content hr" %?% do
      "border" -: "none"
      "border-top" -: "1px dashed " <> ref cBorder
      "margin" -: ref cXl <> " 0"

    ".code-copy-btn" %?% do
      position absolute
      "top" -: ref cSm
      "right" -: ref cSm
      "background" -: ref cBgPanel
      "border" -: "1px solid " <> ref cBorder
      "border-radius" -: ref cRadius
      cursor pointer
      "font-family" -: ref cFontMono
      fontSize (rem 0.65)
      "color" -: ref cFgBright
      "padding" -: "2px 8px"
      lineHeight (unitless 1.4)
      "user-select" -: "none"
      opacity 0
      "transition" -: "opacity 0.15s ease, color 0.15s ease"

    ".content pre:hover .code-copy-btn" %?% opacity 1

    ".code-copy-btn:hover" %?% do
      "color" -: ref cFg
      "border-color" -: ref cBorderStrong

    ".code-copy-btn.copied" %?% do
      "color" -: ref cGbAqua
      opacity 1
