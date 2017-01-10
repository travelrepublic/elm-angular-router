module App exposing (..)

import Html exposing (Html, text, div, button)
import Html.Events exposing (onClick)
import Navigation
import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top, string)
import PageOne
import PageTwo
import PageThree
import HomePage
import Ports exposing (watchDom)


type alias Model =
    { route : Maybe Route
    }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( Model (Url.parsePath route location)
    , (watchDom "")
    )


type Msg
    = NoOp
    | NewUrl String
    | UrlChange Navigation.Location


type Route
    = HomePage
    | PageOne
    | PageTwo
    | PageThree


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map HomePage top
        , Url.map PageOne (s "pageone")
        , Url.map PageTwo (s "pagetwo")
        , Url.map PageThree (s "pagethree")
        ]


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
            ( { model | route = Url.parsePath route location }
            , (watchDom "")
            )


menuItem address =
    button
        [ onClick (NewUrl address) ]
        [ text address ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            (List.map menuItem [ "/", "pageone", "pagetwo", "pagethree" ])
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
          )
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
