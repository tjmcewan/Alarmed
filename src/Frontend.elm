module Frontend exposing (Model, app)

import Element exposing (Element, column, el, fill, padding, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events as Events
import Http
import Json.Decode as Decode
import Lamdera exposing (sendToBackend)
import Types exposing (..)


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
    ( { newItemText = "", items = [] }, Cmd.none )



-- ( { newItemText = "", items = initialItems }, sendToBackend ClientJoin )


maxId : List Item -> Maybe Int
maxId items =
    items |> List.map .id |> List.maximum


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        FNoop ->
            ( model, Cmd.none )

        Update newItemName ->
            ( { model | newItemText = newItemName }, Cmd.none )

        AddItem newItemName ->
            let
                highId =
                    Maybe.withDefault 0 <| maxId model.items

                newItem =
                    { id = highId + 1
                    , name = newItemName
                    , status = Incomplete
                    }
            in
            ( { model | items = model.items ++ [ newItem ] }, Cmd.none )

        AddItemFromEnterKey newItemName ->
            model |> update (AddItem newItemName)


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        ItemsNewValue newItems ->
            ( { model | items = newItems }, Cmd.none )


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "FNoop"
                    )
            )
        )


view : Model -> Html FrontendMsg
view model =
    Element.layout
        [ Background.color (rgb255 51 51 51)
        , Font.color (rgb255 255 255 255)
        ]
    <|
        column []
            [ row []
                [ Input.button [] { onPress = Just (AddItem model.newItemText), label = text "New" }
                , Input.text
                    [ Font.color (rgb255 0 0 0)
                    , onEnter (AddItemFromEnterKey model.newItemText)
                    ]
                    { label = Input.labelHidden "New item"
                    , onChange = \v -> Update v
                    , placeholder = Just (Input.placeholder [] (text "New item..."))
                    , text = model.newItemText
                    }
                ]
            , row []
                [ Element.table []
                    { data = model.items
                    , columns =
                        [ { header = text "id"
                          , width = fill
                          , view = \item -> text <| String.fromInt item.id
                          }
                        , { header = text "name"
                          , width = fill
                          , view = \item -> text item.name
                          }
                        ]
                    }
                ]
            ]
