module Website.Components.Nav (Nav (..)) where

import Clay hiding (filter, href, label, span_, (?))
import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Lucid
import Lucid.Base (makeAttribute)
import Website.Component (Render (..), Styled (..))
import Website.Context (SiteCtx (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBg
  , cBorder
  , cFg
  , cFgBright
  , cFgDim
  , cFgMuted
  , cFontMono
  , cFontSerif
  , cGbBg0H
  , cLg
  , cNavHeight
  , cRadius
  , cXl
  , ref
  )
import Prelude hiding (rem)

data Nav = Nav Text

instance Render Nav where
  render (Nav navLang) =
    nav_ [class_ "nav"] $ do
      a_ [href_ "/", class_ "nav__brand"] $ do
        span_ [class_ "nav__brand-accent"] "\x03bb"
        toHtml (" " <> T.toLower ?ctx.ctxSiteTitle)
      ul_ [class_ "nav__links"] $ do
        navLink "/articles/" "nav.posts" "articles"
        navLink "/projects/" "nav.projects" "projects"
        navLink "/notes/" "nav.notes" "notes"
        navLink "/about/" "nav.about" "about"
      button_
        [ class_ "theme-btn"
        , makeAttribute "data-theme-toggle" ""
        , makeAttribute "aria-label" "Toggle theme"
        ]
        $ toHtmlRaw
          ( "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'>"
              <> "<circle cx='12' cy='12' r='4'/>"
              <> "<line x1='12' y1='2' x2='12' y2='6'/>"
              <> "<line x1='12' y1='18' x2='12' y2='22'/>"
              <> "<line x1='4.93' y1='4.93' x2='7.76' y2='7.76'/>"
              <> "<line x1='16.24' y1='16.24' x2='19.07' y2='19.07'/>"
              <> "<line x1='2' y1='12' x2='6' y2='12'/>"
              <> "<line x1='18' y1='12' x2='22' y2='12'/>"
              <> "<line x1='4.93' y1='19.07' x2='7.76' y2='16.24'/>"
              <> "<line x1='16.24' y1='7.76' x2='19.07' y2='4.93'/>"
              <> "</svg>"
              :: T.Text
          )
      div_ [class_ "lang-switcher"] $ do
        button_ [class_ "lang-btn", makeAttribute "data-lang-btn" "en"] "EN"
        button_ [class_ "lang-btn", makeAttribute "data-lang-btn" "uz"] "UZ"
   where
    dict = Map.findWithDefault Map.empty navLang ?ctx.ctxI18n
    t key fallback = Map.findWithDefault fallback key dict
    navLink href i18nKey fallback =
      li_ $ a_ [href_ href, class_ "nav__link", makeAttribute "data-i18n" i18nKey] (toHtml $ t i18nKey fallback)

instance Styled Nav where
  style_ = do
    ".nav" %?% do
      position sticky
      top (px 0)
      zIndex 100
      "background" -: ref cGbBg0H
      "border-bottom" -: "1px solid " <> ref cBorder
      "height" -: ref cNavHeight
      display flex
      alignItems center
      "padding" -: "0 clamp(1.5rem, 5vw, 3rem)"
      "gap" -: ref cXl

    ".nav__brand" %?% do
      "font-family" -: ref cFontSerif
      fontSize (rem 1.1)
      fontWeight bold
      "color" -: ref cFg
      marginRight auto
      "letter-spacing" -: "-0.02em"

    ".nav__brand:hover" %?% do
      textDecoration none
      "color" -: ref cFgBright

    ".nav__brand-accent" %?% do "color" -: ref cAccent

    ".nav__links" %?% do
      display flex
      "gap" -: ref cLg
      "list-style" -: "none"

    ".nav__link" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.78)
      "letter-spacing" -: "0.04em"
      "color" -: ref cFgDim
      fontWeight (weight 500)
      textTransform lowercase

    ".nav__link:hover" %?% do
      "color" -: ref cAccent
      textDecoration none

    ".nav__link--active" %?% do "color" -: ref cAccent

    ".lang-switcher" %?% do
      display flex
      "gap" -: "4px"
      "font-family" -: ref cFontMono
      fontSize (rem 0.7)

    ".lang-btn" %?% do
      "border" -: "1px solid " <> ref cBorder
      background transparent
      "color" -: ref cFgMuted
      "padding" -: "2px 8px"
      cursor pointer
      "border-radius" -: ref cRadius
      "transition" -: "all 0.15s ease"

    (".lang-btn:hover" <> ".lang-btn.active") %?% do
      "background" -: ref cFg
      "color" -: ref cBg
      "border-color" -: ref cFg

    ".theme-btn" %?% do
      display flex
      alignItems center
      justifyContent center
      "appearance" -: "none"
      "-webkit-appearance" -: "none"
      "margin" -: "0"
      "border" -: "1px solid " <> ref cBorder
      background transparent
      "color" -: ref cFgMuted
      "padding" -: "4px 8px"
      cursor pointer
      "border-radius" -: ref cRadius
      "transition" -: "all 0.15s ease"

    ".theme-btn:hover" %?% do
      "background" -: ref cFg
      "color" -: ref cBg
      "border-color" -: ref cFg
