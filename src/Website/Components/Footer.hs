module Website.Components.Footer (Footer (..)) where

import Clay hiding (filter, span_, (?))
import Data.Text (Text)
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

data Footer = Footer Text (Html ())

instance Render Footer where
  render (Footer lang extra) =
    footer_ [class_ "footer"] $ do
      span_ [makeAttribute "data-i18n" "footer.copyright"]
        $ toHtml ("\xa9 2025 " <> ?ctx.ctxSiteTitle)
      a_
        [ href_ "https://creativecommons.org/licenses/by/4.0/"
        , makeAttribute "rel" "license"
        , makeAttribute "target" "_blank"
        ]
        "CC BY 4.0"
      a_ [href_ feedHref, class_ "footer__rss", makeAttribute "title" "RSS Feed"] $ do
        rssIcon
        " RSS"
      extra
   where
    feedHref =
      if lang == ?ctx.ctxDefaultLang
        then "/feed.xml"
        else "/" <> lang <> "/feed.xml"
    rssIcon =
      toHtmlRaw
        ( "<svg width='12' height='12' viewBox='0 0 24 24' fill='currentColor'>"
            <> "<circle cx='6.18' cy='17.82' r='2.18'/>"
            <> "<path d='M4 4.44v2.83c7.03 0 12.73 5.7 12.73 12.73h2.83c0-8.59-6.97-15.56-15.56-15.56z'/>"
            <> "<path d='M4 10.1v2.83c3.9 0 7.07 3.17 7.07 7.07h2.83c0-5.47-4.43-9.9-9.9-9.9z'/>"
            <> "</svg>"
            :: Text
        )

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

    ".footer__rss" %?% do
      display flex
      alignItems center
      "gap" -: "4px"
