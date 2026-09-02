module Website.Assets (copyAssets) where

import Control.Monad (forM_)
import System.Directory
  ( copyFileWithMetadata
  , createDirectoryIfMissing
  , doesFileExist
  , listDirectory
  )
import System.FilePath ((</>))

-- | Recursively copy srcDir into dstDir, creating directories as needed.
copyAssets :: FilePath -> FilePath -> IO ()
copyAssets srcDir dstDir = do
  createDirectoryIfMissing True dstDir
  entries <- listDirectory srcDir
  forM_ entries $ \name -> do
    let src = srcDir </> name
        dst = dstDir </> name
    isFile <- doesFileExist src
    if isFile
      then copyFileWithMetadata src dst
      else copyAssets src dst
