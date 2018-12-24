module UI.Navigation exposing (Action(..), Icon(..), Label(..), LabelType(..), global, local)

import Chunky exposing (..)
import Color exposing (Color)
import Conditional exposing (..)
import Html exposing (Html, text)
import Html.Attributes exposing (href, style, title)
import Html.Events exposing (onClick)
import List.Extra as List
import String.Format
import Svg exposing (Svg)
import Tachyons.Classes as T
import UI.Kit
import UI.Kit.Classes as C
import UI.Page as Page exposing (Page)



-- 🌳


type Action msg
    = GoToPage Page
    | PerformMsg msg


type Icon msg
    = Icon (Color -> Int -> Svg msg)


type Label
    = Label String LabelType


type LabelType
    = Hidden
    | Shown



-- GLOBAL


global : List ( Page, String ) -> Page -> Html msg
global items activePage =
    block
        [ style "font-size" "11.5px" ]
        [ T.f7
        , T.mb5
        , T.mt4
        , T.tracked
        , T.ttu
        ]
        (List.indexedMap (globalItem activePage <| List.length items) items)


globalItem : Page -> Int -> Int -> ( Page, String ) -> Html msg
globalItem activePage totalItems idx ( page, label ) =
    let
        isActivePage =
            Page.sameBase page activePage

        isLastItem =
            idx + 1 == totalItems
    in
    slab
        Html.a
        [ href (Page.toString page)

        --
        , style "color" (ifThenElse isActivePage globalActiveColor globalDefaultColor)
        , style "border-bottom-color" (ifThenElse isActivePage globalBorderColor "transparent")
        ]
        [ C.textFocus
        , T.dib
        , T.lh_copy
        , T.no_underline
        , T.pointer
        , T.pt2

        --
        , ifThenElse isActivePage T.bb T.bn
        , ifThenElse isLastItem T.mr0 T.mr4
        ]
        [ text label ]


{-| TODO - Wait for avh4/elm-color v1.1.0
-}
globalActiveColor =
    "rgb(65, 50, 63)"


globalDefaultColor =
    "rgba(65, 50, 63, 0.725)"


globalBorderColor =
    "rgba(65, 50, 63, 0.125)"



-- LOCAL


local : List ( Icon msg, Label, Action msg ) -> Html msg
local items =
    block
        [ style "font-size" "12.5px"
        , style "border-bottom-color" localBorderColor
        ]
        [ T.bb, T.flex ]
        (items
            |> List.reverse
            |> List.indexedMap localItem
            |> List.reverse
        )


localItem : Int -> ( Icon msg, Label, Action msg ) -> Html msg
localItem idx ( Icon icon, Label labelText labelType, action ) =
    slab
        (case action of
            GoToPage _ ->
                Html.a

            PerformMsg _ ->
                Html.button
        )
        [ case action of
            GoToPage page ->
                href (Page.toString page)

            PerformMsg msg ->
                onClick msg

        --
        , case labelType of
            Hidden ->
                title labelText

            Shown ->
                title ""

        --
        , style "border-bottom" "1px solid transparent"
        , style "border-right-color" localBorderColor
        , style "border-right-style" "solid"
        , style "border-right-width" (ifThenElse (idx == 0) "0" "1px")
        , style "border-top" "2px solid transparent"
        , style "color" localTextColor
        , style "height" "43px"
        ]
        [ ifThenElse (labelType == Hidden) T.flex_shrink_0 T.flex_grow_1
        , C.navFocus
        , T.bg_transparent
        , T.bl_0
        , T.fw6
        , T.inline_flex
        , T.items_center
        , T.justify_center
        , T.lh_solid
        , T.no_underline
        , T.pointer
        , T.ph3
        ]
        [ icon UI.Kit.colors.text 16

        --
        , case labelType of
            Hidden ->
                empty

            Shown ->
                slab
                    Html.span
                    []
                    [ T.dib, T.ml1 ]
                    [ text labelText ]
        ]


localBorderColor : String
localBorderColor =
    Color.toCssString UI.Kit.colors.subtleBorder


localTextColor : String
localTextColor =
    Color.toCssString UI.Kit.colors.text
