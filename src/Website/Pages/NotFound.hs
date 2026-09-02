module Website.Pages.NotFound
  ( notFoundPage
  , build404
  ) where

import Data.Text.IO qualified as TIO
import Lucid
import System.FilePath ((</>))
import Website.Context (Ctx)
import Website.Layout (Page (..), defPage, fullPage, renderPageText)

notFoundPage :: Html ()
notFoundPage =
  div_ [class_ "page-header"] $ do
    p_ [class_ "error-code"] "404"
    h1_ [class_ "page-header__title"] "page not found"
    p_ [class_ "page-header__subtitle"] "the page you're looking for doesn't exist or was moved."
    div_ [class_ "mt-lg"] $ a_ [href_ "/", class_ "nav__link"] "\x2190 back to home"

build404 :: (Ctx) => FilePath -> IO ()
build404 outDir = do
  let html = renderPageText $ fullPage defPage{pageTitle = "404 \x2014 Not Found", pageBody = notFoundPage}
  TIO.writeFile (outDir </> "404.html") html
  putStrLn "Pages: wrote 404.html"
