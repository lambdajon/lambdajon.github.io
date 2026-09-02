module Website.Components.Card
  ( Card
  , ProjectCard (..)
  ) where

import Clay hiding (filter, p, render, span_, summary, (?))
import Control.Monad (unless)
import Data.Maybe (fromMaybe)
import Data.Text qualified as T
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Components.Tag (TagBadge (..))
import Website.Post (Frontmatter (..), Post (..), postUrl)
import Website.Prelude ((%?%))
import Website.Theme
  ( cAccent
  , cBgPanel
  , cBorder
  , cFgBright
  , cFgDim
  , cFgMuted
  , cFontMono
  , cFontSerif
  , cGbAqua
  , cGbYellow
  , cLg
  , cMd
  , cRadius
  , cSm
  , cXs
  , ref
  )
import Prelude hiding (rem)

data Card

newtype ProjectCard = ProjectCard Post

instance Render ProjectCard where
  render (ProjectCard p) =
    let fm = p.postFrontmatter
        summary = fromMaybe "" fm.fmSummary
     in article_ [class_ "card"] $ do
          h3_ [class_ "card__title"]
            $ a_ [href_ (postUrl p)] (toHtml fm.fmTitle)
          unless (T.null summary)
            $ p_ [class_ "card__summary"] (toHtml summary)
          div_ [class_ "card__tags"] $ mapM_ (render . TagBadge) fm.fmTags

instance Styled Card where
  style_ = do
    ".card-list" %?% do
      display flex
      flexDirection column
      "gap" -: ref cMd

    ".card" %?% do
      "padding" -: ref cLg
      "background" -: ref cBgPanel
      "border" -: "1px solid " <> ref cBorder
      "border-left" -: "3px solid " <> ref cAccent
      "border-radius" -: "0 " <> ref cRadius <> " " <> ref cRadius <> " 0"
      "transition" -: "transform 0.15s ease, border-color 0.15s ease"

    ".card:hover" %?% do
      "transform" -: "translateX(4px)"
      "border-left-color" -: ref cGbYellow

    ".card__title" %?% do
      "font-family" -: ref cFontSerif
      fontSize (rem 1.05)
      fontWeight bold
      "color" -: ref cFgBright
      lineHeight (unitless 1.4)

    ".card__title a" %?% do "color" -: "inherit"

    ".card__title a:hover" %?% do
      "color" -: ref cGbAqua
      textDecoration none

    ".card__meta" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.72)
      "color" -: ref cFgMuted
      "margin-top" -: ref cXs
      display flex
      "gap" -: ref cMd
      "flex-wrap" -: "wrap"

    ".card__summary" %?% do
      fontSize (rem 0.9)
      "color" -: ref cFgDim
      "margin-top" -: ref cSm
      lineHeight (unitless 1.6)

    ".card__tags" %?% do
      display flex
      "gap" -: ref cSm
      "flex-wrap" -: "wrap"
      "margin-top" -: ref cSm
