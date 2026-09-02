module Website.Prelude ((%?%)) where

import Clay ((?))
import Clay.Selector (Selector)
import Clay.Stylesheet (Css)

-- Clay's (?) renamed so ImplicitParams' ?name syntax does not conflict.
infixr 5 %?%
(%?%) :: Selector -> Css -> Css
(%?%) = (?)
