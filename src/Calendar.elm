module Calendar exposing
    ( Config, new
    , Scope(..)
    , view
    , withWeekStartsOn
    , with24HourTime
    , withViewDayOfMonth, withViewDayOfMonthOfYear
    , withViewWeekdayHeader
    , withViewMonthHeader
    , withViewDayHeader, withViewDayOfWeekHeader
    , withViewMultiDayEvent
    , weekBounds, calendarMonthBounds
    , toRowAndColumn
    )

{-| A stateless calendar for viewing events or anything else that can be displayed across time.


# Create

@docs Config, new
@docs Scope

@docs view


# Modify the general rendering

@docs withWeekStartsOn
@docs with24HourTime


# Custom viewing

@docs withViewDayOfMonth, withViewDayOfMonthOfYear
@docs withViewWeekdayHeader
@docs withViewMonthHeader
@docs withViewDayHeader, withViewDayOfWeekHeader

@docs withViewMultiDayEvent


# Helpers

@docs weekBounds, calendarMonthBounds
@docs toRowAndColumn

-}

import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes
import Html.Keyed
import Time


{-| Used to describe the "zoom" level of the date data being rendered.
-}
type Scope
    = Day
    | Week
    | Month
    | Year


{-| An opaque type that holds the configuration for rendering the calendar.
-}
type Config msg
    = Config (InternalConfig msg)


type alias InternalConfig msg =
    { -- Minimally required options
      period : Date
    , scope : Scope

    -- Layout options
    , weekStartsOn : Time.Weekday
    , use24HourTime : Bool

    -- Custom rendering
    , viewDayOfMonth : Maybe ({ column : Int, row : Int } -> Date -> Html msg)
    , viewDayOfMonthOfYear : Maybe (Time.Month -> Date -> Html msg)
    , viewWeekdayHeader : Maybe (Int -> Time.Weekday -> Html msg)
    , viewMonthHeader : Maybe (Time.Month -> Html msg)
    , viewDayHeader : Maybe (Time.Weekday -> Html msg)
    , viewDayOfWeekHeader : Maybe (Date -> Html msg)
    , viewMultiDayEvents : Maybe (List ( String, Html msg ))
    }


{-| Start building up a new calendar. The `period` tells us
what year, month, and day we are looking at. The `scope` tells
us which "zoom" level to render the data at.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.view

-}
new : { period : Date, scope : Scope } -> Config msg
new options =
    Config
        { period = options.period
        , scope = options.scope
        , weekStartsOn = Time.Mon
        , use24HourTime = False
        , viewDayOfMonth = Nothing
        , viewDayOfMonthOfYear = Nothing
        , viewWeekdayHeader = Nothing
        , viewMonthHeader = Nothing
        , viewDayHeader = Nothing
        , viewDayOfWeekHeader = Nothing
        , viewMultiDayEvents = Nothing
        }


