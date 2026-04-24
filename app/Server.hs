{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import System.Environment (lookupEnv)
import Network.HTTP.Types (status201)
import Web.Scotty (get, put, text, json, jsonData, status)
import Web.Scotty.Trans (scottyT)
import Control.Monad (liftM)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Class (lift)
import Database
import Domain
import API
import Web.Scotty.Trans (ActionT)

type Action = ActionT API

main :: IO ()
main = do
  pool <- initPool

  sPort  <- fromMaybe 3000 . (>>= readMaybe) <$> lookupEnv "SERVER_PORT"
  putStrLn $ "Starting server on port " ++ show sPort
  scottyT sPort (runAPI pool) $ do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

--    get "/widgets" $ do
--      widgets <- lift listWidgets
--      json widgets
--
--    put "/widgets" $ do
--      c <- jsonData :: Action CreateWidget
--      now <- liftIO getZonedTime
--      widget <- lift $ createWidget $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
--      status status201
--      json widget
