{-# LANGUAGE ImplicitParams #-}

module Website where

import Control.Concurrent.Async (mapConcurrently)
import Control.Exception (SomeException, try)
import Data.IORef
import Data.Map.Strict qualified as Map
import Options.Applicative
import System.Exit (exitFailure)
import System.Process (callProcess)
import Website.Assets (copyAssets)
import Website.Config (SiteConfig (..), loadConfig)
import Website.Context (mkCtx)
import Website.Discover (collectPosts)
import Website.I18n (buildI18nJs)
import Website.New (NewOpts (..), runNew)
import Website.Pages.About (buildAboutPages)
import Website.Pages.Index (buildIndexHtml)
import Website.Pages.Listing (buildListingPages)
import Website.Pages.NotFound (build404)
import Website.Pages.Single (buildSingle)
import Website.Pages.Tag (buildTagPages)
import Website.Post (Frontmatter (..), Post (..), PostKind (..), postUrl, parsePost)
import Website.Search (buildIndex)
import Website.Style (buildStyleCss)
import Website.Theme (buildThemeCss, gruvboxDark, gruvboxLight)
import Website.Watch (runDevServer)

-- CLI 
data Command
  = Build
  | Watch {watchPort :: Int}
  | New NewOpts

cli :: Parser Command
cli =
  subparser
    ( command "build" (info (pure Build) (progDesc "Build the site"))
        <> command "watch" (info watchCmd (progDesc "Dev server with live reload"))
        <> command "new" (info (New <$> newCmd) (progDesc "Scaffold a new post"))
    )
 where
  watchCmd =
    Watch
      <$> option
        auto
        ( long "port"
            <> short 'p'
            <> value 8080
            <> metavar "PORT"
            <> help "Port for dev server (default: 8080)"
        )

  newCmd =
    NewOpts
      <$> option
        (eitherReader parseKind)
        ( long "kind"
            <> short 'k'
            <> value Article
            <> metavar "KIND"
            <> help "post, note, or project (default: post)"
        )
      <*> strOption
        ( long "title"
            <> short 't'
            <> metavar "TITLE"
            <> help "Post title"
        )
      <*> strOption
        ( long "lang"
            <> short 'l'
            <> value "en"
            <> metavar "LANG"
            <> help "Language code (default: en)"
        )
      <*> many
        ( strOption
            ( long "tag"
                <> metavar "TAG"
                <> help "Tag (repeatable)"
            )
        )
      <*> optional
        ( strOption
            ( long "summary"
                <> short 's'
                <> metavar "TEXT"
                <> help "Short summary"
            )
        )
      <*> switch (long "draft" <> help "Mark as draft")
      <*> switch (long "toc" <> help "Generate table of contents")

  parseKind "post" = Right Article
  parseKind "article" = Right Article
  parseKind "note" = Right Note
  parseKind "project" = Right Project
  parseKind s = Left $ "unknown kind '" <> s <> "' — use post, note, or project"

-- Build 
runBuild :: IO ()
runBuild = do
  cfg <- loadConfig "config.yaml"

  postPaths <- collectPosts (cfgPostsDir cfg)
  notePaths <- collectPosts (cfgNotesDir cfg)
  projectPaths <- collectPosts (cfgProjectsDir cfg)

  errors <- newIORef ([] :: [String])

  let tryParse kind path = do
        result <- try @SomeException (parsePost kind path)
        case result of
          Left err -> modifyIORef errors (show err :) >> pure Nothing
          Right p -> pure (Just p)

  articles <- mapConcurrently (tryParse Article) postPaths
  notes <- mapConcurrently (tryParse Note) notePaths
  projects <- mapConcurrently (tryParse Project) projectPaths

  let allContent = [p | Just p <- articles <> notes <> projects, not p.postFrontmatter.fmDraft]
      translationMap =
        Map.fromListWith
          Map.union
          [ (p.postSlug, Map.singleton p.postFrontmatter.fmLang (postUrl p))
          | p <- allContent
          ]
  let ?ctx = mkCtx cfg translationMap

  _ <- mapConcurrently (buildSingle (cfgOutputDir cfg)) allContent

  buildIndex (cfgOutputDir cfg) allContent
  buildIndexHtml (cfgOutputDir cfg) allContent
  buildTagPages (cfgOutputDir cfg) allContent
  buildListingPages (cfgOutputDir cfg) allContent
  buildAboutPages (cfgOutputDir cfg)
  build404 (cfgOutputDir cfg)
  copyAssets (cfgAssetsDir cfg) (cfgOutputDir cfg)
  buildThemeCss (cfgOutputDir cfg) gruvboxDark gruvboxLight
  buildStyleCss (cfgOutputDir cfg)
  callProcess "tsc" ["--project", "tsconfig.json"]
  buildI18nJs (cfgOutputDir cfg) (cfgDefaultLang cfg)

  errs <- readIORef errors
  mapM_ (\e -> putStrLn $ "ERROR: " <> e) errs
  if null errs
    then putStrLn $ "Built " <> show (length allContent) <> " posts."
    else exitFailure

run :: IO ()
run = do
  cmd <- execParser (info (cli <**> helper) fullDesc)
  case cmd of
    Build -> runBuild
    Watch port -> do
      cfg <- loadConfig "config.yaml"
      runDevServer port (cfgOutputDir cfg) runBuild
    New opts -> runNew opts
