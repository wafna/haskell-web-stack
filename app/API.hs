{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module API where

import Data.Pool
import Control.Monad.Reader
import Control.Monad.IO.Unlift
import Database.PostgreSQL.Simple
import Domain
import Database

newtype API a = API { unAPI :: ReaderT ConnPool IO a }
    deriving (Functor, Applicative, Monad, MonadIO, MonadReader ConnPool, MonadUnliftIO)

runAPI :: ConnPool -> API a -> IO a
runAPI pool (API m) = runReaderT m pool

listWidgets :: API [Widget]
listWidgets = API $ do
    pool <- ask
    liftIO $ withResource pool $ \conn -> do
        query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]

createWidget :: WidgetWip -> API Widget
createWidget wip = API $ do
    widget <- liftIO $ fromWip wip
    pool <- ask
    liftIO $ withResource pool $ \conn -> do
        _ <- execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" widget
        return widget
