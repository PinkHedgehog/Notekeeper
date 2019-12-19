{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Main where

import Web.Spock
import Web.Spock.Config
import Web.Spock.Lucid (lucid)
import Lucid
import Lucid.Base
import Lib
import Data.Text (Text, pack)
import Data.IORef
import Control.Monad (forM, msum, forM_)
import Control.Monad.IO.Class (liftIO)

import           Data.Aeson       hiding (json)
import           Data.Aeson.Types (parseMaybe)
import           Data.Monoid      ((<>))
import           GHC.Generics
import           Control.Monad.Logger    (LoggingT, runStdoutLoggingT)
import           Database.Persist        hiding (get) -- To avoid a naming clash with Web.Spock.get
import qualified Database.Persist        as P         -- We'll be using P.get later for GET /people/<id>.
import           Database.Persist.Sqlite hiding (get)
import           Database.Persist.TH

type Server a = SpockM SqlBackend () ServerState a

newtype ServerState = ServerState {styleSheet :: Text}

-- data Note = Note { author :: Text, contents :: Text } deriving (Generic, Show)
--
-- instance ToJSON Note
--
-- instance FromJSON From

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Note
    author Text
    contents Text
    deriving Show
|]

type ApiAction a = SpockAction SqlBackend () ServerState a
{-
maybePerson <- jsonBody :: ApiAction (Maybe Person)
    case maybePerson of
      Nothing -> errorJson 1 "Failed to parse request body as Person"
      Just thePerson -> do
        newId <- runSQL $ insert thePerson
        json $ object ["result" .= String "success", "id" .= newId]
-}
errorJson :: Int -> Text -> ApiAction ()
errorJson code message =
    json $
        object
            [ "result" .= String "failure"
            , "error" .= object ["code" .= code, "message" .= message]
            ]
--

runSQL
  :: (HasSpock m, SpockConn m ~ SqlBackend)
  => SqlPersistT (LoggingT IO) a -> m a
runSQL action = runQuery $ \conn -> runStdoutLoggingT $ runSqlConn action conn

parseNote notejson = case parseResult of
    Nothing -> ("Author" :: Text, "Note" :: Text)
    Just x  -> x
    where parseResult = do
            result <- decode notejson
            flip parseMaybe result $ \obj -> do
                auth <- obj .: "age"
                cont <- obj .: "name"
                return (auth, cont)

app :: Server ()
app = do
    get root $ do
        allNotes <- runSQL $ selectList [] [Asc NoteId]
        liftIO $ print allNotes
        styleSheet' <- styleSheet <$> getState
        --json allNotes

---
---
        ----file "kek" "Blog.html"
        lucid $ do
            title_ "Notekeeper"
            style_ [type_ "text/css", src_ "style.css"] $ do
                toHtmlRaw styleSheet'
            --link_ [href_ "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css", rel_ "stylesheet", type_ "text/css"]
--            link_ [href_ "style3.css", rel_ "stylesheet", type_ "text/css"]
            h1_ "Notekeeper"
            div_ [class_ "container mt-5"] $ do
                div_ [class_ "row"] $ do
                    div_ [class_ "col-5"] $ do
                        card
                    div_ [class_ "col-4 offset-1"] $ do
                        h2_ "Notes"

                        -- case allNotes of
                        --     Nothing -> card
                        --     Just notes' -> do
                        forM_ allNotes $ \(Entity _ note) -> renderNote (noteAuthor note) (noteContents note)
---
---
                        --forM_ notes' $ \note -> renderNote (author note) (contents note)
    post root $ do

        auth <- param' "author"
        cont <- param' "contents"

        newId <- runSQL $ insert $ Note auth cont
        liftIO $ print newId
        redirect "/"

--

--https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css


main :: IO ()
main = do
    fileStyle <- pack <$> readFile "style.css"

    pool <- runStdoutLoggingT $ createSqlitePool "api.db" 5
    runStdoutLoggingT $ runSqlPool (do runMigration migrateAll) pool
    let st = ServerState fileStyle
    cfg <- defaultSpockCfg () (PCPool pool) st

    --cfg <- defaultSpockCfg () PCNoDatabase st
    runSpock 8000 (spock cfg app)
