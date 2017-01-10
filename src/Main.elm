module Main exposing (..)

import App exposing (..)
import Html exposing (program)
import Navigation


main =
    Navigation.program UrlChange
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
