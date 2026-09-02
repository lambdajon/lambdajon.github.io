module Website.Components.CodeBlock (CodeBlock) where

import Clay hiding (filter, (?))
import Website.Component (Styled (..))
import Website.Prelude ((%?%))
import Website.Theme
  ( cGbAqua
  , cGbBlue
  , cGbFg1
  , cGbGray
  , cGbGreen
  , cGbOrange
  , cGbPurple
  , cGbRed
  , cGbYellow
  , ref
  )
import Prelude hiding (rem)

data CodeBlock

instance Styled CodeBlock where
  style_ = do
    ".hljs" %?% do "color" -: ref cGbFg1

    (".hljs-comment" <> ".hljs-quote") %?% do
      "color" -: ref cGbGray
      fontStyle italic

    (".hljs-keyword" <> ".hljs-selector-tag") %?% do "color" -: ref cGbRed

    (".hljs-number" <> ".hljs-literal") %?% do "color" -: ref cGbPurple

    (".hljs-string" <> ".hljs-doctag") %?% do "color" -: ref cGbGreen

    (".hljs-title" <> ".hljs-section" <> ".hljs-built_in") %?% do
      "color" -: ref cGbYellow
      fontWeight (weight 500)

    ".hljs-type" %?% do "color" -: ref cGbYellow

    (".hljs-tag" <> ".hljs-name" <> ".hljs-attr") %?% do "color" -: ref cGbBlue

    (".hljs-variable" <> ".hljs-template-variable") %?% do "color" -: ref cGbAqua

    (".hljs-symbol" <> ".hljs-bullet") %?% do "color" -: ref cGbOrange

    ".hljs-operator" %?% do "color" -: ref cGbAqua

    ".hljs-property" %?% do "color" -: ref cGbBlue

    ".hljs-function" %?% do "color" -: ref cGbGreen
