module Evergreen.Migrate.V2 exposing (..)

import Evergreen.Type.V1 as Old
import Evergreen.Type.V2 as New
import Lamdera.Migrations exposing (..)


recreate : Old.Item -> New.Item
recreate o =
    let
        newStatus =
            case o.status of
                Old.Incomplete ->
                    New.Incomplete

                Old.Complete ->
                    New.Complete

                Old.Deleted ->
                    New.Deleted
    in
    { id = o.id
    , name = o.name
    , status = newStatus
    }


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { items = List.map recreate old.items, newItemText = old.newItemText, showDeleted = False }, Cmd.none )


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgUnchanged
