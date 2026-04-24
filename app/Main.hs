{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import System.Environment (lookupEnv)
import Network.HTTP.Types (status201)
import Web.Scotty
import Domain
import Database
import Util

main :: IO ()
main = do
  dbHost <- fromMaybe "localhost" <$> lookupEnv "DB_HOST"
  dbPort <- fromMaybe 3001 . (>>= readMaybe) <$> lookupEnv "DB_PORT"
  dbUser <- fromMaybe "username" <$> lookupEnv "DB_USER"
  dbPass <- fromMaybe "password" <$> lookupEnv "DB_PASSWORD"
  dbName <- fromMaybe "web_hs" <$> lookupEnv "DB_DATABASE"
  sPort  <- fromMaybe 3000 . (>>= readMaybe) <$> lookupEnv "SERVER_PORT"
  writeLine ["Connecting to database ", dbName, "@", dbHost, ":", show dbPort]
  pool <- initPool $ DBConfig dbHost dbPort dbUser dbPass dbName

  putStrLn $ "Starting server on port " ++ show sPort
  scotty sPort $ do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

    get "/widgets" $ do
      (liftIO $ listWidgets pool) >>= json

    put "/widgets" $ do
      c <- jsonData :: ActionM CreateWidget
      now <- liftIO getZonedTime
      widget <- liftIO $ fromWip $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
      _ <- liftIO $ createWidget pool widget
      status status201
      json widget
