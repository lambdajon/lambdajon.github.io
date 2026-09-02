module Website.Theme
  ( Palette (..)
  , gruvboxDark
  , gruvboxLight
  , paletteStyle
  , buildThemeCss
  , CssVar
  , ref
  -- Gruvbox palette vars
  , cGbBg0H
  , cGbBg0
  , cGbBg0S
  , cGbBg1
  , cGbBg2
  , cGbBg3
  , cGbBg4
  , cGbFg0
  , cGbFg1
  , cGbFg2
  , cGbFg3
  , cGbFg4
  , cGbRed
  , cGbRedDim
  , cGbGreen
  , cGbGreenDim
  , cGbYellow
  , cGbYellowDim
  , cGbBlue
  , cGbBlueDim
  , cGbPurple
  , cGbPurpleDim
  , cGbAqua
  , cGbAquaDim
  , cGbOrange
  , cGbOrangeDim
  , cGbGray
  -- Semantic vars
  , cBg
  , cBgSoft
  , cBgPanel
  , cBgHighlight
  , cFg
  , cFgBright
  , cFgDim
  , cFgMuted
  , cAccent
  , cAccentDim
  , cLink
  , cLinkHover
  , cBorder
  , cBorderStrong
  , cRadius
  , cRadiusLg
  -- Typography vars
  , cFontMono
  , cFontSerif
  -- Layout / spacing vars
  , cMaxW
  , cNavHeight
  , cXs
  , cSm
  , cMd
  , cLg
  , cXl
  , cXxl
  ) where

import Data.Map.Strict qualified as Map
import Data.Text (Text)
import Data.Text qualified as T
import Data.Text.IO qualified as TIO
import Skylighting.Types
import System.FilePath ((</>))

-- Palette ─────────────────────────

data Palette = Palette
  { pBg0H :: Text
  , pBg0 :: Text
  , pBg0S :: Text
  , pBg1 :: Text
  , pBg2 :: Text
  , pBg3 :: Text
  , pBg4 :: Text
  , pFg0 :: Text
  , pFg1 :: Text
  , pFg2 :: Text
  , pFg3 :: Text
  , pFg4 :: Text
  , pRed :: Text
  , pRedDim :: Text
  , pGreen :: Text
  , pGreenDim :: Text
  , pYellow :: Text
  , pYellowDim :: Text
  , pBlue :: Text
  , pBlueDim :: Text
  , pPurple :: Text
  , pPurpleDim :: Text
  , pAqua :: Text
  , pAquaDim :: Text
  , pOrange :: Text
  , pOrangeDim :: Text
  , pGray :: Text
  }
  deriving stock (Show)

gruvboxDark :: Palette
gruvboxDark =
  Palette
    { pBg0H = "#1d2021"
    , pBg0 = "#282828"
    , pBg0S = "#32302f"
    , pBg1 = "#3c3836"
    , pBg2 = "#504945"
    , pBg3 = "#665c54"
    , pBg4 = "#7c6f64"
    , pFg0 = "#fbf1c7"
    , pFg1 = "#ebdbb2"
    , pFg2 = "#d5c4a1"
    , pFg3 = "#bdae93"
    , pFg4 = "#a89984"
    , pRed = "#fb4934"
    , pRedDim = "#cc241d"
    , pGreen = "#b8bb26"
    , pGreenDim = "#98971a"
    , pYellow = "#fabd2f"
    , pYellowDim = "#d79921"
    , pBlue = "#83a598"
    , pBlueDim = "#458588"
    , pPurple = "#d3869b"
    , pPurpleDim = "#b16286"
    , pAqua = "#8ec07c"
    , pAquaDim = "#689d6a"
    , pOrange = "#fe8019"
    , pOrangeDim = "#d65d0e"
    , pGray = "#928374"
    }

gruvboxLight :: Palette
gruvboxLight =
  Palette
    { pBg0H = "#f9f5d7"
    , pBg0 = "#fbf1c7"
    , pBg0S = "#f2e5bc"
    , pBg1 = "#ebdbb2"
    , pBg2 = "#d5c4a1"
    , pBg3 = "#bdae93"
    , pBg4 = "#a89984"
    , pFg0 = "#282828"
    , pFg1 = "#3c3836"
    , pFg2 = "#504945"
    , pFg3 = "#665c54"
    , pFg4 = "#7c6f64"
    , pRed = "#cc241d"
    , pRedDim = "#9d0006"
    , pGreen = "#98971a"
    , pGreenDim = "#79740e"
    , pYellow = "#d79921"
    , pYellowDim = "#b57614"
    , pBlue = "#458588"
    , pBlueDim = "#076678"
    , pPurple = "#b16286"
    , pPurpleDim = "#8f3f71"
    , pAqua = "#689d6a"
    , pAquaDim = "#427b58"
    , pOrange = "#d65d0e"
    , pOrangeDim = "#af3a03"
    , pGray = "#928374"
    }

-- Skylighting style ───────────────

