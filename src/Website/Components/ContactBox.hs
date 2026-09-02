module Website.Components.ContactBox (ContactBox (..)) where

import Clay hiding (filter, (?))
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cBgPanel
  , cBorder
  , cFg
  , cFontMono
  , cGbAqua
  , cLg
  , cRadius
  , cXl
  , ref
  )
import Prelude hiding (rem)

data ContactBox = ContactBox

instance Render ContactBox where
  render ContactBox =
    div_ [class_ "contact-box"]
      $ p_
      $ do
        "Get in touch: "
        a_ [href_ "mailto:lambdajon42@gmail.com"] "lambdajon42@gmail.com"

instance Styled ContactBox where
  style_ = do
    ".contact-box" %?% do
      "background" -: ref cBgPanel
      "border" -: "1px solid " <> ref cBorder
      "border-left" -: "3px solid " <> ref cGbAqua
      "border-radius" -: "0 " <> ref cRadius <> " " <> ref cRadius <> " 0"
      "padding" -: ref cLg
      "margin-top" -: ref cXl

    ".contact-box p" %?% do
      margin (px 0) (px 0) (px 0) (px 0)
      "font-family" -: ref cFontMono
      fontSize (rem 0.88)
      "color" -: ref cFg
