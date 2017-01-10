module App exposing (..)

import Html exposing (Html, text, div, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Navigation
import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top, string)
import PageOne
import PageTwo
import PageThree
import PageFour
import HomePage
import Ports exposing (watchDom)


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
    | PageThree
    | PageFour Int


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map HomePage top
        , Url.map PageOne (s "pageone")
        , Url.map PageTwo (s "pagetwo")
        , Url.map PageThree (s "pagethree")
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
            (List.map menuItem [ "", "pageone", "pagetwo", "pagethree", "pagefour/1234" ])
        , (case model.route of
            Nothing ->
                div [] [ text "we don't have a route selected" ]

            Just r ->
                case r of
                    HomePage ->
                        HomePage.view

                    PageOne ->
                        PageOne.view

                    PageTwo ->
                        PageTwo.view

                    PageThree ->
                        PageThree.view

                    PageFour id ->
                        PageFour.view id
          )
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
