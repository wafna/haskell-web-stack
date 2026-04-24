{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Database (
    ConnPool, initPool,
    createWidget, listWidgets
    ) where

import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import Data.Pool
import GHC.Generics
import Database.PostgreSQL.Simple
import Util
import Domain

type ConnPool = Pool Connection

initPool :: IO ConnPool
initPool = do
    host <- fromMaybe "localhost" <$> lookupEnv "DB_HOST"
    port <- fromMaybe 3001 . (>>= readMaybe) <$> lookupEnv "DB_PORT"
    database <- fromMaybe "web_hs" <$> lookupEnv "DB_DATABASE"
    username <- fromMaybe "username" <$> lookupEnv "DB_USER"
    password <- fromMaybe "password" <$> lookupEnv "DB_PASSWORD"
    writeLine ["Connecting to database ", database, "@", host, ":", show port]
--    let connInfo = ConnectInfo
--        { connectHost     = host
--        , connectPort     = fromIntegral port
--        , connectUser     = username
--        , connectPassword = password
--        , connectDatabase = database
--        }
    let connInfo = ConnectInfo host (fromIntegral port) username password database
    newPool $ defaultPoolConfig (connect connInfo) close 0.5 10

listWidgets :: Pool Connection -> IO [Widget]
listWidgets pool = withResource pool $ \conn -> do
    query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]

createWidget :: Pool Connection -> Widget -> IO Int
createWidget pool wip = withResource pool $ \conn -> do
    i <- execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" wip
    return $ fromIntegral i
