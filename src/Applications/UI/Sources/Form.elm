module UI.Sources.Form exposing (FormStep(..), Model, Msg(..), initialModel, new, takeStepBackwards, takeStepForwards, update)

import Chunky exposing (..)
import Conditional exposing (..)
import Dict.Ext as Dict
import Html exposing (Html, strong, text)
import Html.Attributes exposing (for, name, placeholder, type_, value)
import List.Extra as List
import Material.Icons.Alert as Icons
import Material.Icons.Navigation as Icons
import Sources exposing (..)
import Sources.Services as Services
import Sources.Services.Common
import Tachyons.Classes as T
import UI.Kit exposing (ButtonType(..), select)
import UI.Navigation exposing (..)
import UI.Page as Page



-- 🌳


type alias Model =
    { step : FormStep, context : Source }


type FormStep
    = Where
    | How
    | By


initialModel : Model
initialModel =
    { step = Where, context = defaultContext }


defaultContext : Source
defaultContext =
    { id = "CHANGE_ME_PLEASE"
    , data = Services.initialData defaultService
    , directoryPlaylists = True
    , enabled = True
    , service = defaultService
    }


defaultService : Service
defaultService =
    AmazonS3



-- 📣


type Msg
    = SelectService String
    | TakeStep
    | TakeStepBackwards


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      case msg of
        SelectService serviceKey ->
            case Services.keyToType serviceKey of
                Just service ->
                    let
                        ( context, data ) =
                            ( model.context
                            , Services.initialData service
                            )
                    in
                    { model | context = { context | data = data, service = service } }

                Nothing ->
                    model

        TakeStep ->
            { model | step = takeStepForwards model.step }

        TakeStepBackwards ->
            { model | step = takeStepBackwards model.step }
      -----------------------------------------
      -- Command
      -----------------------------------------
    , Cmd.none
    )


takeStepForwards : FormStep -> FormStep
takeStepForwards currentStep =
    case currentStep of
        Where ->
            How

        _ ->
            By


takeStepBackwards : FormStep -> FormStep
takeStepBackwards currentStep =
    case currentStep of
        By ->
            How

        _ ->
            Where



-- NEW


new : Model -> List (Html Msg)
new model =
    case model.step of
        Where ->
            newWhere model

        How ->
            newHow model

        By ->
            newBy model


newWhere : Model -> List (Html Msg)
newWhere { context } =
    [ -----------------------------------------
      -- Navigation
      -----------------------------------------
      UI.Navigation.local
        [ ( Icon Icons.arrow_back
          , Label "Back to list" Hidden
          , GoToPage (Page.Sources Sources.Index)
          )
        ]

    -----------------------------------------
    -- Content
    -----------------------------------------
    , UI.Kit.centeredContent
        [ UI.Kit.h2 "Where is your music stored?"

        -- Dropdown
        -----------
        , Services.labels
            |> List.map (\( k, l ) -> Html.option [ value k ] [ text l ])
            |> select SelectService
            |> chunky [ T.pv2, T.w_100 ]

        -- Button
        ---------
        , UI.Kit.button
            WithIcon
            TakeStep
            (Icons.arrow_forward UI.Kit.colorKit.accent 17)
        ]
    ]


newHow : Model -> List (Html Msg)
newHow { context } =
    [ -----------------------------------------
      -- Navigation
      -----------------------------------------
      UI.Navigation.local
        [ ( Icon Icons.arrow_back
          , Label "Take a step back" Shown
          , PerformMsg TakeStepBackwards
          )
        ]

    -----------------------------------------
    -- Content
    -----------------------------------------
    , (\a ->
        UI.Kit.centeredContent
            [ chunk
                [ T.w_100 ]
                [ UI.Kit.canister a ]
            ]
      )
        [ UI.Kit.h3 "Where exactly?"

        -- Fields
        ---------
        , let
            properties =
                Services.properties context.service

            dividingPoint =
                toFloat (List.length properties) / 2

            ( listA, listB ) =
                List.splitAt (ceiling dividingPoint) properties
          in
          chunk
            [ T.flex ]
            [ chunk
                [ T.flex_grow_1, T.pr3 ]
                (List.map (renderProperty context) listA)
            , chunk
                [ T.flex_grow_1, T.pl3 ]
                (List.map (renderProperty context) listB)
            ]

        -- Button
        ---------
        , chunk
            [ T.mt3, T.tc ]
            [ UI.Kit.button
                WithIcon
                TakeStep
                (Icons.arrow_forward UI.Kit.colorKit.accent 17)
            ]
        ]
    ]


newBy : Model -> List (Html Msg)
newBy { context } =
    [ -----------------------------------------
      -- Navigation
      -----------------------------------------
      UI.Navigation.local
        [ ( Icon Icons.arrow_back
          , Label "Take a step back" Shown
          , PerformMsg TakeStepBackwards
          )
        ]

    -----------------------------------------
    -- Content
    -----------------------------------------
    , UI.Kit.centeredContent
        [ UI.Kit.h2 "One last thing"
        , UI.Kit.label [] "What are we going to call this source?"

        -- Input
        --------
        , let
            nameValue =
                Dict.fetch "name" "" context.data
          in
          chunk
            [ T.flex, T.mt4, T.justify_center, T.w_100 ]
            [ UI.Kit.textField
                [ name "name"
                , value nameValue
                ]
            ]

        -- Note
        -------
        , chunk
            [ T.f6, T.flex, T.lh_title, T.mt5, T.o_50, T.tc ]
            [ slab
                Html.span
                []
                [ T.mr1 ]
                [ Icons.warning UI.Kit.colors.text 16 ]
            , strong
                []
                [ text "Make sure CORS is enabled" ]
            ]
        , chunk
            [ T.f6, T.lh_title, T.mb5, T.mt2, T.o_50, T.tc ]
            [ text "You can find the instructions over "
            , UI.Kit.link { label = "here", url = "/about#CORS" }
            ]

        -- Button
        ---------
        , UI.Kit.button
            WithText
            TakeStep
            (text "Add source")
        ]
    ]



-- PROPERTIES


renderProperty : Source -> Property -> Html Msg
renderProperty context property =
    chunk
        [ T.mb4 ]
        [ UI.Kit.label [ for property.k ] property.l
        , UI.Kit.textField
            [ name property.k
            , placeholder property.h
            , type_ (ifThenElse property.p "password" "text")
            , value (Dict.fetch property.k "" context.data)
            ]
        ]
