{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import System.Environment (lookupEnv)
import Network.HTTP.Types (status201)
import Web.Scotty
import Domain
import API

main :: IO ()
main = do
  pool <- initPool

  sPort  <- fromMaybe 3000 . (>>= readMaybe) <$> lookupEnv "SERVER_PORT"
  putStrLn $ "Starting server on port " ++ show sPort
  scotty sPort $ do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

    get "/widgets" $ do
      (liftIO $ runAPI pool listWidgets) >>= json

    put "/widgets" $ do
      c <- jsonData :: ActionM CreateWidget
      now <- liftIO getZonedTime
      widget <- liftIO $ runAPI pool $ createWidget $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
      status status201
      json widget
