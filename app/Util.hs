{-# LANGUAGE OverloadedStrings #-}

module Util where

import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)

writeLine :: [String] -> IO ()
writeLine ss = do
  sequence_ $ fmap putStr ss
  putStrLn ""

envString :: String -> String -> IO String
envString key def = fromMaybe def <$> lookupEnv key

envInt :: String -> Int -> IO Int
envInt key def = fromMaybe def . (>>= readMaybe) <$> lookupEnv key