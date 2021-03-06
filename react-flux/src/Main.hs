{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Main where

import React.Flux
import Control.Concurrent( forkIO, threadDelay )
import Control.Monad( replicateM, void, forM_)
import Data.Text(pack, append, Text)
import Data.Time.Clock

import Control.DeepSeq
import GHC.Generics (Generic)
import Data.Typeable (Typeable)
import qualified Data.Text as T

main :: IO ()
main = do
  registerInitialStore $ (TestState [])
  reactRenderView "table-example" testApp

newtype TestState = TestState [Entry] deriving (Show, Typeable)

data TestAction = TestAction
  deriving (Show, Typeable, Generic, NFData)

instance StoreData TestState where
    type StoreAction TestState = TestAction
    transform _ (TestState _) = do
      putStrLn "State transform called"
      return $ TestState table


testApp :: View '[]
testApp = mkControllerView @'[StoreArg TestState] "todo app" $ \(TestState ents) ->
    div_ $ do
      h3_ $ elemString "react-flux ghcjs"
      button_ [onClick $ \_ _ ->  dispatchTest $ TestAction] $ elemString $ "Add rows"
      let colNames = ["a","b","c","d"]
      table_ $ do
        thead_ . tr_ $ forM_ colNames $ \n ->
            th_ (text_ n)
        tbody_ $ forM_ ents $ \Entry{..} -> do
          let cells = [a, b, T.pack.show $ c, T.pack.show $ c]
          tr_. forM_ cells $ \cell -> do
                td_ (elemText cell)

dispatchTest :: TestAction -> [SomeStoreAction]
dispatchTest a = [someStoreAction @TestState a]


data Entry = Entry
  { a :: Text
  , b :: Text
  , c :: Double
  , d :: Int
  } deriving (Show, Typeable)

table :: [Entry]
table = replicate 1000 Entry {a = "Some", b = "Text here", c = 1.23, d = 424242}