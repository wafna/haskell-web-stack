module Main where

import Control.Monad.IO.Class (liftIO)
import System.Environment (getArgs)
import Data.Text (pack)
import Domain.Widget
import Util
import Database
import API

-- Instantiates and uses the API.
main :: IO ()
main = do
    args <- getArgs
    pool <- initPool
    if null args
        then putStrLn "No widgets specified."
        else doStuff pool $ do
            mapM_ (createWidget . CreateWidget . pack) args
    putStrLn "Widgets!"
    doStuff pool $ do
        w1 <- listWidgets
        sequence_ $ fmap (\(i,w) -> (liftIO . writeLine) [show i, " ", show w]) (zip [(1 :: Int)..] w1)

doStuff :: ConnPool -> API a -> IO ()
doStuff pool f = do
    res <- runAPI pool f
    case res of
        Left err -> putStrLn $ "Error: " ++ show err
        Right _ -> return ()