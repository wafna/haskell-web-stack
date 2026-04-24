{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module API (
    API, runAPI,
    listWidgets, createWidget
) where

import System.IO
import Data.Pool
import Control.Monad.Reader
import Control.Monad.Except
import Control.Monad.IO.Unlift
import qualified Control.Exception as E
import Data.Text (pack)
import Database.PostgreSQL.Simple
import Domain
import Database

newtype API a = API { unAPI :: ReaderT ConnPool IO a }
    deriving (Functor, Applicative, Monad, MonadIO, MonadReader ConnPool, MonadUnliftIO)

instance MonadError APIError API where
    throwError = liftIO . E.throwIO
    catchError (API m) h = API $ ReaderT $ \pool ->
        E.catch (runReaderT m pool) (\e -> runReaderT (unAPI $ h e) pool)

runAPI :: ConnPool -> API a -> IO (Either APIError a)
runAPI pool (API m) = E.try $ runReaderT m pool

withErrorHandling :: API a -> API a
withErrorHandling (API m) = API $ ReaderT $ \pool ->
    E.catch (runReaderT m pool) $ \e -> do
        hPutStrLn stderr $ "API Error: " ++ show (e :: E.SomeException)
        E.throwIO $ InternalError $ pack $ show (e :: E.SomeException)

listWidgets :: API [Widget]
listWidgets = withErrorHandling $ API $ do
    pool <- ask
    liftIO $ withResource pool $ \conn -> do
        query_ conn "SELECT id, name, created_at, deleted_at FROM web_hs.widgets" :: IO [Widget]

createWidget :: WidgetWip -> API Widget
createWidget wip = withErrorHandling $ API $ do
    widget <- liftIO $ fromWip wip
    pool <- ask
    liftIO $ withResource pool $ \conn -> do
        _ <- execute conn "INSERT INTO web_hs.widgets (id, name, created_at, deleted_at) VALUES (?, ?, ?, ?)" widget
        return widget
