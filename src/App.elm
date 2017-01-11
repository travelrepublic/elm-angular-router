module App exposing (..)

import Html exposing (Html, text, div, button, h1)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Navigation
import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top, string, custom)
import PageOne
import PageTwo
import PageThree
import PageFour
import HomePage
import Ports exposing (watchDom)
import Regex as R
import Ports exposing (newUrl)


type alias Model =
    { route : Maybe Route
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    urlChanged (Model Nothing) location


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Navigation.Location


type Route
    = HomePage
    | PageOne
    | PageTwo
    | PageThree String
    | PageFour Int

guidRegex =
    R.regex "^[\\w]{8}-[\\w]{4}-[\\w]{4}-[\\w]{4}-[\\w]{12}$"


regexParser regex =
    custom "REGEX" 
        (\s ->
            if R.contains regex s then
                Ok s
            else 
                Err "String does not match supplied regex")


guidParser =
    regexParser guidRegex



route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map HomePage top
        , Url.map PageOne (s "pageone")
        , Url.map PageTwo (s "pagetwo")
        , Url.map PageThree (s "pagethree" </> guidParser) 
        , Url.map PageFour (s "pagefour" </> int)
        ]


urlChanged model location =
    let
        r =
            Url.parsePath route location

        compile =
            case r of
                Just PageTwo ->
                    False

                Just (PageThree _) ->
                    False     

                _ ->
                    True
    in
        ( { model | route = r }
        , (watchDom compile)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewUrl url ->
            ( model
            , Navigation.newUrl url
            )

        UrlChange location ->
            urlChanged model location


menuItem address =
    button
        [ class "menu-item"
        , onClick (NewUrl ("/" ++ address))
        ]
        [ text
            (if address == "" then
                "home"
             else
                address
            )
        ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            (List.map menuItem 
                [ ""
                , "pageone"
                , "pagetwo"
                , "pagethree/d210716c-fe26-483d-abe1-b4dd5b8ecb1f"
                , "pagethree/not-a-valid-guid"
                , "pagefour/1234" ])
        , (case model.route of
            Nothing ->
                h1 [class "invalid"] [ text "Invalid route" ]

            Just r ->
                case r of
                    HomePage ->
                        HomePage.view

                    PageOne ->
                        PageOne.view

                    PageTwo ->
                        PageTwo.view

                    PageThree guid ->
                        PageThree.view guid

                    PageFour id ->
                        PageFour.view id
          )
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    newUrl NewUrl
