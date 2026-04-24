{-# LANGUAGE OverloadedStrings #-}

module Main where

import System.Environment (getArgs)
import Data.Text (pack)
import Network.HTTP.Simple
import Domain.Widget
import Util

main :: IO ()
main = do
    args <- getArgs
    if null args
        then putStrLn "No widgets specified."
        else do
            mapM_ createWidgetRequest args
    
    putStrLn "Widgets!"
    listWidgetsRequest

createWidgetRequest :: String -> IO ()
createWidgetRequest name = do
    let body = CreateWidget (pack name)
    request <- parseRequest "PUT http://localhost:3000/widgets"
    let request' = setRequestBodyJSON body request
    _ <- httpJSON request' :: IO (Response Widget)
    return ()

listWidgetsRequest :: IO ()
listWidgetsRequest = do
    request <- parseRequest "GET http://localhost:3000/widgets"
    response <- httpJSON request :: IO (Response [Widget])
    let widgets = getResponseBody response
    sequence_ $ fmap (\(i, w) -> writeLine [show i, " ", show w]) (zip [(1 :: Int)..] widgets)
