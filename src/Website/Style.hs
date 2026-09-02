module Website.Style (buildStyleCss) where

import Clay (Css, compact, renderWith)
import Data.Text.IO qualified as TIO
import Data.Text.Lazy qualified as TL
import System.FilePath ((</>))
import Website.Component (style)
import Website.Components.Base (Base)
import Website.Components.Card (Card)
import Website.Components.CodeBlock (CodeBlock)
import Website.Components.ContactBox (ContactBox)
import Website.Components.Content (Content)
import Website.Components.Footer (Footer)
import Website.Components.Hero (Hero)
import Website.Components.Nav (Nav)
import Website.Components.NoteList (NoteList)
import Website.Components.PageHeader (PageHeader)
import Website.Components.Section (Section)
import Website.Components.Tag (TagBadge, TagIndex)

buildStyleCss :: FilePath -> IO ()
buildStyleCss outDir = do
  TIO.writeFile (outDir </> "style.css") . TL.toStrict . renderWith compact [] $ allCss
  putStrLn "Style: wrote style.css"

allCss :: Css
allCss =
  mconcat
    [ style Base
    , style Nav
    , style Footer
    , style Hero
    , style PageHeader
    , style Section
    , style Card
    , style NoteList
    , style TagBadge
    , style TagIndex
    , style Content
    , style CodeBlock
    , style ContactBox
    ]
