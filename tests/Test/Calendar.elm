module Test.Calendar exposing (suite)

import Calendar
import Date
import Expect
import Fuzz
import Test exposing (Test)
import Time


suite : Test
suite =
    Test.describe "Calendar helpers are accurate"
        [ Test.test "calendarMonthBounds" <|
            \() ->
                Calendar.calendarMonthBounds Time.Sun (Date.fromCalendarDate 2024 Time.Apr 1)
                    |> Expect.equal
                        ( Date.fromCalendarDate 2024 Time.Mar 31
                        , Date.fromCalendarDate 2024 Time.May 4
                        )
        ]
