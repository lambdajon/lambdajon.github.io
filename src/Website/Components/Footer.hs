module Website.Components.Footer (Footer (..)) where

import Clay hiding (filter, span_, (?))
import Lucid
import Lucid.Base (makeAttribute)
import Website.Component (Render (..), Styled (..))
import Website.Context (SiteCtx (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBorder
  , cFgMuted
  , cFontMono
  , cMaxW
  , cMd
  , cXl
  , ref
  )
import Prelude hiding (rem)

newtype Footer = Footer (Html ())

instance Render Footer where
  render (Footer extra) =
    footer_ [class_ "footer"] $ do
      span_ [makeAttribute "data-i18n" "footer.copyright"]
        $ toHtml ("\xa9 2025 " <> ?ctx.ctxSiteTitle)
      a_
        [ href_ "https://creativecommons.org/licenses/by/4.0/"
        , makeAttribute "rel" "license"
        , makeAttribute "target" "_blank"
        ]
        "CC BY 4.0"
      extra

instance Styled Footer where
  style_ = do
    ".footer" %?% do
      "max-width" -: ref cMaxW
      margin (px 0) auto (px 0) auto
      "padding" -: ref cXl <> " clamp(1.5rem, 5vw, 3rem)"
      display flex
      justifyContent spaceBetween
      alignItems center
      "flex-wrap" -: "wrap"
      "gap" -: ref cMd
      "font-family" -: ref cFontMono
      fontSize (rem 0.72)
      "color" -: ref cFgMuted
      "border-top" -: "1px solid " <> ref cBorder

    ".footer a" %?% do "color" -: ref cFgMuted

    ".footer a:hover" %?% do "color" -: ref cAccent
