{-# LANGUAGE OverloadedStrings #-}

module Database (
    ConnPool, initPool,
    ) where

import Data.Pool
import Database.PostgreSQL.Simple
import Util

type ConnPool = Pool Connection

initPool :: IO ConnPool
initPool = do
    host <- envString "DB_HOST" "localhost"
    port <- envInt "DB_PORT" 3001
    username <- envString "DB_USER" "username"
    password <- envString "DB_PASSWORD" "password"
    database <- envString "DB_DATABASE" "web_hs"
    writeLine ["Connecting to database ", database, "@", host, ":", show port]
    let connInfo = ConnectInfo host (fromIntegral port) username password database
    newPool $ defaultPoolConfig (connect connInfo) close 0.5 10

