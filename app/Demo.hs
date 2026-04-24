module Main where

import Control.Monad.IO.Class (liftIO)
import System.Environment (getArgs)
import Data.Text (pack)
import Data.Time (getCurrentTime)
import Data.Time.LocalTime (utcToLocalTime, getCurrentTimeZone)
import Domain
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
        else do
            res <- runAPI pool $ do
                now <- liftIO getCurrentTime
                tz <- liftIO getCurrentTimeZone
                let localNow = utcToLocalTime tz now
                mapM_ (\name -> createWidget (WidgetWip (pack name) localNow)) args

                liftIO $ putStrLn "Widgets!"
                w1 <- listWidgets
                sequence_ $ fmap (\(i,w) -> (liftIO . writeLine) [show i, " ", show w]) (zip [(1 :: Int)..] w1)
            case res of
                Left err -> putStrLn $ "Error: " ++ show err
                Right _ -> return ()