paletteStyle :: Palette -> Style
paletteStyle p =
  Style
    { tokenStyles =
        Map.fromList
          [ (KeywordTok, defStyle{tokenColor = col p.pRed, tokenBold = True})
          , (DataTypeTok, defStyle{tokenColor = col p.pYellow})
          , (DecValTok, defStyle{tokenColor = col p.pPurple})
          , (BaseNTok, defStyle{tokenColor = col p.pPurple})
          , (FloatTok, defStyle{tokenColor = col p.pPurple})
          , (CharTok, defStyle{tokenColor = col p.pGreen})
          , (StringTok, defStyle{tokenColor = col p.pGreen})
          , (CommentTok, defStyle{tokenColor = col p.pGray, tokenItalic = True})
          , (OtherTok, defStyle{tokenColor = col p.pAqua})
          , (FunctionTok, defStyle{tokenColor = col p.pYellow})
          , (VariableTok, defStyle{tokenColor = col p.pFg1})
          , (ControlFlowTok, defStyle{tokenColor = col p.pRed, tokenBold = True})
          , (OperatorTok, defStyle{tokenColor = col p.pAqua})
          , (ImportTok, defStyle{tokenColor = col p.pBlue})
          , (SpecialCharTok, defStyle{tokenColor = col p.pOrange})
          , (SpecialStringTok, defStyle{tokenColor = col p.pGreen})
          , (ErrorTok, defStyle{tokenColor = col p.pRed, tokenUnderline = True})
          , (NormalTok, defStyle{tokenColor = col p.pFg1})
          ]
    , defaultColor = col p.pFg1
    , backgroundColor = col p.pBg0
    , lineNumberColor = col p.pGray
    , lineNumberBackgroundColor = col p.pBg0H
    }
 where
  col = toColor . T.unpack

-- CSS variable name constants (internal) ────────────────────────
--
-- Each CSS custom property name is defined exactly once here.
-- Both the :root {} generation and the Vars record below use
-- these constants, so renaming a variable is a single-line change.

newtype CssVar = CssVar Text

-- Wrap a CssVar in var() for use as a CSS property value.
ref :: CssVar -> Text
ref (CssVar n) = "var(" <> n <> ")"

-- Format a single :root property line.
prop :: CssVar -> Text -> Text
prop (CssVar n) val = "  " <> n <> ": " <> val <> ";"

-- Gruvbox palette vars
cGbBg0H, cGbBg0, cGbBg0S :: CssVar
cGbBg0H = CssVar "--gb-bg0-h"
cGbBg0 = CssVar "--gb-bg0"
cGbBg0S = CssVar "--gb-bg0-s"

cGbBg1, cGbBg2, cGbBg3, cGbBg4 :: CssVar
cGbBg1 = CssVar "--gb-bg1"
cGbBg2 = CssVar "--gb-bg2"
cGbBg3 = CssVar "--gb-bg3"
cGbBg4 = CssVar "--gb-bg4"

cGbFg0, cGbFg1, cGbFg2, cGbFg3, cGbFg4 :: CssVar
cGbFg0 = CssVar "--gb-fg0"
cGbFg1 = CssVar "--gb-fg1"
cGbFg2 = CssVar "--gb-fg2"
cGbFg3 = CssVar "--gb-fg3"
cGbFg4 = CssVar "--gb-fg4"

cGbRed, cGbRedDim, cGbGreen, cGbGreenDim :: CssVar
cGbRed = CssVar "--gb-red"
cGbRedDim = CssVar "--gb-red-dim"
cGbGreen = CssVar "--gb-green"
cGbGreenDim = CssVar "--gb-green-dim"

cGbYellow, cGbYellowDim, cGbBlue, cGbBlueDim :: CssVar
cGbYellow = CssVar "--gb-yellow"
cGbYellowDim = CssVar "--gb-yellow-dim"
cGbBlue = CssVar "--gb-blue"
cGbBlueDim = CssVar "--gb-blue-dim"

cGbPurple, cGbPurpleDim, cGbAqua, cGbAquaDim :: CssVar
cGbPurple = CssVar "--gb-purple"
cGbPurpleDim = CssVar "--gb-purple-dim"
cGbAqua = CssVar "--gb-aqua"
cGbAquaDim = CssVar "--gb-aqua-dim"

cGbOrange, cGbOrangeDim, cGbGray :: CssVar
cGbOrange = CssVar "--gb-orange"
cGbOrangeDim = CssVar "--gb-orange-dim"
cGbGray = CssVar "--gb-gray"

-- Semantic vars
cBg, cBgSoft, cBgPanel, cBgHighlight :: CssVar
cBg = CssVar "--bg"
cBgSoft = CssVar "--bg-soft"
cBgPanel = CssVar "--bg-panel"
cBgHighlight = CssVar "--bg-highlight"

