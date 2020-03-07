module Types exposing (..)

import Lamdera exposing (ClientId)
import Set exposing (Set)


type Status
    = Incomplete
    | Complete


type alias Item =
    { id : Int
    , name : String
    , status : Status
    }


type alias BackendModel =
    { clients : Set ClientId
    , items : List Item
    }


type alias FrontendModel =
    { newItemText : String
    , items : List Item
    }


type FrontendMsg
    = FNoop
    | Update String
    | AddItem String
    | AddItemFromEnterKey String


type ToBackend
    = ClientJoin


type BackendMsg
    = Noop


type ToFrontend
    = ItemsNewValue (List Item)
