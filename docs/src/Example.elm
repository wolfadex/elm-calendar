module Example exposing (main)

import Browser
import Calendar
import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import List.Extra
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
    , customMonthHeader : Bool
    , today : Date
    , selectedDate : Date
    , period : Date
    , scope : Calendar.Scope
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { customDayOfMonth = False
      , customWeekdayHeader = False
      , customMonthHeader = False
      , today = Date.fromCalendarDate 2024 Time.Feb 22
      , selectedDate = Date.fromCalendarDate 2024 Time.Feb 22
      , period = Date.fromCalendarDate 2024 Time.Feb 22
      , scope = Calendar.Month
      }
    , Date.today
        |> Task.perform CurrentDateReceived
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = CurrentDateReceived Date
    | UserClickedDate Date
    | UserClickedCustomDayOfMonth
    | UserClickedCustomWeekdayHeader
    | UserClickedCustomMonthHeader
    | UserClickedPreviousPeriod
    | UserClickedNextPeriod
    | UserClickedTodayPeriod
    | UserClickedScope Calendar.Scope


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CurrentDateReceived today ->
            ( { model
                | today = today
                , selectedDate = today
                , period = today
              }
            , Cmd.none
            )

        UserClickedDate date ->
            ( { model | period = date, selectedDate = date }
            , Cmd.none
            )

        UserClickedPreviousPeriod ->
            ( { model
                | period =
                    case model.scope of
                        Calendar.Year ->
                            Date.add Date.Years -1 model.period

                        Calendar.Month ->
                            Date.add Date.Months -1 model.period

                        Calendar.Week ->
                            Date.add Date.Weeks -1 model.period

                        Calendar.Day ->
                            Date.add Date.Days -1 model.period
              }
            , Cmd.none
            )

        UserClickedNextPeriod ->
            ( { model
                | period =
                    case model.scope of
                        Calendar.Year ->
                            Date.add Date.Years 1 model.period

                        Calendar.Month ->
                            Date.add Date.Months 1 model.period

                        Calendar.Week ->
                            Date.add Date.Weeks 1 model.period

                        Calendar.Day ->
                            Date.add Date.Days 1 model.period
              }
            , Cmd.none
            )

        UserClickedTodayPeriod ->
            ( { model | period = model.today, selectedDate = model.today }
            , Cmd.none
            )

        UserClickedScope scope ->
            ( { model | scope = scope }
            , Cmd.none
            )

        UserClickedCustomDayOfMonth ->
            ( { model | customDayOfMonth = not model.customDayOfMonth }
            , Cmd.none
            )

        UserClickedCustomWeekdayHeader ->
            ( { model | customWeekdayHeader = not model.customWeekdayHeader }, Cmd.none )

        UserClickedCustomMonthHeader ->
            ( { model | customMonthHeader = not model.customMonthHeader }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Example Calendar"
    , body =
        [ Html.h1 [] [ Html.text "Elm Calendar" ]
        , Html.div
            [ Html.Attributes.style "display" "flex"
            ]
            [ Html.div
                [ Html.Attributes.style "display" "grid"
                , Html.Attributes.style "gap" "1rem"
                , Html.Attributes.style "grid-template-columns" "1fr auto 1fr"
                , Html.Attributes.style "width" "100%"
                ]
                [ Html.div
                    [ Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "gap" "2rem"
                    , Html.Attributes.style "align-items" "center"
                    ]
                    [ viewButtonGroup
                        []
                        [ { label = "Previous"
                          , onClick = UserClickedPreviousPeriod
                          , attributes = []
                          }
                        , { label = "Next"
                          , onClick = UserClickedNextPeriod
                          , attributes = []
                          }
                        ]
                    , viewToggleButton
                        { label = "Today"
                        , onClick = UserClickedTodayPeriod
                        , active = model.selectedDate == model.today
                        }
                    ]
                , Html.h1 [ Html.Attributes.style "text-align" "center" ] <|
                    case model.scope of
                        Calendar.Year ->
                            [ model.period
                                |> Date.year
                                |> String.fromInt
                                |> Html.text
                            ]

                        Calendar.Month ->
                            let
                                month =
                                    model.period
                                        |> Date.month
                                        |> monthToLabel
                            in
                            [ (month ++ " " ++ String.fromInt (Date.year model.period))
                                |> Html.text
                            ]

                        Calendar.Week ->
                            let
                                ( startDate, endDate ) =
                                    Calendar.weekBounds Time.Sun model.period

                                startYear =
                                    Date.year startDate

                                endYear =
                                    Date.year endDate

                                startMonth =
                                    Date.month startDate

                                endMonth =
                                    Date.month endDate

                                startDay =
                                    Date.day startDate
                                        |> Date.withOrdinalSuffix

                                endDay =
                                    Date.day endDate
                                        |> Date.withOrdinalSuffix
                            in
                            [ (monthToShortLabel startMonth
                                ++ " "
                                ++ startDay
                                ++ (if startYear == endYear then
                                        ""

                                    else
                                        ", " ++ String.fromInt startYear
                                   )
                              )
                                |> Html.text
                            , Html.text " — "
                            , ((if startMonth == endMonth then
                                    ""

                                else
                                    monthToShortLabel endMonth
                               )
                                ++ " "
                                ++ endDay
                                ++ ", "
                                ++ String.fromInt endYear
                              )
                                |> Html.text
                            ]

                        Calendar.Day ->
                            let
                                year =
                                    model.period
                                        |> Date.year
                                        |> String.fromInt

                                month =
                                    model.period
                                        |> Date.month
                                        |> monthToLabel

                                day =
                                    model.period
                                        |> Date.day
                                        |> Date.withOrdinalSuffix
                            in
                            [ (year ++ " " ++ month ++ " " ++ day)
                                |> Html.text
                            ]
                , viewButtonGroup
                    [ Html.Attributes.style "justify-content" "flex-end"
                    ]
                    [ { label = "Year"
                      , onClick = UserClickedScope Calendar.Year
                      , attributes =
                            case model.scope of
                                Calendar.Year ->
                                    [ Html.Attributes.style "background-color" "cornflowerblue"
                                    , Html.Attributes.style "color" "white"
                                    ]

                                _ ->
                                    []
                      }
                    , { label = "Month"
                      , onClick = UserClickedScope Calendar.Month
                      , attributes =
                            case model.scope of
                                Calendar.Month ->
                                    [ Html.Attributes.style "background-color" "cornflowerblue"
                                    , Html.Attributes.style "color" "white"
                                    ]

                                _ ->
                                    []
                      }
                    , { label = "Week"
                      , onClick = UserClickedScope Calendar.Week
                      , attributes =
                            case model.scope of
                                Calendar.Week ->
                                    [ Html.Attributes.style "background-color" "cornflowerblue"
                                    , Html.Attributes.style "color" "white"
                                    ]

                                _ ->
                                    []
                      }
                    , { label = "Day"
                      , onClick = UserClickedScope Calendar.Day
                      , attributes =
                            case model.scope of
                                Calendar.Day ->
                                    [ Html.Attributes.style "background-color" "cornflowerblue"
                                    , Html.Attributes.style "color" "white"
                                    ]

                                _ ->
                                    []
                      }
                    ]
                ]
            ]
        , Calendar.new
            { period = model.period
            , scope = model.scope
            }
            |> applyIf model.customDayOfMonth (Calendar.withViewDayOfMonth (viewDayOfMonthCustom model.selectedDate))
            |> applyIf model.customDayOfMonth (Calendar.withViewDayOfMonthOfYear (viewDayOfMonthOfYearCustom model.selectedDate))
            |> applyIf model.customWeekdayHeader (Calendar.withViewWeekdayHeader viewWeekdayHeaderCustom)
            |> applyIf model.customMonthHeader (Calendar.withViewMonthHeader (viewMonthHeaderCustom model.selectedDate))
            |> Calendar.withWeekStartsOn Time.Sun
            |> Calendar.withViewMultiDayEvent (viewCustomEvent model.period)
            |> Calendar.view
            |> (\cal ->
                    let
                        wrapper c =
                            Html.div
                                [ Html.Attributes.style "max-height" "70vh"
                                , Html.Attributes.style "overflow" "auto"
                                , Html.Attributes.style "border" "3px solid black"
                                ]
                                [ c ]
                    in
                    case model.scope of
                        Calendar.Year ->
                            wrapper cal

                        Calendar.Month ->
                            wrapper cal

                        Calendar.Week ->
                            cal

                        Calendar.Day ->
                            cal
               )
        , Html.br [] []
        , Html.div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "gap" "1rem"
            ]
            [ viewToggleButton
                { label =
                    if model.customDayOfMonth then
                        "Default day of month view"

                    else
                        "Custom day of month view"
                , onClick = UserClickedCustomDayOfMonth
                , active = model.customDayOfMonth
                }
            , viewToggleButton
                { label =
                    if model.customWeekdayHeader then
                        "Default weekday header view"

                    else
                        "Custom weekday header view"
                , onClick = UserClickedCustomWeekdayHeader
                , active = model.customWeekdayHeader
                }
            , viewToggleButton
                { label =
                    if model.customMonthHeader then
                        "Default month header view"

                    else
                        "Custom month header view"
                , onClick = UserClickedCustomMonthHeader
                , active = model.customMonthHeader
                }
            ]
        ]
    }


