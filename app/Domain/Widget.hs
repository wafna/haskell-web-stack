{-# LANGUAGE DeriveAnyClass #-}

module Domain.Widget where

import Data.Text (Text)
import Data.Time (LocalTime)
import Data.UUID (UUID)
import Data.UUID.V4 (nextRandom)
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)
import Database.PostgreSQL.Simple (FromRow, ToRow)

data Widget = Widget
  { widgetId  :: UUID
  , name      :: Text
  , createdAt :: LocalTime
  , deletedAt :: Maybe LocalTime
  } deriving (Show, Generic, ToJSON, FromJSON)

instance FromRow Widget
instance ToRow Widget

data WidgetWip = WidgetWip Text LocalTime

instance Wip WidgetWip where
    fromWip :: WidgetWip -> IO Widget
    fromWip (WidgetWip name createdAt) = do
      uuid <- nextRandom
      return $ Widget uuid name createdAt Nothing

data CreateWidget = CreateWidget
    { createWidgetName :: Text
    }   deriving (Show, Generic, ToJSON, FromJSON)
