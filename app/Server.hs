{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import Network.HTTP.Types (status201)
import Web.Scotty.Trans (scottyT, ActionT, get, put, text, json, jsonData, status)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Class (lift)
import Control.Exception (throwIO)
import Database
import Domain
import API
import Util

type Action = ActionT API

-- Exposes the API over HTTP.
main :: IO ()
main = do
  pool <- initPool
  port  <- envInt "SERVER_PORT" 3000
  putStrLn $ "Starting server on port " ++ show port
  scottyT (fromIntegral port) (runAPIOrThrow pool) $ do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

    get "/widgets" $ do
      widgets <- lift listWidgets
      json widgets

    put "/widgets" $ do
      c <- jsonData :: Action CreateWidget
      now <- liftIO getZonedTime
      widget <- lift $ createWidget $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
      status status201
      json widget

runAPIOrThrow :: ConnPool -> API a -> IO a
runAPIOrThrow pool m = do
  res <- runAPI pool m
  case res of
    Left err -> throwIO err
    Right a  -> return a
