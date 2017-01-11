port module Ports exposing (watchDom, newUrl)


port watchDom : Bool -> Cmd msg

port newUrl : (String -> msg) -> Sub msg
