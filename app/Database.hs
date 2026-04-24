{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Database where

import Data.Pool
import GHC.Generics
import Database.PostgreSQL.Simple
import Domain

data DBConfig = DBConfig
  { host     :: String
  , port     :: Int
  , user     :: String
  , password :: String
  , database :: String
  } deriving (Show, Generic)

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

listWidgets :: Pool Connection -> IO [Widget]
listWidgets pool = withResource pool $ \conn -> do
    query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]

createWidget :: Pool Connection -> Widget -> IO Int
createWidget pool wip = withResource pool $ \conn -> do
    i <- execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" wip
    return $ fromIntegral i