shortEvent =
    { title = "Short Event"
    , filter = \period day -> Date.month day == Date.month period && Date.day day >= 3 && Date.day day <= 5
    , color = "coral"
    }


longEvent =
    { title = "Long Event"
    , filter = \period day -> Date.month day == Date.month period && Date.day day >= 15 && Date.day day <= 29
    , color = "aqua"
    }


events =
    [ shortEvent, longEvent ]


viewCustomEvent : Date -> List ( String, Html Msg )
viewCustomEvent focalPeriod =
    List.concatMap
        (viewEvent focalPeriod)
        events


viewEvent : Date -> { title : String, filter : Date -> Date -> Bool, color : String } -> List ( String, Html Msg )
viewEvent focalPeriod event =
    let
        ( start, end ) =
            Calendar.calendarMonthBounds Time.Sun focalPeriod

        rowsAndColumns : List { row : Int, columnStart : Int, columnEnd : Int }
        rowsAndColumns =
            Date.range Date.Day 1 start end
                |> List.filter (event.filter focalPeriod)
                |> List.map (Calendar.toRowAndColumn Time.Sun)
                |> List.sortBy .row
                |> List.Extra.groupWhile (\a b -> a.row == b.row)
                |> List.map
                    (\( first, rest ) ->
                        let
                            columns =
                                (first :: rest)
                                    |> List.map .column
                        in
                        { row = first.row
                        , columnStart =
                            columns
                                |> List.minimum
                                |> Maybe.withDefault first.column
                        , columnEnd =
                            columns
                                |> List.maximum
                                |> Maybe.withDefault first.column
                        }
                    )

        rowCount =
            List.length rowsAndColumns

        beginingStyles =
            [ Html.Attributes.style "border-top-left-radius" "0.25rem"
            , Html.Attributes.style "border-bottom-left-radius" "0.25rem"
            , Html.Attributes.style "margin-left" "5px"
            ]

        middleEndStyles =
            [ Html.Attributes.style "border-right-width" "0"
            , Html.Attributes.style "margin-right" "1px"
            ]

        middleStartStyles =
            [ Html.Attributes.style "border-left-width" "0"
            , Html.Attributes.style "margin-left" "1px"
            ]

        endingStyles =
            [ Html.Attributes.style "border-top-right-radius" "0.25rem"
            , Html.Attributes.style "border-bottom-right-radius" "0.25rem"
            , Html.Attributes.style "margin-right" "5px"
            ]
    in
    List.indexedMap
        (\index { row, columnStart, columnEnd } ->
            ( event.title
            , Html.div
                ([ Html.Attributes.style "background" event.color
                 , Html.Attributes.style "padding" "0.25rem 0.5rem"
                 , Html.Attributes.style "grid-row" (String.fromInt row)
                 , Html.Attributes.style "grid-column" (String.fromInt columnStart ++ " / " ++ String.fromInt (columnEnd + 1))
                 , Html.Attributes.style "margin-top" "2rem"
                 , Html.Attributes.style "margin-bottom" "3px"
                 , Html.Attributes.style "border-style" "solid"
                 , Html.Attributes.style "border-color" event.color
                 , Html.Attributes.style "border-width" "2px"
                 ]
                    ++ (if index == 0 then
                            beginingStyles

                        else
                            []
                       )
                    ++ (if index == rowCount - 1 then
                            endingStyles

                        else
                            []
                       )
                    ++ (if index > 0 && index < rowCount - 1 then
                            middleEndStyles ++ middleStartStyles

                        else
                            []
                       )
                    ++ (if index == 0 && index < rowCount - 1 then
                            middleEndStyles

                        else
                            []
                       )
                    ++ (if index == rowCount - 1 && index > 0 then
                            middleStartStyles

                        else
                            []
                       )
                )
                [ Html.text event.title ]
            )
        )
        rowsAndColumns


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


