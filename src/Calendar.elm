module Calendar exposing
    ( Config, new
    , Scope(..)
    , view
    , withWeekStartsOn
    , withViewDayOfMonth, withViewDayOfMonthOfYear
    , withViewWeekdayHeader
    , withViewMonthHeader
    , weekBounds
    )

{-| REPLACEME


# Create

@docs Config, new
@docs Scope

@docs view


# Modify the general rendering

@docs withWeekStartsOn


# Custom viewing

@docs withViewDayOfMonth, withViewDayOfMonthOfYear
@docs withViewWeekdayHeader
@docs withViewMonthHeader


# Helpers

@docs weekBounds

-}

import Date exposing (Date)
import Html exposing (Html)
import Html.Attributes
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

    -- Custom rendering
    , viewDayOfMonth : Maybe (Date -> Html msg)
    , viewDayOfMonthOfYear : Maybe (Time.Month -> Date -> Html msg)
    , viewWeekdayHeader : Maybe (Time.Weekday -> Html msg)
    , viewMonthHeader : Maybe (Time.Month -> Html msg)
    }


{-| Start building up a new calendar. The `period` tells us
what year, month, and day we are looking at. The `scope` tells
us which "zoom" level to render the data at.

    Calendar.new
        { period = Date.fromParts 2024 Time.Feb 22
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
        , viewDayOfMonth = Nothing
        , viewDayOfMonthOfYear = Nothing
        , viewWeekdayHeader = Nothing
        , viewMonthHeader = Nothing
        }


{-| By default this the week starts on Monday.
Use this function to change it to another day.

    Calendar.new
        { period = Date.fromParts 2022 Time.Feb 22
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


{-| Override the default rendering of the day of the month, for the `Month` scope.

    Calendar.new
        { period = Date.fromParts 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withViewDayOfMonth
            (\date ->
                Html.text
                    (String.fromInt (Date.day date))
            )
        |> Calendar.view

-}
withViewDayOfMonth : (Date -> Html msg) -> Config msg -> Config msg
withViewDayOfMonth viewDayOfMonth (Config options) =
    Config
        { options
            | viewDayOfMonth = Just viewDayOfMonth
        }


{-| Override the default rendering of the day of the month, for the `Year` scope.

    Calendar.new
        { period = Date.fromParts 2024 Time.Feb 22
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
        { period = Date.fromParts 2024 Time.Feb 22
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
withViewWeekdayHeader : (Time.Weekday -> Html msg) -> Config msg -> Config msg
withViewWeekdayHeader viewWeekdayHeader (Config options) =
    Config
        { options
            | viewWeekdayHeader = Just viewWeekdayHeader
        }


{-| Override the default rendering of the month header, for the `Year` scope.

    Calendar.new
        { period = Date.fromParts 2024 Time.Feb 22
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


{-| Renders your `Config` to `Html`.
If you want to customize the rendering,use one of the various `withView...` functions.

    Calendar.new
        { period = Date.fromParts 2024 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.view

-}
view : Config msg -> Html msg
view (Config options) =
    case options.scope of
        Day ->
            Html.div []
                [ Html.text "TODO" ]

        Week ->
            Html.div []
                [ Html.text "TODO" ]

        Month ->
            Html.div
                [ Html.Attributes.style "display" "grid"
                , Html.Attributes.style "grid-template-columns" "repeat(7, 1fr)"
                ]
                (viewDaysOfWeek options
                    ++ viewMonthDays options
                )

        Year ->
            allMonths
                |> List.map (viewMonthOfYear options)
                |> Html.div []


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
    Html.div []
        [ case options.viewMonthHeader of
            Just viewMonthHeader ->
                viewMonthHeader month

            Nothing ->
                Html.h2 [ Html.Attributes.style "text-align" "center" ]
                    [ Html.text (monthToLabel month) ]
        , Html.div
            [ Html.Attributes.style "display" "grid"
            , Html.Attributes.style "grid-template-columns" "repeat(7, 1fr)"
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


viewMonthDaysOfYear : InternalConfig msg -> Time.Month -> List (Html msg)
viewMonthDaysOfYear options month =
    let
        period =
            Date.fromCalendarDate (Date.year options.period) month 1

        firstDay =
            period
                |> Date.floor Date.Month
                |> Date.floor (startOfWeek options.weekStartsOn)

        lastDate =
            period
                |> ceilingMonth
                |> Date.ceiling (endOfWeek options.weekStartsOn)
                |> Date.add Date.Days 1
    in
    Date.range Date.Day 1 firstDay lastDate
        |> List.map (viewMonthDayOfYear options month)


viewMonthDayOfYear : InternalConfig msg -> Time.Month -> Date -> Html msg
viewMonthDayOfYear options month date =
    Html.div
        [ Html.Attributes.style "aspect-ratio" "1"
        ]
        [ case options.viewDayOfMonthOfYear of
            Just viewDayOfMonthOfYear ->
                viewDayOfMonthOfYear month date

            Nothing ->
                if Date.month date == month then
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


viewDaysOfWeek : InternalConfig msg -> List (Html msg)
viewDaysOfWeek options =
    options.weekStartsOn
        |> daysOfWeek
        |> List.map
            (\weekday ->
                case options.viewWeekdayHeader of
                    Just viewWeekdayHeader ->
                        viewWeekdayHeader weekday

                    Nothing ->
                        Html.div
                            [ Html.Attributes.style "border" "1px solid black"
                            ]
                            [ Html.text (weekdayToLabel weekday) ]
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


weekdayToLabel : Time.Weekday -> String
weekdayToLabel weekday =
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


viewMonthDays : InternalConfig msg -> List (Html msg)
viewMonthDays options =
    let
        firstDay =
            options.period
                |> Date.floor Date.Month
                |> Date.floor (startOfWeek options.weekStartsOn)

        lastDate =
            options.period
                |> ceilingMonth
                |> Date.ceiling (endOfWeek options.weekStartsOn)
                |> Date.add Date.Days 1
    in
    Date.range Date.Day 1 firstDay lastDate
        |> List.map (viewMonthDay options)


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


viewMonthDay : InternalConfig msg -> Date -> Html msg
viewMonthDay options date =
    Html.div
        [ Html.Attributes.style "aspect-ratio" "1"
        ]
        [ case options.viewDayOfMonth of
            Just viewDayOfMonth ->
                viewDayOfMonth date

            Nothing ->
                Html.div
                    [ Html.Attributes.style "border" "1px solid black"
                    , Html.Attributes.style "width" "100%"
                    , Html.Attributes.style "height" "100%"
                    , Html.Attributes.style "display" "flex"
                    , Html.Attributes.style "justify-content" "center"
                    , Html.Attributes.style "align-items" "center"
                    ]
                    [ Html.text (String.fromInt (Date.day date)) ]
        ]



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
