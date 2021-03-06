{-# LANGUAGE OverloadedStrings #-}

import           Control.Exception              ( evaluate )
import qualified Data.Text                     as T
import           KDL                            ( document
                                                , parse
                                                )
import           System.Directory               ( doesFileExist
                                                , getDirectoryContents
                                                )
import           System.FilePath                ( (</>) )
import           Test.Hspec                     ( SpecWith
                                                , describe
                                                , hspec
                                                , it
                                                , parallel
                                                , runIO
                                                , shouldBe
                                                )
import           Test.QuickCheck                ( )

testCase :: FilePath -> FilePath -> SpecWith ()
testCase input expected = do
  describe "KDL.parseKDL" $ do
    it ("should satisfy " ++ input) $ do
      inputFile     <- T.pack <$> readFile input
      shouldSucceed <- doesFileExist expected
      case parse document input inputFile of
        Left  _ -> shouldSucceed `shouldBe` False
        Right d -> do
          expectedFile <- readFile expected
          show d `shouldBe` expectedFile

inputDir :: FilePath
inputDir = "kdl/tests/test_cases/input"

expectedDir :: FilePath
expectedDir = "kdl/tests/test_cases/expected_kdl"

main :: IO ()
main = hspec $ do
  parallel $ do
    describe "should pass the kdl-org provided test cases" $ do
      files_ <- runIO $ getDirectoryContents inputDir
      let files         = filter (`notElem` [".", ".."]) files_
      let inputFiles    = map (inputDir </>) files
      let expectedFiles = map (expectedDir </>) files
      let testCases     = zipWith testCase inputFiles expectedFiles
      sequence_ testCases
