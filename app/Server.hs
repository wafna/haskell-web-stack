{-# LANGUAGE OverloadedStrings #-}

module Server (runServer, app, runAPIOrThrow) where

import Network.HTTP.Types (status201)
import Web.Scotty.Trans (scottyOptsT, Options(..), defaultOptions, ActionT, get, put, text, json, jsonData, status)
import Network.Wai.Handler.Warp (setPort, setHost)
import Control.Monad.Trans.Class (lift)
import Data.String (fromString)
import Control.Exception (throwIO)
import Database
import Domain.Widget
import API
import Util

type Action = ActionT API

-- Exposes the API over HTTP.
runServer :: IO ()
runServer = do
  pool <- initPool
  port  <- envInt "SERVER_PORT" 3000
  host  <- envString "SERVER_HOST" "0.0.0.0"
  putStrLn $ "Starting server on " ++ host ++ ":" ++ show port

  let warpSettings = setPort port
                   $ setHost (fromString host)
                   $ settings defaultOptions

  scottyOptsT (defaultOptions { settings = warpSettings }) (runAPIOrThrow pool) (app pool)

app pool = do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

    get "/widgets" $ do
      lift listWidgets >>= json

    put "/widgets" $ do
      c <- jsonData :: Action CreateWidget
      widget <- lift $ createWidget c
      status status201
      json widget

runAPIOrThrow :: ConnPool -> API a -> IO a
runAPIOrThrow pool m = do
  res <- runAPI pool m
  case res of
    Left err -> throwIO err
    Right a  -> return a