{-| By default this the week starts on Monday.
Use this function to change it to another day.

    Calendar.new
        { period = Date.fromCalendarDate 2022 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withWeekStartsOn Time.Sun
        |> Calendar.view

-}
withWeekStartsOn : Time.Weekday -> Config msg -> Config msg
withWeekStartsOn weekday (Config options) =
    Config
        { options
            | weekStartsOn = weekday
        }


{-| Instead of AM & PM display times in 24-hour format.

    Calendar.new
        { period = Date.fromCalendarDate 2022 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.with24HourTime
        |> Calendar.view

-}
with24HourTime : Config msg -> Config msg
with24HourTime (Config options) =
    Config
        { options
            | use24HourTime = True
        }


{-| Override the default rendering of the day of the month, for the `Month` scope.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewDayOfMonth
            (\date ->
                Html.text
                    (String.fromInt (Date.day date))
            )
        |> Calendar.view

-}
withViewDayOfMonth : ({ column : Int, row : Int } -> Date -> Html msg) -> Config msg -> Config msg
withViewDayOfMonth viewDayOfMonth (Config options) =
    Config
        { options
            | viewDayOfMonth = Just viewDayOfMonth
        }


{-| Override the default rendering of the day of the month, for the `Year` scope.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewDayOfMonthOfYear
            (\month date ->
                Html.text
                    (String.fromInt (Date.day date))
            )
        |> Calendar.view

-}
withViewDayOfMonthOfYear : (Time.Month -> Date -> Html msg) -> Config msg -> Config msg
withViewDayOfMonthOfYear viewDayOfMonthOfYear (Config options) =
    Config
        { options
            | viewDayOfMonthOfYear = Just viewDayOfMonthOfYear
        }


{-| Override the default rendering of the weekday header of the month.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewWeekdayHeader
            (\weekday ->
                Html.text <|
                    case weekday of
                        Time.Mon ->
                            "M"

                        Time.Tue ->
                            "T"

                        Time.Wed ->
                            "W"

                        Time.Thu ->
                            "T"

                        Time.Fri ->
                            "F"

                        Time.Sat ->
                            "S"

                        Time.Sun ->
                            "S"
            )
        |> Calendar.view

-}
withViewWeekdayHeader : (Int -> Time.Weekday -> Html msg) -> Config msg -> Config msg
withViewWeekdayHeader viewWeekdayHeader (Config options) =
    Config
        { options
            | viewWeekdayHeader = Just viewWeekdayHeader
        }


{-| Override the default rendering of the month header, for the `Year` scope.

    Calendar.new
        { period = Date.fromCalendarDate  2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewMonthHeader
            (\month ->
                case month of
                    Time.Jan ->
                        Html.text "Jan"

                    Time.Feb ->
                        Html.text "Feb"

                    ...
            )
        |> Calendar.view

-}
withViewMonthHeader : (Time.Month -> Html msg) -> Config msg -> Config msg
withViewMonthHeader viewMonthHeader (Config options) =
    Config
        { options
            | viewMonthHeader = Just viewMonthHeader
        }


{-| Override the default rendering of the day header, for the `Day` scope.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewDayHeader
            (\weekday ->
                Html.text <|
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
            )
        |> Calendar.view

-}
withViewDayHeader : (Time.Weekday -> Html msg) -> Config msg -> Config msg
withViewDayHeader viewDayHeader (Config options) =
    Config
        { options
            | viewDayHeader = Just viewDayHeader
        }


{-| Override the default rendering of the day header, for the `Week` scope.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewDayOfWeekHeader
            (\date ->
                date
                    |> Date.day
                    |> String.fromInt
                    |> Html.text
            )
        |> Calendar.view

-}
withViewDayOfWeekHeader : (Date -> Html msg) -> Config msg -> Config msg
withViewDayOfWeekHeader viewDayOfWeekHeader (Config options) =
    Config
        { options
            | viewDayOfWeekHeader = Just viewDayOfWeekHeader
        }


{-| Allows for placing things like multi-day events on the calendar,
spaning across multiple grid cells.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewMultiDayEvent
            [-- Your custom event rendering here
            ]
        |> Calendar.view

-}
withViewMultiDayEvent : List ( String, Html msg ) -> Config msg -> Config msg
withViewMultiDayEvent viewMultiDayEvents (Config options) =
    Config
        { options
            | viewMultiDayEvents = Just viewMultiDayEvents
        }


{-| Renders your `Config` to `Html`.
If you want to customize the rendering,use one of the various `withView...` functions.

    Calendar.new
        { period = Date.fromCalendarDate 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.view

-}
view : Config msg -> Html msg
view (Config options) =
    case options.scope of
        Day ->
            viewDay options

        Week ->
            viewWeek options

        Month ->
            let
                weeks : Int
                weeks =
                    options
                        |> monthDateRange
                        |> List.length
                        |> (\count -> ceiling (toFloat count / 7))
            in
            Html.Keyed.node "div"
                [ Html.Attributes.style "display" "grid"
                , Html.Attributes.style "grid-template-columns" "repeat(7, 1fr)"
                , Html.Attributes.style "grid-template-rows" ("min-content repeat(" ++ String.fromInt weeks ++ ", 1fr)")
                , Html.Attributes.style "width" "100%"
                ]
                (viewDaysOfWeek options
                    ++ viewMonthDays options
                    ++ (case options.viewMultiDayEvents of
                            Just viewMultiDayEvents ->
                                viewMultiDayEvents

                            Nothing ->
                                []
                       )
                )

        Year ->
            allMonths
                |> List.map (viewMonthOfYear options)
                |> Html.div []


viewDay : InternalConfig msg -> Html msg
viewDay options =
    Html.div
        [ Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "auto 1fr"
        , Html.Attributes.style "grid-template-rows" "auto 1fr"
        ]
        [ Html.div [ Html.Attributes.style "border" "1px solid black" ] []
        , case options.viewDayHeader of
            Just viewDayHeader ->
                viewDayHeader (Date.weekday options.period)

            Nothing ->
                Html.div
                    [ Html.Attributes.style "border" "1px solid black"
                    , Html.Attributes.style "border-left-width" "0"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "flex-direction" "column"
                    , Html.Attributes.style "align-items" "center"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "padding" "3px"
                    ]
                    [ options.period
                        |> Date.weekday
                        |> weekdayToLabel
                        |> Html.text
                    ]
        , Html.div
            [ Html.Attributes.style "border" "1px solid black"
            , Html.Attributes.style "border-top-width" "0"
            , Html.Attributes.style "display" "flex"
            , Html.Attributes.style "flex-direction" "column"
            , Html.Attributes.style "align-items" "center"
            , Html.Attributes.style "justify-content" "center"
            , Html.Attributes.style "padding" "3px"
            , Html.Attributes.style "border-bottom-style" "double"
            ]
            [ Html.text "all-day" ]
        , Html.div
            [ Html.Attributes.style "border" "1px solid black"
            , Html.Attributes.style "border-top-width" "0"
            , Html.Attributes.style "border-left-width" "0"
            , Html.Attributes.style "min-height" "3rem"
            , Html.Attributes.style "border-bottom-style" "double"
            ]
            []
        , allHours
            |> List.concatMap (viewHour options)
            |> Html.div
                [ Html.Attributes.style "display" "grid"
                , Html.Attributes.style "grid-template-columns" "subgrid"
                , Html.Attributes.style "grid-column" "1 / 3"
                , Html.Attributes.style "max-height" "40rem"
                , Html.Attributes.style "overflow" "auto"
                ]
        ]


viewWeek : InternalConfig msg -> Html msg
viewWeek options =
    Html.div
        [ Html.Attributes.style "display" "grid"
        , Html.Attributes.style "grid-template-columns" "auto repeat(7, 1fr)"
        , Html.Attributes.style "grid-template-rows" "auto 1fr"
        ]
        (List.concat
            [ [ Html.div [ Html.Attributes.style "border" "1px solid black" ] [] ]
            , let
                ( start, end ) =
                    weekBounds options.weekStartsOn options.period
              in
              Date.range Date.Day 1 start (Date.add Date.Days 1 end)
                |> List.map
                    (\date ->
                        case options.viewDayOfWeekHeader of
                            Just viewDayOfWeekHeader ->
                                viewDayOfWeekHeader date

                            Nothing ->
                                Html.div
                                    [ Html.Attributes.style "border" "1px solid black"
                                    , Html.Attributes.style "border-left-width" "0"
                                    , Html.Attributes.style "display" "flex"
                                    , Html.Attributes.style "flex-direction" "column"
                                    , Html.Attributes.style "align-items" "center"
                                    , Html.Attributes.style "justify-content" "center"
                                    , Html.Attributes.style "padding" "3px"
                                    ]
                                    [ let
                                        weekday =
                                            date
                                                |> Date.weekday
                                                |> weekdayToShortLabel

                                        month =
                                            date
                                                |> Date.monthNumber
                                                |> String.fromInt

                                        day =
                                            date
                                                |> Date.day
                                                |> String.fromInt
                                      in
                                      Html.text (weekday ++ " " ++ month ++ "/" ++ day)
                                    ]
                    )
            , [ Html.div
                    [ Html.Attributes.style "border" "1px solid black"
                    , Html.Attributes.style "border-top-width" "0"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "flex-direction" "column"
                    , Html.Attributes.style "align-items" "center"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "padding" "3px"
                    , Html.Attributes.style "border-bottom-style" "double"
                    ]
                    [ Html.text "all-day" ]
              ]
            , List.range 1 7
                |> List.map
                    (\_ ->
                        Html.div
                            [ Html.Attributes.style "border" "1px solid black"
                            , Html.Attributes.style "border-top-width" "0"
                            , Html.Attributes.style "border-left-width" "0"
                            , Html.Attributes.style "min-height" "3rem"
                            , Html.Attributes.style "border-bottom-style" "double"
                            ]
                            []
                    )
            , [ allHours
                    |> List.concatMap (viewWeekHour options)
                    |> Html.div
                        [ Html.Attributes.style "display" "grid"
                        , Html.Attributes.style "grid-template-columns" "subgrid"
                        , Html.Attributes.style "grid-column" "1 / 9"
                        , Html.Attributes.style "max-height" "40rem"
                        , Html.Attributes.style "overflow" "auto"
                        ]
              ]
            ]
        )


allHours : List Int
allHours =
    List.range 0 23


viewHour : InternalConfig msg -> Int -> List (Html msg)
viewHour options hour =
    [ Html.div
        [ Html.Attributes.style "border-color" "black"
        , Html.Attributes.style "border-style" "solid"
        , Html.Attributes.style "border-width" "1px"
        , Html.Attributes.style "border-top-width" "0"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "flex-direction" "column"
        , Html.Attributes.style "align-items" "flex-end"
        , Html.Attributes.style "justify-content" "flex-start"
        , Html.Attributes.style "padding" "3px"
        ]
        [ Html.text <|
            if options.use24HourTime then
                String.padLeft 2 '0' (String.fromInt hour) ++ ":00"

            else if hour == 0 then
                "12am"

            else if hour < 12 then
                String.fromInt hour ++ "am"

            else if hour == 12 then
                "12pm"

            else
                String.fromInt (hour - 12) ++ "pm"
        ]
    , Html.div
        [ Html.Attributes.style "border-color" "black"
        , Html.Attributes.style "border-style" "solid"
        , Html.Attributes.style "border-width" "1px"
        , Html.Attributes.style "border-top-width" "0"
        , Html.Attributes.style "border-left-width" "0"
        , Html.Attributes.style "min-height" "3rem"
        ]
        []
    ]


viewWeekHour : InternalConfig msg -> Int -> List (Html msg)
viewWeekHour options hour =
    let
        dayHour =
            Html.div
                [ Html.Attributes.style "border-color" "black"
                , Html.Attributes.style "border-style" "solid"
                , Html.Attributes.style "border-width" "1px"
                , Html.Attributes.style "border-top-width" "0"
                , Html.Attributes.style "border-left-width" "0"
                , Html.Attributes.style "min-height" "3rem"
                ]
                []
    in
    [ Html.div
        [ Html.Attributes.style "border-color" "black"
        , Html.Attributes.style "border-style" "solid"
        , Html.Attributes.style "border-width" "1px"
        , Html.Attributes.style "border-top-width" "0"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "flex-direction" "column"
        , Html.Attributes.style "align-items" "flex-end"
        , Html.Attributes.style "justify-content" "flex-start"
        , Html.Attributes.style "padding" "3px"
        ]
        [ Html.text <|
            if options.use24HourTime then
                String.padLeft 2 '0' (String.fromInt hour) ++ ":00"

            else if hour == 0 then
                "12am"

            else if hour < 12 then
                String.fromInt hour ++ "am"

            else if hour == 12 then
                "12pm"

            else
                String.fromInt (hour - 12) ++ "pm"
        ]
    , dayHour
    , dayHour
    , dayHour
    , dayHour
    , dayHour
    , dayHour
    , dayHour
    ]


allMonths : List Time.Month
allMonths =
    [ Time.Jan
    , Time.Feb
    , Time.Mar
    , Time.Apr
    , Time.May
    , Time.Jun
    , Time.Jul
    , Time.Aug
    , Time.Sep
    , Time.Oct
    , Time.Nov
    , Time.Dec
    ]


viewMonthOfYear : InternalConfig msg -> Time.Month -> Html msg
viewMonthOfYear options month =
    let
        weeks : Int
        weeks =
            options
                |> monthDateRange
                |> List.length
                |> (\count -> ceiling (toFloat count / 7))
    in
    Html.div []
        [ case options.viewMonthHeader of
            Just viewMonthHeader ->
                viewMonthHeader month

            Nothing ->
                Html.h2 [ Html.Attributes.style "text-align" "center" ]
                    [ Html.text (monthToLabel month) ]
        , Html.Keyed.node "div"
            [ Html.Attributes.style "display" "grid"
            , Html.Attributes.style "grid-template-columns" "repeat(7, 1fr)"
            , Html.Attributes.style "grid-template-rows" ("min-content repeat(" ++ String.fromInt weeks ++ ", 1fr)")
            , Html.Attributes.style "width" "100%"
            ]
            (viewDaysOfWeek options
                ++ viewMonthDaysOfYear options month
            )
        ]


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


viewMonthDaysOfYear : InternalConfig msg -> Time.Month -> List ( String, Html msg )
viewMonthDaysOfYear options month =
    let
        period =
            Date.fromCalendarDate (Date.year options.period) month 1

        ( firstDate, lastDate ) =
            calendarMonthBounds options.weekStartsOn period
    in
    Date.range Date.Day 1 firstDate (Date.add Date.Days 1 lastDate)
        |> List.map (viewMonthDayOfYear options month)


viewMonthDayOfYear : InternalConfig msg -> Time.Month -> Date -> ( String, Html msg )
viewMonthDayOfYear options month date =
    ( monthToLabel month ++ "-" ++ String.fromInt (Date.day date)
    , case options.viewDayOfMonthOfYear of
        Just viewDayOfMonthOfYear ->
            viewDayOfMonthOfYear month date

        Nothing ->
            Html.div
                [ Html.Attributes.style "min-width" "0"
                ]
                [ if Date.month date == month then
                    Html.div
                        [ Html.Attributes.style "border" "1px solid black"
                        , Html.Attributes.style "width" "100%"
                        , Html.Attributes.style "height" "100%"
                        , Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "justify-content" "center"
                        , Html.Attributes.style "align-items" "center"
                        ]
                        [ Html.text (String.fromInt (Date.day date)) ]

                  else
                    Html.div
                        [ Html.Attributes.style "border" "1px solid black"
                        , Html.Attributes.style "width" "100%"
                        , Html.Attributes.style "height" "100%"
                        , Html.Attributes.style "background" "lightgray"
                        ]
                        []
                ]
    )


viewDaysOfWeek : InternalConfig msg -> List ( String, Html msg )
viewDaysOfWeek options =
    options.weekStartsOn
        |> daysOfWeek
        |> List.indexedMap
            (\index weekday ->
                ( weekdayToShortLabel weekday
                , case options.viewWeekdayHeader of
                    Just viewWeekdayHeader ->
                        viewWeekdayHeader index weekday

                    Nothing ->
                        Html.div
                            [ Html.Attributes.style "border" "1px solid black"
                            , Html.Attributes.style "grid-row" "1"
                            , Html.Attributes.style "grid-column" (String.fromInt (index + 1))
                            ]
                            [ Html.text (weekdayToShortLabel weekday) ]
                )
            )


daysOfWeek : Time.Weekday -> List Time.Weekday
daysOfWeek start =
    case start of
        Time.Mon ->
            [ Time.Mon, Time.Tue, Time.Wed, Time.Thu, Time.Fri, Time.Sat, Time.Sun ]

        Time.Tue ->
            [ Time.Tue, Time.Wed, Time.Thu, Time.Fri, Time.Sat, Time.Sun, Time.Mon ]

        Time.Wed ->
            [ Time.Wed, Time.Thu, Time.Fri, Time.Sat, Time.Sun, Time.Mon, Time.Tue ]

        Time.Thu ->
            [ Time.Thu, Time.Fri, Time.Sat, Time.Sun, Time.Mon, Time.Tue, Time.Wed ]

        Time.Fri ->
            [ Time.Fri, Time.Sat, Time.Sun, Time.Mon, Time.Tue, Time.Wed, Time.Thu ]

        Time.Sat ->
            [ Time.Sat, Time.Sun, Time.Mon, Time.Tue, Time.Wed, Time.Thu, Time.Fri ]

        Time.Sun ->
            [ Time.Sun, Time.Mon, Time.Tue, Time.Wed, Time.Thu, Time.Fri, Time.Sat ]


weekdayToShortLabel : Time.Weekday -> String
weekdayToShortLabel weekday =
    case weekday of
        Time.Sun ->
            "Sun"

        Time.Mon ->
            "Mon"

        Time.Tue ->
            "Tue"

        Time.Wed ->
            "Wed"

        Time.Thu ->
            "Thu"

        Time.Fri ->
            "Fri"

        Time.Sat ->
            "Sat"


weekdayToLabel : Time.Weekday -> String
weekdayToLabel weekday =
    case weekday of
        Time.Sun ->
            "Sunday"

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


viewMonthDays : InternalConfig msg -> List ( String, Html msg )
viewMonthDays options =
    options
        |> monthDateRange
        |> List.indexedMap (viewMonthDay options)


monthDateRange : InternalConfig msg -> List Date
monthDateRange options =
    let
        ( firstDate, lastDate ) =
            calendarMonthBounds options.weekStartsOn options.period
    in
    Date.range Date.Day 1 firstDate (Date.add Date.Days 1 lastDate)


startOfWeek : Time.Weekday -> Date.Interval
startOfWeek weekday =
    case weekday of
        Time.Mon ->
            Date.Monday

        Time.Tue ->
            Date.Tuesday

        Time.Wed ->
            Date.Wednesday

        Time.Thu ->
            Date.Thursday

        Time.Fri ->
            Date.Friday

        Time.Sat ->
            Date.Saturday

        Time.Sun ->
            Date.Sunday


endOfWeek : Time.Weekday -> Date.Interval
endOfWeek weekday =
    case weekday of
        Time.Mon ->
            Date.Sunday

        Time.Tue ->
            Date.Monday

        Time.Wed ->
            Date.Tuesday

        Time.Thu ->
            Date.Wednesday

        Time.Fri ->
            Date.Thursday

        Time.Sat ->
            Date.Friday

        Time.Sun ->
            Date.Saturday


viewMonthDay : InternalConfig msg -> Int -> Date -> ( String, Html msg )
viewMonthDay options index date =
    let
        column =
            modBy 7 index + 1

        row =
            (index // 7) + 2
    in
    ( monthToLabel (Date.month date) ++ "-" ++ String.fromInt (Date.day date)
    , case options.viewDayOfMonth of
        Just viewDayOfMonth ->
            viewDayOfMonth { column = column, row = row } date

        Nothing ->
            Html.div
                [ Html.Attributes.style "min-width" "0"
                , Html.Attributes.style "grid-column" (String.fromInt column)
                , Html.Attributes.style "grid-row" (String.fromInt row)
                ]
                [ Html.div
                    [ Html.Attributes.style "border" "1px solid black"
                    , Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" "100%"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "align-items" "center"
                    ]
                    [ Html.text (String.fromInt (Date.day date)) ]
                ]
    )



-- HELPERS


{-| Rounds to the last day of the month of the given date.
-}
ceilingMonth : Date -> Date
ceilingMonth date =
    date
        |> Date.add Date.Months 1
        |> Date.floor Date.Month
        |> Date.add Date.Days -1


{-| Get the first and last day of the week that the given date is in,
relative to the start day of the week.

    import Date
    import Time

    Calendar.weekBounds Time.Sun (Date.fromCalendarDate 2024 Time.Apr 1)
    --> (Date.fromCalendarDate 2024 Time.Mar 31, Date.fromCalendarDate 2024 Time.Apr 6)

-}
weekBounds : Time.Weekday -> Date -> ( Date, Date )
weekBounds weekStartsOn date =
    let
        start =
            date
                |> Date.floor (startOfWeek weekStartsOn)

        end =
            date
                |> Date.ceiling (endOfWeek weekStartsOn)
    in
    ( start, end )


{-| Get the first and last day of the calendar month that the given date is in.
E.g. in April 2024 the 1st is on a Monday and the 30th is on a Tuesday. If the
first day of the week is Sunday then the start date will be 2024-03-31 and the
end date will be 2024-05-04.

    import Date
    import Time

    Calendar.calendarMonthBounds Time.Sun (Date.fromCalendarDate 2024 Time.Apr 1)
    --> ( Date.fromCalendarDate  2024 Time.Mar 31, Date.fromCalendarDate  2024 Time.May 4 )

-}
calendarMonthBounds : Time.Weekday -> Date -> ( Date, Date )
calendarMonthBounds weekStartsOn date =
    let
        start =
            date
                |> Date.floor Date.Month
                |> Date.floor (startOfWeek weekStartsOn)

        end =
            date
                |> ceilingMonth
                |> Date.ceiling (endOfWeek weekStartsOn)
    in
    ( start, end )


{-| Get the row and column of the given date in a calendar month view.
Useful for placing content in the calendar grid.

    import Date
    import Time

    Calendar.toRowAndColumn Time.Sun (Date.fromCalendarDate 2024 Time.Apr 15)
    --> { row = 4, column = 2 }

-}
toRowAndColumn : Time.Weekday -> Date -> { column : Int, row : Int }
toRowAndColumn weekStartsOn date =
    let
        ( start, end ) =
            calendarMonthBounds weekStartsOn date

        index =
            Date.range Date.Day 1 start end
                |> findIndex ((==) date)
                |> Maybe.withDefault 0

        column =
            modBy 7 index + 1

        row =
            (index // 7) + 2
    in
    { column = column, row = row }


findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex =
    findIndexHelp 0


findIndexHelp : Int -> (a -> Bool) -> List a -> Maybe Int
findIndexHelp index predicate list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if predicate x then
                Just index

            else
                findIndexHelp (index + 1) predicate xs
