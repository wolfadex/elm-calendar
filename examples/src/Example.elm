module Example exposing (main)

import Browser
import Calendar
import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Task
import Time


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { customDayOfMonth : Bool
    , customWeekdayHeader : Bool
    , today : Date
    , scope : Calendar.Scope
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { customDayOfMonth = False
      , customWeekdayHeader = False
      , today = Date.fromCalendarDate 2024 Time.Feb 22
      , scope = Calendar.Month
      }
    , Date.today
        |> Task.perform CurrentDateReceived
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = UserClickedCustomDayOfMonth
    | UserClickedCustomWeekdayHeader
    | CurrentDateReceived Date
    | UserClickedPreviousPeriod
    | UserClickedNextPeriod


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CurrentDateReceived today ->
            ( { model | today = today }
            , Cmd.none
            )

        UserClickedPreviousPeriod ->
            ( { model | today = Date.add Date.Months -1 model.today }
            , Cmd.none
            )

        UserClickedNextPeriod ->
            ( { model | today = Date.add Date.Months 1 model.today }
            , Cmd.none
            )

        UserClickedCustomDayOfMonth ->
            ( { model | customDayOfMonth = not model.customDayOfMonth }
            , Cmd.none
            )

        UserClickedCustomWeekdayHeader ->
            ( { model | customWeekdayHeader = not model.customWeekdayHeader }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Example Calendar"
    , body =
        [ Html.div
            [ Html.Attributes.style "display" "flex"
            ]
            [ case model.scope of
                Calendar.Month ->
                    let
                        month =
                            model.today
                                |> Date.month
                                |> monthToLabel
                    in
                    Html.div
                        [ Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "gap" "2rem"
                        ]
                        [ Html.div
                            [ Html.Attributes.style "display" "flex"
                            , Html.Attributes.style "align-items" "center"
                            ]
                            [ Html.button
                                [ Html.Attributes.style "border-top-right-radius" "0"
                                , Html.Attributes.style "border-bottom-right-radius" "0"
                                , Html.Attributes.style "border-top-left-radius" "1rem"
                                , Html.Attributes.style "border-bottom-left-radius" "1rem"
                                , Html.Attributes.style "padding" "0.25rem 0.5rem"
                                , Html.Events.onClick UserClickedPreviousPeriod
                                ]
                                [ Html.text "Previous" ]
                            , Html.button
                                [ Html.Attributes.style "border-top-left-radius" "0"
                                , Html.Attributes.style "border-bottom-left-radius" "0"
                                , Html.Attributes.style "border-top-right-radius" "1rem"
                                , Html.Attributes.style "border-bottom-right-radius" "1rem"
                                , Html.Attributes.style "padding" "0.25rem 0.5rem"
                                , Html.Events.onClick UserClickedNextPeriod
                                ]
                                [ Html.text "Next" ]
                            ]
                        , Html.h1 []
                            [ Html.text <|
                                month
                                    ++ " "
                                    ++ String.fromInt (Date.year model.today)
                            ]
                        ]

                Calendar.Week ->
                    Html.h1 []
                        [ Html.text <| "Week view" ]

                Calendar.Day ->
                    Html.h1 []
                        [ Html.text <| "Day view" ]

                Calendar.Year ->
                    Html.h1 []
                        [ Html.text <| "Year view" ]
            ]
        , Calendar.new
            { period = model.today
            , scope = model.scope
            }
            |> applyIf model.customDayOfMonth (Calendar.withViewDayOfMonth (viewDayOfMonthCustom model.today))
            |> applyIf model.customWeekdayHeader (Calendar.withViewWeekdayHeader viewWeekdayHeaderCustom)
            |> Calendar.view
        , Html.br [] []
        , Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "gap" "1rem"
            ]
            [ Html.button
                [ Html.Events.onClick UserClickedCustomDayOfMonth ]
                [ Html.text <|
                    if model.customDayOfMonth then
                        "Default day of month view"

                    else
                        "Custom day of month view"
                ]
            , Html.button
                [ Html.Events.onClick UserClickedCustomWeekdayHeader ]
                [ Html.text <|
                    if model.customWeekdayHeader then
                        "Default weekday header view"

                    else
                        "Custom weekday header view"
                ]
            ]
        ]
    }


monthToLabel : Time.Month -> String
monthToLabel month =
    case month of
        Time.Jan ->
            "January"

        Time.Feb ->
            "February"

        Time.Mar ->
            "March"

        Time.Apr ->
            "April"

        Time.May ->
            "May"

        Time.Jun ->
            "June"

        Time.Jul ->
            "July"

        Time.Aug ->
            "August"

        Time.Sep ->
            "September"

        Time.Oct ->
            "October"

        Time.Nov ->
            "November"

        Time.Dec ->
            "December"



-- Custom view functions


viewDayOfMonthCustom : Date -> Date -> Html Msg
viewDayOfMonthCustom today date =
    Html.div
        [ Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "padding" "3px"
        ]
        [ Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "justify-content" "flex-end"
            ]
            [ Html.span
                (if date == today then
                    [ Html.Attributes.style "font-weight" "bold"
                    , Html.Attributes.style "background" "cornflowerblue"
                    , Html.Attributes.style "color" "white"
                    , Html.Attributes.style "border-radius" "50%"
                    , Html.Attributes.style "width" "1.5rem"
                    , Html.Attributes.style "height" "1.5rem"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "align-items" "center"
                    ]

                 else
                    [ Html.Attributes.style "border-radius" "50%"
                    , Html.Attributes.style "width" "1.5rem"
                    , Html.Attributes.style "height" "1.5rem"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "align-items" "center"
                    ]
                )
                [ Html.text (String.fromInt (Date.day date))
                ]
            ]
        ]


viewWeekdayHeaderCustom : Time.Weekday -> Html Msg
viewWeekdayHeaderCustom weekday =
    Html.div
        [ Html.Attributes.style "width" "100%"
        , Html.Attributes.style "text-align" "center"
        , Html.Attributes.style "text-decoration" "underline"
        ]
        [ Html.span
            []
            [ Html.text (weekdayToFullLabel weekday) ]
        ]


weekdayToFullLabel : Time.Weekday -> String
weekdayToFullLabel weekday =
    case weekday of
        Time.Mon ->
            "Monday"

        Time.Tue ->
            "Tuesday"

        Time.Wed ->
            "Wednesday"

        Time.Thu ->
            "Thursday"

        Time.Fri ->
            "Friday"

        Time.Sat ->
            "Saturday"

        Time.Sun ->
            "Sunday"



-- Utilty - Basics


applyIf : Bool -> (a -> a) -> a -> a
applyIf condition f x =
    if condition then
        f x

    else
        x
