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
import           GHC.Generics
import           Control.Monad.Logger    (LoggingT, runStdoutLoggingT)
import           Database.Persist        hiding (get) -- To avoid a naming clash with Web.Spock.get
import qualified Database.Persist        as P         -- We'll be using P.get later for GET /people/<id>.
import           Database.Persist.Sqlite hiding (get)
import           Database.Persist.TH

type Server a = SpockM () () ServerState a

newtype ServerState = ServerState { notes :: IORef ([Note], Text)}

-- data Note = Note { author :: Text, contents :: Text } deriving (Generic, Show)
--
-- instance ToJSON Note
--
-- instance FromJSON From

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Note json -- The json keyword will make Persistent generate sensible ToJSON and FromJSON instances for us.
  name Text
  age Int
  deriving Show
|]

app :: Server ()
app = do
    get root $ do
        ref' <- getState >>= (liftIO . readIORef . notes)
        let notes' = fst ref'
            styleSheet' = snd ref'
        -- file "kek" "Blog.html"
        lucid $ do
            title_ "Notekeeper"
            style_ [type_ "text/css", src_ styleSheet'] $ do
                toHtmlRaw styleSheet'
            --link_ [href_ "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css", rel_ "stylesheet", type_ "text/css"]
--            link_ [href_ "style3.css", rel_ "stylesheet", type_ "text/css"]
            h1_ "Notekeeper"
            div_ [class_ "container mt-5"] $ do
                div_ [class_ "row"] $ do
                    div_ [class_ "col-5"] $ do
                        h1_ "Hew Note"
                        form_ [action_ "", method_ "post"] $ do
                            label_ $ do
                                "Author: "
                                input_ [name_ "author", class_ "input-field"]
                            label_ $ do
                                "Contents: "
                                input_ [name_ "contents", class_ "input-field"]
                            br_ []
                            input_ [type_ "submit", value_ "Add Note", class_ "mt-2 btn btn-danger"]
                    div_ [class_ "col-4 offset-1"] $ do
                        h2_ "Notes"
                        forM_ notes' $ \note -> renderNote (author note) (contents note)

                        --forM_ notes' $ \note -> renderNote (author note) (contents note)
    post root $ do
        author <- param' "author"
        contents <- param' "contents"
        notesRef <- notes <$> getState
        liftIO $ atomicModifyIORef' notesRef $ \(notes, x)  -> ((notes ++ [Note author contents], x), ())
        redirect "/"
            -- li_ $ do
            --     toHtml (author note)
            --     ": "
            --     toHtml (contents note)
            --
            --h2_ "New note"
            --form_ [method_ "post"] $ do
            --card

--https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css
main :: IO ()
main = do
    fileStyle <- pack <$> readFile "style.css"
    myRef <- newIORef ([ Note "Alice" "Must not forget to walk the dog"
                      , Note "Bob" "Must. Eat. Pizza!"
                      ], fileStyle)
    let st = ServerState myRef
    cfg <- defaultSpockCfg () PCNoDatabase st
    runSpock 8000 (spock cfg app)
