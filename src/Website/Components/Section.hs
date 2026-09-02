module Website.Components.Section (Section (..)) where

import Clay hiding (filter, sec, (?))
import Data.Text (Text)
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cBorder
  , cFontMono
  , cGbYellow
  , cLg
  , cMaxW
  , cMd
  , cXxl
  , ref
  )
import Prelude hiding (rem)

data Section = Section
  { sLabel :: Text
  , sContent :: Html ()
  }

instance Render Section where
  render sec =
    section_ [class_ "section"] $ do
      div_ [class_ "section__label"] (toHtml sec.sLabel)
      sec.sContent

instance Styled Section where
  style_ = do
    ".section" %?% do
      "max-width" -: ref cMaxW
      margin (px 0) auto (px 0) auto
      "padding" -: ref cLg <> " clamp(1.5rem, 5vw, 3rem) " <> ref cXxl

    ".section__label" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.72)
      "letter-spacing" -: "0.1em"
      textTransform uppercase
      "color" -: ref cGbYellow
      "margin-bottom" -: ref cLg
      display flex
      alignItems center
      "gap" -: ref cMd

    ".section__label::after" %?% do
      "content" -: "''"
      "flex" -: "1"
      height (px 1)
      "background" -: ref cBorder
