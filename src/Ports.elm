port module Ports exposing (..)


port watchDom : Bool -> Cmd msg


port newUrl : (String -> msg) -> Sub msg
