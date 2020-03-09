module Frontend exposing (Model, app)

import Element exposing (Element, column, el, fill, height, padding, px, rgb255, row, spacing, text, width)
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
    ( { newItemText = "", items = [], showDeleted = False }, sendToBackend ClientJoin )


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

                newItems =
                    model.items ++ [ newItem ]
            in
            case String.length newItemName of
                0 ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | newItemText = "", items = newItems }, sendToBackend (PersistItems newItems) )

        AddItemFromButton newItemName ->
            model |> update (AddItem newItemName)

        SetStatus itemId newStatus ->
            let
                boolToStatus bool =
                    if bool then
                        Complete

                    else
                        Incomplete

                updater =
                    \item ->
                        if item.id == itemId then
                            { item | status = boolToStatus newStatus }

                        else
                            item

                updatedItems =
                    List.map updater model.items
            in
            ( { model | items = updatedItems }, sendToBackend (PersistItems updatedItems) )

        DeleteItem itemId ->
            let
                updater =
                    \item ->
                        if item.id == itemId then
                            { item | status = Deleted }

                        else
                            item

                updatedItems =
                    List.map updater model.items
            in
            ( { model | items = updatedItems }, sendToBackend (PersistItems updatedItems) )

        ToggleDeleted ->
            ( { model | showDeleted = not model.showDeleted }, Cmd.none )


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
        , padding 10
        ]
    <|
        column [ spacing 10 ] <|
            [ row [ spacing 10 ]
                [ Input.text
                    [ Font.color (rgb255 0 0 0)
                    , onEnter (AddItem model.newItemText)
                    ]
                    { label = Input.labelHidden "New item"
                    , onChange = \v -> Update v
                    , placeholder = Just (Input.placeholder [] (text "New item..."))
                    , text = model.newItemText
                    }
                , Input.button
                    [ Border.width 1
                    , Border.rounded 3
                    , padding 10
                    ]
                    { onPress = Just (AddItemFromButton model.newItemText), label = text "Add item" }
                , Input.button
                    [ Border.width 1
                    , Border.rounded 3
                    , padding 10
                    ]
                    { onPress = Just ToggleDeleted, label = text "Show deleted" }
                ]
            ]
                ++ itemsView model.showDeleted model.items


statusDisplay : Status -> Bool
statusDisplay status =
    case status of
        Incomplete ->
            False

        _ ->
            True


fontStyle : Status -> List (Element.Attribute FrontendMsg)
fontStyle status =
    case status of
        Incomplete ->
            [ Font.unitalicized ]

        Complete ->
            [ Font.strike ]

        Deleted ->
            [ Font.strike, Font.italic ]


itemsView : Bool -> List Item -> List (Element FrontendMsg)
itemsView showDeleted items =
    if showDeleted then
        items |> List.map itemView

    else
        items
            |> List.filter (\i -> i.status /= Deleted)
            |> List.map itemView


itemView : Item -> Element FrontendMsg
itemView item =
    row [ spacing 10 ]
        [ Input.checkbox []
            { onChange = SetStatus item.id
            , icon = Input.defaultCheckbox
            , checked = statusDisplay item.status
            , label = Input.labelRight (fontStyle item.status) (text item.name)
            }
        , deleteView item
        ]


deleteView : Item -> Element FrontendMsg
deleteView item =
    case item.status of
        Complete ->
            Input.button [] { onPress = Just (DeleteItem item.id), label = text "[x]" }

        _ ->
            Element.none
