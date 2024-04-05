module Calendar exposing
    ( Config, new
    , Scope(..)
    , view
    , withWeekStartsOnMonday
    , withViewDayOfMonth
    , withViewWeekdayHeader
    )

{-| REPLACEME


# Create

@docs Config, new
@docs Scope

@docs view


# Modify the general rendering

@docs withWeekStartsOnMonday


# Custom viewing

@docs withViewDayOfMonth
@docs withViewWeekdayHeader

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
    , weekStartsOnMonday : Bool

    -- Custom rendering
    , viewDayOfMonth : Maybe (Date -> Html msg)
    , viewWeekdayHeader : Maybe (Time.Weekday -> Html msg)
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
        , weekStartsOnMonday = False
        , viewDayOfMonth = Nothing
        , viewWeekdayHeader = Nothing
        }


{-| By default, this package has the week starts on Sunday.
Use this function to change it to Monday.

    Calendar.new
        { period = Date.fromParts 2022 Time.Feb 22
        , scope = Calendar.Month
        }
        |> Calendar.withWeekStartsOnMonday
        |> Calendar.view

-}
withWeekStartsOnMonday : Config msg -> Config msg
withWeekStartsOnMonday (Config options) =
    Config
        { options
            | weekStartsOnMonday = True
        }


{-| Override the default rendering of the day of the month.

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
                []

        Week ->
            Html.div []
                []

        Month ->
            Html.div
                [ Html.Attributes.style "display" "grid"
                , Html.Attributes.style "grid-template-columns" "repeat(7, 1fr)"
                ]
                (viewDaysOfWeek options
                    ++ viewMonthDays options
                )

        Year ->
            Html.div []
                []


viewDaysOfWeek : InternalConfig msg -> List (Html msg)
viewDaysOfWeek options =
    let
        daysOfWeek =
            if options.weekStartsOnMonday then
                [ Time.Mon, Time.Tue, Time.Wed, Time.Thu, Time.Fri, Time.Sat, Time.Sun ]

            else
                [ Time.Sun, Time.Mon, Time.Tue, Time.Wed, Time.Thu, Time.Fri, Time.Sat ]
    in
    List.map
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
        daysOfWeek


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
                |> Date.floor Date.Week
                |> (\d ->
                        if options.weekStartsOnMonday then
                            d

                        else
                            Date.add Date.Days -1 d
                   )

        lastDate =
            options.period
                |> Date.ceiling Date.Month
                |> Date.ceiling Date.Week
                |> (\d ->
                        if options.weekStartsOnMonday then
                            d

                        else
                            Date.add Date.Days -1 d
                   )
    in
    Date.range Date.Day 1 firstDay lastDate
        |> List.map (viewMonthDay options)


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
