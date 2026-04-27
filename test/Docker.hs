module Docker (startDatabase, stopDatabase) where

import System.Process (callCommand)
import Control.Concurrent (threadDelay)

startDatabase :: IO ()
startDatabase = do
    putStrLn "Starting database container..."
    callCommand "docker compose -f database/docker-compose.yml up -d"
    putStrLn "Waiting for database to be ready..."
    threadDelay 5000000 -- 5 seconds

stopDatabase :: IO ()
stopDatabase = do
    putStrLn "Stopping database container..."
    callCommand "docker compose -f database/docker-compose.yml down"
