defmodule GymTimerUiWeb.Clock do
  use GenServer

  @blank <<0, 0, 0>>

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def val() do
    GenServer.call(__MODULE__, :val)
  end

  def clock_mode() do
    GenServer.call(__MODULE__, :clock_mode)
  end

  def count_up_mode(count_in \\ 10) do
    GenServer.call(__MODULE__, {:count_up_mode, count_in})
  end

  def count_down_mode(count_down_from \\ 600, count_in \\ 10) do
    GenServer.call(__MODULE__, {:count_down_mode, count_down_from, count_in})
  end

  def test_mode(digits, color) do
    GenServer.call(__MODULE__, {:test_mode, digits, color})
  end

  def raw_mode(bytes, sounds \\ %{}) do
    GenServer.call(__MODULE__, {:raw_mode, bytes, sounds})
  end

  def interval_mode(work_period, rest_period \\ 0, count_in \\ 10) do
    GenServer.call(__MODULE__, {:interval_mode, work_period, rest_period, count_in})
  end

  def pause() do
    GenServer.call(__MODULE__, :pause)
  end

  def unpause() do
    GenServer.call(__MODULE__, :unpause)
  end

  def set_timesource(timesource) do
    GenServer.call(__MODULE__, {:set_timesource, timesource})
  end

  @impl true
  def init(state) do
    new_state = Map.merge(%{mode: :clock, sounds: %{}, timesource: &Timex.now/0}, state)
    {:ok, new_state}
  end

  @impl true
  def handle_call({:set_timesource, timesource}, _from, state) do
    {:reply, timesource, Map.put(state, :timesource, timesource)}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :clock, timesource: timesource}) do
    timezone = Timex.Timezone.get("America/New_York")
    now = timesource.() |> Timex.Timezone.convert(timezone)

    {:ok, hours} = Timex.format(now, "{h24}")
    {:ok, minutes} = Timex.format(now, "{m}")

    <<h1::binary-size(1)>> <> h2 = hours
    <<m1::binary-size(1)>> <> m2 = minutes

    color = <<255, 0, 0>>

    clock =
      digit(h1, color) <>
        digit(h2, color) <> digit(":", color) <> digit(m1, color) <> digit(m2, color)

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :count_up, timesource: timesource}) do
    current_time = timesource.()
    start_time = Map.get(state, :start_time, current_time)

    paused_time =
      Time.diff(current_time, Map.get(state, :pause_start, current_time))
      |> Kernel.+(Map.get(state, :paused_time, 0))

    time_diff =
      Time.diff(current_time, start_time)
      |> Kernel.-(paused_time)

    half_sec =
      Time.add(start_time, paused_time)
      |> Time.diff(current_time, :millisecond)
      |> Integer.mod(1000) < 500

    counting_in = time_diff < 0

    color = if counting_in, do: <<0, 255, 0>>, else: <<255, 0, 0>>
    time_diff_abs = if counting_in, do: time_diff * -1, else: time_diff

    <<s1::binary-size(1)>> <> s2 =
      time_diff_abs
      |> Integer.mod(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    <<m1::binary-size(1)>> <> m2 =
      time_diff_abs
      |> Integer.floor_div(60)
      |> Integer.mod(99)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    clock =
      digit(m1, color) <>
        digit(m2, color) <> digit(":", color) <> digit(s1, color) <> digit(s2, color)

    new_state =
      state
      |> Map.put(:clock, clock)
      |> Map.update!(:sounds, fn sounds ->
        Map.put(sounds, :count_in, time_diff_abs in [3, 2, 1] && counting_in && half_sec)
        |> Map.put(:go, time_diff_abs == 0 && !counting_in)
      end)

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :count_down, timesource: timesource}) do
    current_time = timesource.()
    start_time = Map.get(state, :start_time, current_time)

    paused_time =
      Time.diff(current_time, Map.get(state, :pause_start, current_time))
      |> Kernel.+(Map.get(state, :paused_time, 0))

    time_diff =
      Time.diff(current_time, start_time)
      |> Kernel.-(paused_time)

    counting_in = time_diff < 0

    color = if counting_in, do: <<0, 255, 0>>, else: <<255, 0, 0>>
    time_diff_abs = if counting_in, do: time_diff * -1, else: time_diff

    count_down_from = Map.get(state, :count_down_from)

    half_sec =
      Time.add(start_time, paused_time)
      |> Time.diff(current_time, :millisecond)
      |> Integer.mod(1000) < 500

    starting_value =
      cond do
        counting_in ->
          time_diff_abs

        count_down_from - time_diff_abs > 0 ->
          count_down_from - time_diff_abs

        count_down_from - time_diff_abs > -5 ->
          if half_sec, do: 0, else: -2

        true ->
          -1
      end

    case starting_value do
      -1 ->
        handle_call(:val, nil, %{mode: :clock, sounds: %{}})

      -2 ->
        clock =
          digit("", color) <>
            digit("", color) <> digit("", color) <> digit("", color) <> digit("", color)

        new_state = state |> Map.put(:clock, clock)
        {:reply, new_state, new_state}

      _ ->
        <<s1::binary-size(1)>> <> s2 =
          starting_value
          |> Integer.mod(60)
          |> Integer.to_string()
          |> String.pad_leading(2, "0")

        <<m1::binary-size(1)>> <> m2 =
          starting_value
          |> Integer.floor_div(60)
          |> Integer.mod(99)
          |> Integer.to_string()
          |> String.pad_leading(2, "0")

        clock =
          digit(m1, color) <>
            digit(m2, color) <> digit(":", color) <> digit(s1, color) <> digit(s2, color)

        new_state =
          state
          |> Map.put(:clock, clock)
          |> Map.update!(:sounds, fn sounds -> Map.put(sounds, :end_time, starting_value == 0) end)
          |> Map.update!(:sounds, fn sounds ->
            Map.put(sounds, :count_in, starting_value in [3, 2, 1] && counting_in && half_sec)
            |> Map.put(:go, starting_value == count_down_from && !counting_in)
          end)

        {:reply, new_state, new_state}
    end
  end

  @impl true
  def handle_call(
        :val,
        _from,
        state = %{
          mode: :interval,
          work_period: work_period,
          rest_period: rest_period,
          start_time: start_time,
          timesource: timesource
        }
      ) do
    current_time = timesource.()

    paused_time =
      Time.diff(current_time, Map.get(state, :pause_start, current_time))
      |> Kernel.+(Map.get(state, :paused_time, 0))

    time_diff =
      Time.diff(current_time, start_time)
      |> Kernel.-(paused_time)

    half_sec =
      Time.add(start_time, paused_time)
      |> Time.diff(current_time, :millisecond)
      |> Integer.mod(1000) < 500

    counting_in = time_diff < 0

    time_diff_abs = if counting_in, do: time_diff * -1, else: time_diff

    total_period = work_period + rest_period
    resting = !counting_in && Integer.mod(time_diff, total_period) >= work_period

    color =
      cond do
        resting ->
          <<0, 0, 255>>

        counting_in ->
          <<0, 255, 0>>

        true ->
          <<255, 0, 0>>
      end

    total_intervals =
      if counting_in, do: 0, else: time_diff_abs |> Integer.floor_div(total_period) |> Kernel.+(1)

    interval_value =
      cond do
        resting ->
          rest_period -
            (time_diff_abs
             |> Integer.mod(total_period)
             |> Kernel.-(work_period)
             |> Integer.mod(rest_period))

        counting_in ->
          time_diff_abs

        true ->
          time_diff_abs |> Integer.mod(total_period) |> Integer.mod(work_period)
      end

    <<s1::binary-size(1)>> <> s2 =
      interval_value
      |> Integer.mod(99)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    <<m1::binary-size(1)>> <> m2 =
      total_intervals
      |> Integer.mod(99)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    clock =
      digit(m1, <<0, 255, 0>>) <>
        digit(m2, <<0, 255, 0>>) <> digit(":", color) <> digit(s1, color) <> digit(s2, color)

    new_state =
      state
      |> Map.put(:clock, clock)
      |> Map.update!(:sounds, fn sounds ->
        sounds
        |> Map.put(:count_in, interval_value in [3, 2, 1] && counting_in && half_sec)
        |> Map.put(:rest, interval_value == rest_period && resting)
        |> Map.put(:work, interval_value == work_period && !resting && !counting_in)
        |> Map.put(:work, interval_value == 0 && !resting && !counting_in)
      end)

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :test, digits: [d1, d2, d3, d4, d5], color: color}) do
    clock =
      digit(d1, color) <>
        digit(d2, color) <>
        digit(d3, color) <>
        digit(d4, color) <>
        digit(d5, color)

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :raw, bytes: bytes}) do
    new_state = Map.put(state, :clock, bytes)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state) do
    clock =
      digit(:off, @blank) <>
        digit(:off, @blank) <> digit(:off, @blank) <> digit(:off, @blank) <> digit(:off, @blank)

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:clock_mode, _from, state) do
    new_state = %{
      mode: :clock,
      sounds: %{},
      timesource: Map.get(state, :timesource, &Timex.now/0)
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:count_up_mode, count_in}, _from, state) do
    timesource = Map.get(state, :timesource, &Timex.now/0)
    start_time = Time.add(timesource.(), count_in)

    new_state = %{
      mode: :count_up,
      start_time: start_time,
      paused_time: 0,
      sounds: %{},
      timesource: timesource
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:count_down_mode, count_down_from, count_in}, _from, state) do
    timesource = Map.get(state, :timesource, &Timex.now/0)
    start_time = Time.add(timesource.(), count_in)

    new_state = %{
      sounds: %{},
      mode: :count_down,
      start_time: start_time,
      paused_time: 0,
      count_down_from: count_down_from,
      timesource: timesource
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:test_mode, digits, color}, _from, _state) do
    new_state = %{mode: :test, digits: digits, color: color, sounds: %{}}
    {:reply, digits, new_state}
  end

  @impl true
  def handle_call({:raw_mode, bytes, sounds}, _from, _state) do
    new_state = %{mode: :raw, bytes: bytes, sounds: sounds}
    {:reply, bytes, new_state}
  end

  @impl true
  def handle_call({:interval_mode, work_period, rest_period, count_in}, _from, state) do
    timesource = Map.get(state, :timesource, &Timex.now/0)
    start_time = Time.add(timesource.(), count_in)

    new_state = %{
      sounds: %{},
      mode: :interval,
      start_time: start_time,
      paused_time: 0,
      work_period: work_period,
      rest_period: rest_period,
      timesource: timesource
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:pause, _from, state) do
    timesource = Map.get(state, :timesource, &Timex.now/0)
    new_state = Map.put(state, :pause_start, timesource.())

    {:reply, :paused, new_state}
  end

  @impl true
  def handle_call(:unpause, _from, state) do
    timesource = Map.get(state, :timesource, &Timex.now/0)
    current_time = timesource.()
    additional_paused_time = Time.diff(current_time, Map.get(state, :pause_start, current_time))

    new_state =
      state
      |> Map.delete(:pause_start)
      |> Map.update(:paused_time, 0, fn current -> current + additional_paused_time end)

    {:reply, new_state, new_state}
  end

  def digit("1", color) do
    @blank <>
      @blank <>
      @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      @blank <>
      @blank <>
      @blank <>
      @blank <> @blank <> @blank <> @blank <> @blank
  end

  def digit("2", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      @blank <> @blank
  end

  def digit("3", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      @blank <>
      @blank <>
      color <>
      color <>
      @blank <> @blank
  end

  def digit("4", color) do
    color <>
      color <>
      @blank <>
      @blank <>
      color <>
      color <>
      color <> color <> @blank <> @blank <> @blank <> @blank <> color <> color <> @blank <> @blank
  end

  def digit("5", color) do
    color <>
      color <>
      color <>
      color <>
      @blank <>
      @blank <>
      color <> color <> color <> color <> @blank <> @blank <> color <> color <> @blank <> @blank
  end

  def digit("6", color) do
    color <>
      color <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      color <> color <> color <> color <> color <> color <> color <> color <> @blank <> @blank
  end

  def digit("7", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      @blank <>
      @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank
  end

  def digit("8", color) do
    color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <> color <> color <> color <> color <> color <> color <> color <> @blank <> @blank
  end

  def digit("9", color) do
    color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <> color <> @blank <> @blank <> @blank <> @blank <> color <> color <> @blank <> @blank
  end

  def digit("0", color) do
    color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <> color <> color <> color <> color <> color <> @blank <> @blank <> @blank <> @blank
  end

  def digit(":", color) do
    @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> color <> color
  end

  def digit(_number, _color) do
    @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank
  end
end
