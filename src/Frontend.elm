module Frontend exposing (Model, app)

import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Lamdera exposing (sendToBackend)
import Types exposing (..)

import Element exposing (Element, el, text, row, column, alignRight, fill, width, rgb255, spacing, centerY, padding)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


type alias Model =
    FrontendModel


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "v1"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
    ( { counter = 0, clientId = "" }, sendToBackend ClientJoin )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

        Decrement ->
            ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        FNoop ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        CounterNewValue newValue clientId ->
            ( { model | counter = newValue, clientId = clientId }, Cmd.none )


view : Model -> Html FrontendMsg
view model =
    Element.layout
        [ Background.color (rgb255 15 15 15)
        , Font.color (rgb255 255 255 255)
        , Border.rounded 3
        , padding 30
        ]
        <| column [] [
            row []
            [ Input.button [padding 30] { onPress = Just Increment, label = text "+" }
            , el [] ( text (String.fromInt model.counter))
            , Input.button [padding 30] { onPress = Just Decrement, label = text "-" }
            , el [] (text "Click me then refresh me!")
            ]
            ,row [] [

            el [] (text <| "Last message from: " ++ model.clientId)
            ]
        ]