monthToShortLabel : Time.Month -> String
monthToShortLabel month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"



-- Custom view functions


viewDayOfMonthCustom : Date -> { column : Int, row : Int } -> Date -> Html Msg
viewDayOfMonthCustom today { column, row } date =
    Html.div
        [ Html.Attributes.style "border" "1px solid black"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "min-height" "4rem"
        , Html.Attributes.style "padding" "3px"

        -- These styles help with grid layout and layering events on top of the grid
        , Html.Attributes.style "min-width" "0"
        , Html.Attributes.style "grid-column" (String.fromInt column)
        , Html.Attributes.style "grid-row" (String.fromInt row)
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
                    , Html.Events.onClick (UserClickedDate date)
                    , Html.Attributes.style "cursor" "pointer"
                    ]
                )
                [ Html.text (String.fromInt (Date.day date))
                ]
            ]
        , if Date.day date == 7 then
            Html.div
                [ Html.Attributes.style "background" "#fffb00"
                , Html.Attributes.style "padding" "0.25rem 0.5rem"
                , Html.Attributes.style "border-radius" "0.25rem"
                , Html.Attributes.style "border" "2px solid #fffb00"
                ]
                [ Html.text "Special event!" ]

          else
            Html.text ""
        ]


viewDayOfMonthOfYearCustom : Date -> Time.Month -> Date -> Html Msg
viewDayOfMonthOfYearCustom today month date =
    if Date.month date == month then
        Html.div
            [ Html.Attributes.style "border" "1px solid black"
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "min-height" "4rem"
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
                        , Html.Events.onClick (UserClickedDate date)
                        , Html.Attributes.style "cursor" "pointer"
                        ]
                    )
                    [ Html.text (String.fromInt (Date.day date))
                    ]
                ]
            , if Date.day date == 7 then
                Html.div
                    [ Html.Attributes.style "background" "#fffb00"
                    , Html.Attributes.style "padding" "0.25rem 0.5rem"
                    , Html.Attributes.style "border-radius" "0.25rem"
                    , Html.Attributes.style "border" "2px solid #fffb00"
                    ]
                    [ Html.text "Special event!" ]

              else
                Html.text ""
            ]

    else
        Html.div
            [ Html.Attributes.style "border" "1px solid black"
            , Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "background" "#ffe5b6"
            ]
            []


