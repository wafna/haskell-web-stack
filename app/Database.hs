{-# LANGUAGE OverloadedStrings #-}

module Database (
    ConnPool, initPool,
    ) where

import System.Environment (lookupEnv)
import Data.Word
import Data.Maybe (fromMaybe)
import Text.Read (readMaybe)
import Data.Pool
import Database.PostgreSQL.Simple
import Util

type ConnPool = Pool Connection

initPool :: IO ConnPool
initPool = do
    host <- fromMaybe "localhost" <$> lookupEnv "DB_HOST"
    port <- fromMaybe (3001 :: Word16) . (>>= readMaybe) <$> lookupEnv "DB_PORT"
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

