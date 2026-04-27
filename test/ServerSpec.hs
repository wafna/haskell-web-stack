{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module ServerSpec (spec) where

import Test.Hspec
import Test.Hspec.Wai
import Network.Wai (Application)
import Web.Scotty.Trans (scottyAppT, defaultOptions)
import Server (app, runAPIOrThrow)
import Database (ConnPool)

-- Mocking the pool as something that will fail if actually used for DB
-- For truly "unit" tests of the server logic that doesn't reach the DB,
-- we'd need to mock the API monad or the database functions.
-- Since the current architecture uses `lift listWidgets` directly,
-- it's hard to mock without changing the type of `app` or using a real test DB.

-- For now, let's see if we can at least test the "/" route which doesn't use the DB.

spec :: Spec
spec = with (testApp) $ do
    describe "GET /" $ do
        it "responds with 200" $ do
            get "/" `shouldRespondWith` 200
        it "responds with correct text" $ do
            get "/" `shouldRespondWith` "Haskell HTTP server and PostgreSQL database."

    describe "GET /non-existent" $ do
        it "responds with 404" $ do
            get "/non-existent" `shouldRespondWith` 404

testApp :: IO Application
testApp = do
    -- We pass undefined or a dummy pool because "/" doesn't use it.
    -- If we test other routes, we'll need a way to mock the DB.
    let pool = undefined :: ConnPool
    scottyAppT defaultOptions (runAPIOrThrow pool) (app pool)
