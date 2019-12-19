{-# LANGUAGE OverloadedStrings #-}
module Lib where

--import Web.Spock.Lucid (lucid)
import Lucid
import Data.Text
import Data.Semigroup ((<>))

renderNote :: Text -> Text -> Html ()
renderNote author contents = do
    div_ [class_ "alert alert-info"] $ do
        div_ [class_ "row"] $ do
            div_ [class_ "col-8"] $ do
                b_ "Author: " <> toHtml author <> br_ []
                b_ "Contents: " <> toHtml contents <> br_ []
                -- <b>Город: </b>{{ info.city }}<br>
                -- <b>Температура: </b>{{ info.temp }} <sup>0</sup> <br>
            -- </div>
            -- <div class="col-2 offset-1">
                -- <img src="http://openweathermap.org/img/w/{{ info.icon }}.png" alt="">
            -- </div>
--        </div>
--    </div>

card :: Html ()
card = do
    --style_ [src_ "style3.css"] ("" :: Text)
    --link_ [href_ "https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css", rel_ "stylesheet", type_ "text/css"]
    div_ [class_ "card-deck mb-3 text-center"] $ do
        div_ [class_ "card mb-4 shadow-sm"] $ do
            div_ [class_ "card-header"] $ do
                h4_ [class_ "my-0 font-weight-normal"] "New note"
            div_ [class_ "card-body"] $ do
                form_ [action_ "", method_ "post"] $ do
                    label_ $ do
                        "Author: "
                        br_ []
                        input_ [name_ "author", class_ "input-field"]
                    br_ []
                    label_ $ do
                        "Contents: "
                        br_ []
                        input_ [name_ "contents", class_ "input-field"]
                    br_ []
                    input_ [type_ "submit", value_ "Add Note", class_ "mt-2 btn btn-danger"]
                --button_ [type_ "button", class_ "btn btn-lg btn-block btn-primary"] $ "Contact us"
    {-
 - <div class="card mb-4 shadow-sm">
                    <div class="card-header">
                        <h4 class="my-0 font-weight-normal">Enterprise</h4>
                    </div>
                    <div class="card-body">
                        <h1 class="card-title pricing-card-title">$29 <small class="text-muted">/ mo</small></h1>
                        <ul class="list-unstyled mt-3 mb-4">
                            <li>30 users included</li>
                            <li>15 GB of storage</li>
                            <li>Phone and email support</li>
                            <li>Help center access</li>
                        </ul>
                        <button type="button" class="btn btn-lg btn-block btn-primary">Contact us</button>
                    </div>
                </div>

-}

someFunc :: IO ()
someFunc = putStrLn "someFunc"
