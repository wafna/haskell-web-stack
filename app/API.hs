{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module API (
    APIError(..),
    API, runAPI,
    listWidgets, createWidget
) where

import Data.Time (getZonedTime, zonedTimeToLocalTime)
import System.IO
import Data.Pool
import Control.Monad.Reader
import Control.Monad.Except
import Control.Monad.IO.Unlift
import qualified Control.Exception as E
import Data.Text (pack)
import Domain.Widget
import Domain.APIError
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
    runDB listWidgets_

createWidget :: CreateWidget -> API Widget
createWidget c = withErrorHandling $ API $ do
    now <- liftIO getZonedTime
    widget <- liftIO $ fromWip $ WidgetWip (createWidgetName c) (zonedTimeToLocalTime now)
--    widget <- liftIO $ fromWip wip
    _ <- runDB $ insertWidget_ widget
    return widget

runDB :: (MonadReader (Pool a) m, MonadIO m) => (a -> IO b) -> m b
runDB f = do
    pool <- ask
    liftIO $ withResource pool f

