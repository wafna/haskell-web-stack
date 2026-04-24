module Util where

writeLine :: [String] -> IO ()
writeLine ss = do
  sequence_ $ fmap putStr ss
  putStrLn ""
