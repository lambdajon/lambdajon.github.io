module Website.Discover (collectPosts) where

import Control.Monad (filterM)
import Data.List (isPrefixOf)
import System.Directory (doesDirectoryExist, doesFileExist, listDirectory)
import System.FilePath (takeExtension, takeFileName, (</>))

{- | Recursively collect all .md files.
| Files starts with '_' are skipped.
-}
collectPosts :: FilePath -> IO [FilePath]
collectPosts dir = do
  exists <- doesDirectoryExist dir
  if not exists then
    pure []
  else do
    entries <- listDirectory dir
    let paths = map (dir </>) entries
    files <- filterM doesFileExist paths
    subdirs <- filterM doesDirectoryExist paths
    let mdFiles = filter isMdFile files
    nested <- mapM collectPosts subdirs
    pure (mdFiles <> concat nested)
 where
  isMdFile p = takeExtension p == ".md" && not ("_" `isPrefixOf` takeFileName p)
