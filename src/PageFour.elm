module PageFour exposing (..)

import Html exposing (Html, text, div, button, node)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)


view id =
    node "page-four"
        [ attribute "custom-id" (toString id) ]
        []
