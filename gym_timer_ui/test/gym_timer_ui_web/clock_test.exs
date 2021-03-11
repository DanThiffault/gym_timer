defmodule GymTimerUiWeb.ClockTest do
  use ExUnit.Case
  alias GymTimerUiWeb.Clock

  describe "clock mode" do
    test "it display the current hour & minute" do
      Clock.clock_mode()

      Clock.set_timesource(fn ->
        Timex.to_datetime({{2015, 1, 1}, {13, 24, 0}}, "America/New_York")
      end)

      %{mode: :clock, clock: digits} = Clock.val()
      red = <<255, 0, 0>>

      assert digits ==
               Clock.digit("1", red) <>
                 Clock.digit("3", red) <>
                 Clock.digit(":", red) <>
                 Clock.digit("2", red) <> Clock.digit("4", red)
    end
  end

  describe "count up mode" do
    test "it starts with a count in" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode()
      %{mode: :count_up, clock: clock} = Clock.val()
      color = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("1", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "it switches to counting up" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 11) end)
      %{mode: :count_up, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("0", color)
      assert Enum.at(digits, 4) == Clock.digit("1", color)
    end

    test "it keeps counting up" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode()
      Clock.set_timesource(fn -> Timex.shift(start_time, minutes: 98, seconds: 59) end)
      %{mode: :count_up, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("9", color)
      assert Enum.at(digits, 1) == Clock.digit("8", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("4", color)
      assert Enum.at(digits, 4) == Clock.digit("9", color)
    end

    test "it can be paused" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode(0)
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 10) end)
      Clock.pause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 20) end)
      %{mode: :count_up, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("1", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "it can be unpaused" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode(0)
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 10) end)
      Clock.pause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 20) end)
      Clock.unpause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 25) end)
      %{mode: :count_up, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("1", color)
      assert Enum.at(digits, 4) == Clock.digit("5", color)
    end

    test "it plays sounds" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_up_mode(5)

      %{mode: :count_up, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 2) end)
      %{mode: :count_up, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 3) end)
      %{mode: :count_up, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 4) end)
      %{mode: :count_up, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 5) end)
      %{mode: :count_up, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:go]
    end
  end

  describe "count down mode" do
    test "it starts with a count in" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(100, 10)
      %{mode: :count_down, clock: clock} = Clock.val()
      color = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("1", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "plays count in sounds" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(100, 5)

      %{mode: :count_down, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 2) end)
      %{mode: :count_down, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 3) end)
      %{mode: :count_down, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 4) end)
      %{mode: :count_down, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 5) end)
      %{mode: :count_down, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:go]
    end

    test "switches to counting down" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(20 * 60, 10)
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 11) end)
      %{mode: :count_down, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("1", color)
      assert Enum.at(digits, 1) == Clock.digit("9", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("5", color)
      assert Enum.at(digits, 4) == Clock.digit("9", color)
    end

    test "can be paused" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(600, 0)
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 10) end)
      Clock.pause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 20) end)
      %{mode: :count_down, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("9", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("5", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "can be unpaused" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(600, 0)
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 10) end)
      Clock.pause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 20) end)
      Clock.unpause()
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 30) end)

      %{mode: :count_down, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("9", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("4", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "ends when the count down is over" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.count_down_mode(600, 0)

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 600) end)
      %{mode: :count_down, clock: clock, sounds: sounds} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>
      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("0", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)

      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == [:end_time]

      # Blink off
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 600, milliseconds: 600) end)
      %{mode: :count_down, clock: clock} = Clock.val()
      color = <<255, 0, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>
      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("0", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)

      # Switch back to clock
      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 610) end)
      %{mode: mode, sounds: sounds} = Clock.val()

      assert mode == :clock
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []
    end
  end

  describe "interval mode" do
    test "it can count in" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.interval_mode(6, 4, 10)
      %{mode: :interval, clock: clock} = Clock.val()
      color = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", color)
      assert Enum.at(digits, 1) == Clock.digit("0", color)
      assert Enum.at(digits, 2) == Clock.digit(":", color)
      assert Enum.at(digits, 3) == Clock.digit("1", color)
      assert Enum.at(digits, 4) == Clock.digit("0", color)
    end

    test "plays count in sounds" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.interval_mode(6, 4, 5)

      %{mode: :interval, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 2) end)
      %{mode: :interval, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 3) end)
      %{mode: :interval, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 4) end)
      %{mode: :interval, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:count_in]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 5) end)
      %{mode: :interval, sounds: sounds} = Clock.val()
      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)

      assert active_sounds == [:work]
    end

    test "it counts work time" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.interval_mode(6, 4, 0)
      %{mode: :interval, clock: clock, sounds: sounds} = Clock.val()
      red = <<255, 0, 0>>
      green = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", green)
      assert Enum.at(digits, 1) == Clock.digit("1", green)
      assert Enum.at(digits, 2) == Clock.digit(":", red)
      assert Enum.at(digits, 3) == Clock.digit("0", red)
      assert Enum.at(digits, 4) == Clock.digit("0", red)

      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == [:work]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 3) end)
      %{mode: :interval, clock: clock, sounds: sounds} = Clock.val()

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", green)
      assert Enum.at(digits, 1) == Clock.digit("1", green)
      assert Enum.at(digits, 2) == Clock.digit(":", red)
      assert Enum.at(digits, 3) == Clock.digit("0", red)
      assert Enum.at(digits, 4) == Clock.digit("3", red)

      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []
    end

    test "it counts rest time" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.interval_mode(6, 4, 0)

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 6) end)
      %{mode: :interval, clock: clock, sounds: sounds} = Clock.val()
      blue = <<0, 0, 255>>
      green = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", green)
      assert Enum.at(digits, 1) == Clock.digit("1", green)
      assert Enum.at(digits, 2) == Clock.digit(":", blue)
      assert Enum.at(digits, 3) == Clock.digit("0", blue)
      assert Enum.at(digits, 4) == Clock.digit("4", blue)

      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == [:rest]

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 8) end)
      %{mode: :interval, clock: clock, sounds: sounds} = Clock.val()

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", green)
      assert Enum.at(digits, 1) == Clock.digit("1", green)
      assert Enum.at(digits, 2) == Clock.digit(":", blue)
      assert Enum.at(digits, 3) == Clock.digit("0", blue)
      assert Enum.at(digits, 4) == Clock.digit("2", blue)

      active_sounds = sounds |> Enum.filter(fn {_k, v} -> v end) |> Enum.map(fn {k, _v} -> k end)
      assert active_sounds == []
    end

    test "it tracks completed intervals" do
      start_time = Timex.now()
      Clock.set_timesource(fn -> start_time end)
      Clock.interval_mode(6, 4, 0)

      Clock.set_timesource(fn -> Timex.shift(start_time, seconds: 20) end)
      %{mode: :interval, clock: clock} = Clock.val()
      red = <<255, 0, 0>>
      green = <<0, 255, 0>>

      digits = for <<digit::384 <- clock>>, do: <<digit::size(384)>>

      assert Enum.at(digits, 0) == Clock.digit("0", green)
      assert Enum.at(digits, 1) == Clock.digit("3", green)
      assert Enum.at(digits, 2) == Clock.digit(":", red)
      assert Enum.at(digits, 3) == Clock.digit("0", red)
      assert Enum.at(digits, 4) == Clock.digit("0", red)
    end
  end
end
