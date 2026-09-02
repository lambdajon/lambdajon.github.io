module Website.Component
  ( Render (..)
  , Styled (..)
  , style
  ) where

import Clay (Css)
import Lucid (Html)
import Website.Context (Ctx)

-- | Render a component to HTML. May require site context via Ctx.
class Render a where
  render :: (Ctx) => a -> Html ()

class Styled a where
  style_ :: Css

style :: forall a -> (Styled a) => Css
style (type a) = style_ @a
