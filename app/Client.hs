{-# LANGUAGE OverloadedStrings #-}

module Main where

import System.Environment (getArgs)
import Data.Text (pack)
import Network.HTTP.Simple
import Domain.Widget
import Util

main :: IO ()
main = do
    helloRequest
    args <- getArgs
    if null args
        then putStrLn "No widgets specified."
        else mapM_ createWidgetRequest args
    putStrLn "Widgets!"
    listWidgetsRequest

helloRequest :: IO ()
helloRequest = do
    request <- parseRequest "GET http://localhost:3000/"
    response <- httpLBS request
    let body = getResponseBody response
    writeLine ["RESPONSE: ", show body]
    return ()

createWidgetRequest :: String -> IO ()
createWidgetRequest name = do
    let body = CreateWidget (pack name)
    request <- parseRequest "PUT http://localhost:3000/widgets"
    let request' = setRequestBodyJSON body request
    widget <- httpJSON request' :: IO (Response Widget)
    writeLine  ["Created: ", show widget]
    return ()

listWidgetsRequest :: IO ()
listWidgetsRequest = do
    request <- parseRequest "GET http://localhost:3000/widgets"
    response <- httpJSON request :: IO (Response [Widget])
    let widgets = getResponseBody response
    sequence_ $ fmap (\(i, w) -> writeLine [show i, " ", show w]) $ zip [(1 :: Int)..] widgets
