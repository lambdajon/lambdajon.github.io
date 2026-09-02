{-# LANGUAGE OverloadedStrings #-}

module Website.Watch (runDevServer) where

import Control.Concurrent (forkIO, threadDelay)
import Control.Exception (SomeException, try)
import Control.Monad (forever, void)
import Data.ByteString.Lazy qualified as BL
import Network.HTTP.Types (hCacheControl, status404)
import Network.Wai (Application, Middleware, mapResponseHeaders, modifyResponse, responseLBS)
import Network.Wai.Application.Static (defaultFileServerSettings, ss404Handler, ssIndices, staticApp)
import Network.Wai.Handler.Warp (run)
import System.FSNotify (watchTree, withManager)
import System.FilePath ((</>))
import System.IO (hPutStrLn, stderr)
import WaiAppStatic.Types (unsafeToPiece)

runDevServer :: Int -> FilePath -> IO () -> IO ()
runDevServer port outDir buildAction = do
  putStrLn $ "Dev server: http://localhost:" <> show port
  buildAction

  void $ forkIO $ withManager $ \mgr -> do
    let watchAndRebuild dir = watchTree mgr dir (const True) $ \event -> do
          hPutStrLn stderr $ "Changed: " <> show event
          buildAction
    _ <- watchAndRebuild "data"
    forever (threadDelay maxBound)

  let settings =
        (defaultFileServerSettings outDir)
          { ssIndices = [unsafeToPiece "index.html"]
          , ss404Handler = Just (serve404 outDir)
          }
  run port (noCache (staticApp settings))

serve404 :: FilePath -> Application
serve404 outDir _req respond = do
  result <- try @SomeException $ BL.readFile (outDir </> "404.html")
  respond $ case result of
    Right html -> responseLBS status404 [("Content-Type", "text/html; charset=utf-8")] html
    Left _ -> responseLBS status404 [("Content-Type", "text/plain")] "404 Not Found"

noCache :: Middleware
noCache = modifyResponse (mapResponseHeaders ((hCacheControl, "no-store") :))
