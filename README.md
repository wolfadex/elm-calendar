# `elm-calendar` [![Build Status](https://github.com/wolfadex/elm-calendar/workflows/CI/badge.svg)](https://github.com/wolfadex/elm-calendar/actions?query=branch%3Amain)

A stateless calendar for viewing events or anything else that can be displayed across time.

To get started, I want to view what my birthday month will look like in the year 3000.

```elm
import Calendar exposing (Calendar)
import Date exposing (Date)
import Time

-- We create a new `Calendar`
Calendar.new
    { period =
        -- with the period we want to view
        Date.fromCalendarDate 3000 Time.Feb 22
    , scope =
        -- scoped to viewing the whole month
        Calendar.Month
    }
    -- I'm in the US, so I want the week to start on Sunday
    |> Calendar.withWeekStartsOn Time.Sun
    -- and then we render it to HTML
    |> Calendar.view
```

This is a nice start, but I think we can do better. I'd like add some flair to may actual birthday.

```elm
import Calendar exposing (Calendar)
import Date exposing (Date)
import Html
import Time

Calendar.new
    { period =
        Date.fromCalendarDate 3000 Time.Feb 22
    , scope =
        Calendar.Month
    }
    |> Calendar.withWeekStartsOn Time.Sun
    -- Now we can customize how each day of the month is displayed
    |> Calendar.withViewDayOfMonth
        (\date gridPosition ->
            Html.div []
                -- These styles are our custom style for our calendar
                [ Html.Attributes.style "border" "1px solid black"
                , Html.Attributes.style "width" "100%"
                , Html.Attributes.style "height" "100%"
                , Html.Attributes.style "min-height" "4rem"
                , Html.Attributes.style "padding" "3px"

                -- These styles help with general grid layout and will likely be used on every calendar
                , Html.Attributes.style "min-width" "0"
                , Html.Attributes.style "grid-column" (String.fromInt gridPosition.column)
                , Html.Attributes.style "grid-row" (String.fromInt gridPosition.row)

                , if Date.day date == 22 then
                    -- It's my birthday, so let's add a colorful background
                    Html.Attributes.style "background-color" "aqua"

                  else
                    -- Otherwise, just a white background
                    Html.Attributes.style "background-color" "white"
                ]
                [ if Date.month date == Time.Jan then
                    -- We might have some days from the previous month
                    Html.text "It's not February yet"

                  else if Date.day date < 22 then
                    -- We're getting closer
                    Html.text ("Only " ++ String.fromInt (Date.day date) " days till my birthday")

                  else if Date.day date == 22 then
                    -- It's my birthday
                    Html.text "It's my birthday 🥳"

                  else
                    -- It's after my birthday
                    Html.text "Gotta wait till next year"
                ]
        )
    |> Calendar.view
```

To see live examples, checkout [link to demo site](https://wolfadex.github.io/elm-calendar/)
