module Evergreen.Type.V1 exposing (..)

import Lamdera exposing (ClientId)
import Set exposing (Set)


type Status
    = Incomplete
    | Complete
    | Deleted


type alias ItemId =
    Int


type alias Item =
    { id : ItemId
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
    | AddItemFromButton String
    | SetStatus ItemId Bool
    | DeleteItem ItemId


type ToBackend
    = ClientJoin
    | PersistItems (List Item)


type BackendMsg
    = Noop


type ToFrontend
    = ItemsNewValue (List Item)
