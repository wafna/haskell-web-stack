{-# LANGUAGE OverloadedStrings #-}

module Database where

import Data.Pool
import GHC.Int
import Database.PostgreSQL.Simple
import Util
import Domain.Widget

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

listWidgets_ :: Connection -> IO [Widget]
listWidgets_ conn =
    query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]

insertWidget_ :: Widget -> Connection -> IO Int64
insertWidget_ widget conn =
    execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" widget