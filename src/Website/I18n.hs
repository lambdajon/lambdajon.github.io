module Website.I18n (buildI18nJs) where

import Data.Aeson (encode)
import Data.ByteString.Lazy qualified as BL
import Data.Map.Strict (Map)
import Data.Text (Text)
import Data.Text.Encoding qualified as TE
import Data.Text.IO qualified as TIO
import Data.Yaml qualified as Y
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))

buildI18nJs :: FilePath -> Text -> IO ()
buildI18nJs outDir defaultLang = do
  dict <- Y.decodeFileThrow "i18n.yaml" :: IO (Map Text (Map Text Text))
  let json = TE.decodeUtf8 (BL.toStrict (encode dict))
      js =
        "const i18n = "
          <> json
          <> ";\n"
          <> "const siteDefaultLang = \""
          <> defaultLang
          <> "\";\n"
  createDirectoryIfMissing True (outDir </> "js")
  TIO.writeFile (outDir </> "js" </> "i18n.js") js
  putStrLn "i18n: wrote /js/i18n.js"
