module Website.Layout
  ( Page (..)
  , defPage
  , renderPageText
  , fullPage
  , page
  , writePage
  ) where

import Data.Text (Text)
import Data.Text.IO qualified as TIO
import Data.Text.Lazy qualified as TL
import Lucid
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Website.Component (render)
import Website.Components.Footer (Footer (..))
import Website.Components.Nav (Nav (..))
import Website.Context (Ctx, SiteCtx (..))

-- Page record ─────────────────────

data Page = Page
  { pageTitle :: !Text
  , pageLang :: !Text
  , pageHead :: Html ()
  , pageBack :: Html ()
  , pageBody :: Html ()
  , pageScripts :: Html ()
  }

defPage :: Page
defPage =
  Page
    { pageTitle = ""
    , pageLang = "en"
    , pageHead = mempty
    , pageBack = a_ [href_ "/"] "\x2190 home"
    , pageBody = mempty
    , pageScripts = mempty
    }

renderPageText :: Html () -> Text
renderPageText = TL.toStrict . renderText

writePage :: FilePath -> Html () -> IO ()
writePage dir html = do
  createDirectoryIfMissing True dir
  TIO.writeFile (dir </> "index.html") (renderPageText html)

fullPage :: (Ctx) => Page -> Html ()
fullPage pg = do
  doctype_
  html_ [lang_ pg.pageLang] $ do
    head_ $ do
      headContent pg.pageTitle
      pg.pageHead
    body_ $ do
      render Nav
      pg.pageBody
      render (Footer pg.pageBack)
      siteScripts
      pg.pageScripts

page :: (Ctx) => Text -> Text -> Html () -> Html ()
page title lang body =
  fullPage defPage{pageTitle = title, pageLang = lang, pageBody = body}

-- Head 

headContent :: (Ctx) => Text -> Html ()
headContent pageTitle = do
  meta_ [charset_ "UTF-8"]
  meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1.0"]
  title_ $ toHtml (pageTitle <> " \x2014 " <> ?ctx.ctxSiteTitle)
  link_ [rel_ "stylesheet", href_ "/theme.css"]
  link_ [rel_ "stylesheet", href_ "/fonts.css"]
  link_ [rel_ "stylesheet", href_ "/style.css"]
  script_ themeInitScript

themeInitScript :: Text
themeInitScript =
  "(function(){\
  \var s=localStorage.getItem('theme');\
  \if(!s)s=matchMedia('(prefers-color-scheme:light)').matches?'light':'dark';\
  \document.documentElement.setAttribute('data-theme',s);\
  \})()"

-- Scripts 

siteScripts :: Html ()
siteScripts = do
  script_ [src_ "/js/i18n.js"] ("" :: Text)
  script_ [src_ "/js/main.js"] ("" :: Text)
