{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Main where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import Data.Pool
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import System.Environment (lookupEnv)
import GHC.Generics
import Database.PostgreSQL.Simple
import Network.HTTP.Types (status201)
import Web.Scotty
import Domain

data DBConfig = DBConfig
  { host     :: String
  , port     :: Int
  , user     :: String
  , password :: String
  , database :: String
  } deriving (Show, Generic)

-- Initialize the connection pool
initPool :: DBConfig -> IO (Pool Connection)
initPool cfg = 
  let connInfo = ConnectInfo 
        { connectHost     = host cfg
        , connectPort     = fromIntegral (port cfg)
        , connectUser     = user cfg
        , connectPassword = password cfg
        , connectDatabase = database cfg
        }
  in newPool $ defaultPoolConfig (connect connInfo) close 0.5 10

main :: IO ()
main = do
  dbHost <- fromMaybe "localhost" <$> lookupEnv "DB_HOST"
  dbPort <- fromMaybe 3001 . (>>= readMaybe) <$> lookupEnv "DB_PORT"
  dbUser <- fromMaybe "username" <$> lookupEnv "DB_USER"
  dbPass <- fromMaybe "password" <$> lookupEnv "DB_PASSWORD"
  dbName <- fromMaybe "web_hs" <$> lookupEnv "DB_DATABASE"
  sPort  <- fromMaybe 3000 . (>>= readMaybe) <$> lookupEnv "SERVER_PORT"

  sequence_ $ fmap putStr ["Connecting to database ", dbName, " at ", dbHost, ":", show dbPort]
  putStrLn ""

  let dbCfg = DBConfig dbHost dbPort dbUser dbPass dbName
  pool <- initPool dbCfg

  putStrLn $ "Starting server on port " ++ show sPort
  scotty sPort $ do
    get "/" $ do
      text "Haskell HTTP server and PostgreSQL database."

    get "/widgets" $ do
      -- Example usage of the pool
      widgets <- liftIO $ withResource pool $ \conn -> do
        query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]
      json widgets

    put "/widgets" $ do
      c <- jsonData :: ActionM CreateWidget
      now <- liftIO getZonedTime
      widget <- liftIO $ fromWip $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
      r <- liftIO $ withResource pool $ \conn -> do
        execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" widget
      (liftIO . putStrLn) $ show r
      status status201
      json widget
