module PageThree exposing (..)

import Html exposing (Html, text, div, button, h1)
import Html.Events exposing (onClick)


view guid =
    h1 
        [] 
        [ text ("Page Three (Elm) " ++ guid) ]