viewWeekdayHeaderCustom : Int -> Time.Weekday -> Html Msg
viewWeekdayHeaderCustom columnIndex weekday =
    Html.div
        [ Html.Attributes.style "width" "100%"
        , Html.Attributes.style "text-align" "center"
        , Html.Attributes.style "text-decoration" "underline"
        ]
        [ Html.span
            []
            [ Html.text (weekdayToFullLabel weekday)
            ]
        ]


viewMonthHeaderCustom : Date -> Time.Month -> Html Msg
viewMonthHeaderCustom today month =
    Html.h2
        [ Html.Attributes.style "text-align" "center"
        , if Date.month today == month then
            Html.Attributes.style "text-decoration" "underline"

          else
            Html.Attributes.class ""
        , if Date.month today == month then
            Html.Attributes.style "color" "cornflowerblue"

          else
            Html.Attributes.class ""
        ]
        [ Html.span
            []
            [ Html.text (monthToLabel month) ]
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


viewButtonGroup : List (Html.Attribute msg) -> List { label : String, onClick : msg, attributes : List (Html.Attribute msg) } -> Html msg
viewButtonGroup attributes buttons =
    Html.div
        ([ Html.Attributes.style "display" "flex"
         , Html.Attributes.style "align-items" "center"
         ]
            ++ attributes
        )
        (case buttons of
            [] ->
                []

            [ only ] ->
                [ Html.button
                    ([ Html.Attributes.style "border-radius" "0.5rem"
                     , Html.Attributes.style "padding" "0.25rem 0.5rem"
                     , Html.Events.onClick only.onClick
                     ]
                        ++ only.attributes
                    )
                    [ Html.text only.label ]
                ]

            first :: rest ->
                List.concat
                    [ [ Html.button
                            ([ Html.Attributes.style "border-top-right-radius" "0"
                             , Html.Attributes.style "border-bottom-right-radius" "0"
                             , Html.Attributes.style "border-top-left-radius" "0.5rem"
                             , Html.Attributes.style "border-bottom-left-radius" "0.5rem"
                             , Html.Attributes.style "padding" "0.25rem 0.5rem"
                             , Html.Events.onClick first.onClick
                             ]
                                ++ first.attributes
                            )
                            [ Html.text first.label ]
                      ]
                    , case List.reverse rest of
                        [] ->
                            []

                        last :: middle ->
                            List.reverse
                                (Html.button
                                    ([ Html.Attributes.style "border-top-left-radius" "0"
                                     , Html.Attributes.style "border-bottom-left-radius" "0"
                                     , Html.Attributes.style "border-top-right-radius" "0.5rem"
                                     , Html.Attributes.style "border-bottom-right-radius" "0.5rem"
                                     , Html.Attributes.style "padding" "0.25rem 0.5rem"
                                     , Html.Events.onClick last.onClick
                                     ]
                                        ++ last.attributes
                                    )
                                    [ Html.text last.label ]
                                    :: List.map
                                        (\button ->
                                            Html.button
                                                ([ Html.Attributes.style "border-radius" "0"
                                                 , Html.Attributes.style "padding" "0.25rem 0.5rem"
                                                 , Html.Events.onClick button.onClick
                                                 ]
                                                    ++ button.attributes
                                                )
                                                [ Html.text button.label ]
                                        )
                                        middle
                                )
                    ]
        )


viewToggleButton : { label : String, onClick : msg, active : Bool } -> Html msg
viewToggleButton options =
    Html.button
        (buttonStyles
            ++ [ Html.Events.onClick options.onClick
               , if options.active then
                    Html.Attributes.style "background-color" "cornflowerblue"

                 else
                    Html.Attributes.class ""
               , if options.active then
                    Html.Attributes.style "color" "white"

                 else
                    Html.Attributes.class ""
               ]
        )
        [ Html.text options.label ]


buttonStyles : List (Html.Attribute msg)
buttonStyles =
    [ Html.Attributes.style "border-radius" "0.5rem"
    , Html.Attributes.style "padding" "0.25rem 0.5rem"
    ]



-- Utilty - Basics


applyIf : Bool -> (a -> a) -> a -> a
applyIf condition f x =
    if condition then
        f x

    else
        x
