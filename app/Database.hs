{-# LANGUAGE DeriveGeneric #-}

module Database where

import Data.Pool
import GHC.Generics
import Database.PostgreSQL.Simple

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

