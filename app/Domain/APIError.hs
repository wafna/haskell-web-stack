{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}

module Domain.APIError where

import Data.Text
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)
import qualified Control.Exception as E

data APIError
    = NotFound Text
    | InvalidInput Text
    | InternalError Text
    deriving (Show, Generic, ToJSON, FromJSON)

instance E.Exception APIError