cFg, cFgBright, cFgDim, cFgMuted :: CssVar
cFg = CssVar "--fg"
cFgBright = CssVar "--fg-bright"
cFgDim = CssVar "--fg-dim"
cFgMuted = CssVar "--fg-muted"

cAccent, cAccentDim, cLink, cLinkHover :: CssVar
cAccent = CssVar "--accent"
cAccentDim = CssVar "--accent-dim"
cLink = CssVar "--link"
cLinkHover = CssVar "--link-hover"

cBorder, cBorderStrong :: CssVar
cBorder = CssVar "--border"
cBorderStrong = CssVar "--border-strong"

cRadius, cRadiusLg :: CssVar
cRadius = CssVar "--radius"
cRadiusLg = CssVar "--radius-lg"

-- Typography vars
cFontMono, cFontSerif :: CssVar
cFontMono = CssVar "--font-mono"
cFontSerif = CssVar "--font-serif"

-- Layout / spacing vars
cMaxW, cNavHeight :: CssVar
cMaxW = CssVar "--max-width"
cNavHeight = CssVar "--nav-height"

cXs, cSm, cMd, cLg, cXl, cXxl :: CssVar
cXs = CssVar "--spacing-xs"
cSm = CssVar "--spacing-sm"
cMd = CssVar "--spacing-md"
cLg = CssVar "--spacing-lg"
cXl = CssVar "--spacing-xl"
cXxl = CssVar "--spacing-2xl"

-- CSS generation ──────────────────

themeCss :: Palette -> Text
themeCss p =
  T.unlines
    $ [":root {"]
      <> palettProps p
      <> ["", "  /* Semantic */"]
      <> semanticProps
      <> ["", "  /* Typography */"]
      <> typographyProps
      <> ["", "  /* Layout */"]
      <> layoutProps
      <> ["}"]

palettProps :: Palette -> [Text]
palettProps p =
  [ "  /* Gruvbox Dark */"
  , prop cGbBg0H p.pBg0H
  , prop cGbBg0 p.pBg0
  , prop cGbBg0S p.pBg0S
  , prop cGbBg1 p.pBg1
  , prop cGbBg2 p.pBg2
  , prop cGbBg3 p.pBg3
  , prop cGbBg4 p.pBg4
  , prop cGbFg0 p.pFg0
  , prop cGbFg1 p.pFg1
  , prop cGbFg2 p.pFg2
  , prop cGbFg3 p.pFg3
  , prop cGbFg4 p.pFg4
  , prop cGbRed p.pRed
  , prop cGbRedDim p.pRedDim
  , prop cGbGreen p.pGreen
  , prop cGbGreenDim p.pGreenDim
  , prop cGbYellow p.pYellow
  , prop cGbYellowDim p.pYellowDim
  , prop cGbBlue p.pBlue
  , prop cGbBlueDim p.pBlueDim
  , prop cGbPurple p.pPurple
  , prop cGbPurpleDim p.pPurpleDim
  , prop cGbAqua p.pAqua
  , prop cGbAquaDim p.pAquaDim
  , prop cGbOrange p.pOrange
  , prop cGbOrangeDim p.pOrangeDim
  , prop cGbGray p.pGray
  ]

semanticProps :: [Text]
semanticProps =
  [ prop cBg (ref cGbBg0)
  , prop cBgSoft (ref cGbBg0S)
  , prop cBgPanel (ref cGbBg1)
  , prop cBgHighlight (ref cGbBg2)
  , prop cFg (ref cGbFg1)
  , prop cFgBright (ref cGbFg0)
  , prop cFgDim (ref cGbFg3)
  , prop cFgMuted (ref cGbFg4)
  , prop cAccent (ref cGbOrange)
  , prop cAccentDim (ref cGbOrangeDim)
  , prop cLink (ref cGbAqua)
  , prop cLinkHover (ref cGbGreen)
  , prop cBorder (ref cGbBg2)
  , prop cBorderStrong (ref cGbBg3)
  ]

typographyProps :: [Text]
typographyProps =
  [ prop cFontMono "'JetBrains Mono', 'Fira Code', monospace"
  , prop cFontSerif "'Source Serif 4', Georgia, serif"
  ]

layoutProps :: [Text]
layoutProps =
  [ prop cMaxW "860px"
  , prop cNavHeight "56px"
  , prop cXs "0.25rem"
  , prop cSm "0.5rem"
  , prop cMd "1rem"
  , prop cLg "1.5rem"
  , prop cXl "2.5rem"
  , prop cXxl "4rem"
  , prop cRadius "4px"
  , prop cRadiusLg "8px"
  ]

lightOverrideCss :: Palette -> Text
lightOverrideCss p =
  T.unlines $ ["[data-theme=\"light\"] {"] <> palettProps p <> ["}"]

buildThemeCss :: FilePath -> Palette -> Palette -> IO ()
buildThemeCss outDir dark light = do
  TIO.writeFile (outDir </> "theme.css") (themeCss dark <> "\n" <> lightOverrideCss light)
  putStrLn "Theme: wrote theme.css"
