module Website.Components.NoteList
  ( NoteList
  , NoteItem (..)
  ) where

import Clay hiding (filter, p, span_, (?))
import Data.Text qualified as T
import Lucid
import Website.Component (Render (..), Styled (..))
import Website.Post (Frontmatter (..), Post (..), postUrl)
import Website.Prelude ((%?%))
import Website.Theme
  ( cBgPanel
  , cBorder
  , cFg
  , cFgMuted
  , cFontMono
  , cFontSerif
  , cGbAqua
  , cLg
  , cMd
  , ref
  )
import Prelude hiding (rem)

data NoteList

newtype NoteItem = NoteItem Post

instance Render NoteItem where
  render (NoteItem p) =
    let fm = p.postFrontmatter
        dateStr = maybe "" (T.pack . show) fm.fmDate
     in div_ [class_ "note-item"] $ do
          span_ [class_ "note-item__date"] (toHtml dateStr)
          span_ [class_ "note-item__title"]
            $ a_ [href_ (postUrl p)] (toHtml fm.fmTitle)

instance Styled NoteList where
  style_ = do
    ".note-list" %?% do
      display flex
      flexDirection column

    ".note-item" %?% do
      display flex
      alignItems baseline
      "gap" -: ref cLg
      "padding" -: ref cMd <> " 0"
      "border-bottom" -: "1px dashed " <> ref cBorder
      "transition" -: "background 0.15s ease"

    ".note-item:hover" %?% do
      "background" -: ref cBgPanel
      "margin" -: "0 calc(-1 * " <> ref cMd <> ")"
      "padding-left" -: ref cMd
      "padding-right" -: ref cMd

    ".note-item__date" %?% do
      "font-family" -: ref cFontMono
      fontSize (rem 0.72)
      "color" -: ref cFgMuted
      whiteSpace nowrap
      minWidth (rem 6)

    ".note-item__title" %?% do
      "font-family" -: ref cFontSerif
      fontSize (rem 1)
      "color" -: ref cFg

    ".note-item__title a" %?% do "color" -: "inherit"

    ".note-item__title a:hover" %?% do
      "color" -: ref cGbAqua
      textDecoration none
