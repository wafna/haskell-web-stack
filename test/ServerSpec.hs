{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module ServerSpec (spec) where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON
import qualified Data.ByteString.Lazy as BL
import qualified Data.ByteString as BS
import Network.Wai (Application)
import Web.Scotty.Trans (scottyAppT, defaultOptions)
import Server (app, runAPIOrThrow)
import Database (initPool)
import Docker (startDatabase, stopDatabase)

spec :: Spec
spec = beforeAll_ startDatabase $ afterAll_ stopDatabase $ with testApp $ do
    describe "GET /" $ do
        it "responds with 200" $ do
            get "/" `shouldRespondWith` 200
        it "responds with correct text" $ do
            get "/" `shouldRespondWith` "Haskell HTTP server and PostgreSQL database."

    describe "GET /widgets" $ do
        it "responds with empty list initially" $ do
            get "/widgets" `shouldRespondWith` [json|[]|]

    describe "PUT /widgets" $ do
        it "creates a widget" $ do
            put "/widgets" [json|{"createWidgetName": "Test Widget"}|] `shouldRespondWith` 201

    describe "GET /widgets after creation" $ do
        it "contains the created widget" $ do
            put "/widgets" [json|{"createWidgetName": "Unique Widget"}|] `shouldRespondWith` 201
            get "/widgets" `shouldRespondWith` 200 { matchBody = MatchBody $ \_ body ->
                if "Unique Widget" `BS.isInfixOf` (BL.toStrict body)
                then Nothing
                else Just "Created widget not found in list"
            }

testApp :: IO Application
testApp = do
    pool <- initPool
    scottyAppT defaultOptions (runAPIOrThrow pool) (app pool)
