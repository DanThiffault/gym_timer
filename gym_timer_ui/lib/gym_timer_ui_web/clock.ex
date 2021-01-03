defmodule GymTimerUiWeb.Clock do
  use GenServer

  @blank <<222, 222, 222>>

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

  def test_mode(digits) do
    GenServer.call(__MODULE__, {:test_mode, digits})
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

  @impl true
  def init(state) do
    new_state = Map.merge(%{mode: :clock}, state)
    {:ok, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :clock}) do
    timezone = Timex.Timezone.get("America/New_York")
    now = Timex.now() |> Timex.Timezone.convert(timezone)

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
  def handle_call(:val, _from, state = %{mode: :count_up}) do
    current_time = Timex.now()
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

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(
        :val,
        _from,
        state = %{
          mode: :interval,
          work_period: work_period,
          rest_period: rest_period,
          start_time: start_time
        }
      ) do
    current_time = Timex.now()

    paused_time =
      Time.diff(current_time, Map.get(state, :pause_start, current_time))
      |> Kernel.+(Map.get(state, :paused_time, 0))

    time_diff =
      Time.diff(current_time, start_time)
      |> Kernel.-(paused_time)

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
      if counting_in, do: 0, else: time_diff_abs |> Integer.floor_div(total_period)

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

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :test, digits: [d1, d2, d3, d4, d5]}) do
    color = <<0, 255, 255>>

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
  def handle_call(:val, _from, state) do
    clock =
      digit(:off, @blank) <>
        digit(:off, @blank) <> digit(:off, @blank) <> digit(:off, @blank) <> digit(:off, @blank)

    new_state = Map.put(state, :clock, clock)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:clock_mode, _from, _state) do
    new_state = %{mode: :clock}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:count_up_mode, count_in}, _from, _state) do
    start_time = Time.add(Timex.now(), count_in)
    new_state = %{mode: :count_up, start_time: start_time, paused_time: 0}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:test_mode, digits}, _from, _state) do
    new_state = %{mode: :test, digits: digits}
    {:reply, digits, new_state}
  end

  @impl true
  def handle_call({:interval_mode, work_period, rest_period, count_in}, _from, _state) do
    start_time = Time.add(Timex.now(), count_in)

    new_state = %{
      mode: :interval,
      start_time: start_time,
      paused_time: 0,
      work_period: work_period,
      rest_period: rest_period
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:pause, _from, state) do
    new_state = Map.put(state, :pause_start, Timex.now())

    {:reply, :paused, new_state}
  end

  @impl true
  def handle_call(:unpause, _from, state) do
    current_time = Timex.now()
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
      @blank <>
      @blank <>
      @blank <>
      @blank <> @blank <> @blank <> color <> color
  end

  def digit("2", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <>
      color <> color <> color <> color <> @blank <> @blank
  end

  def digit("3", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <> color <> color <> color <> @blank <> @blank <> color <> color <> color <> color
  end

  def digit("4", color) do
    color <>
      color <>
      @blank <>
      @blank <>
      color <> color <> color <> color <> @blank <> @blank <> @blank <> @blank <> color <> color
  end

  def digit("5", color) do
    color <>
      color <>
      color <>
      color <>
      @blank <> @blank <> color <> color <> @blank <> @blank <> color <> color <> color <> color
  end

  def digit("6", color) do
    color <>
      color <>
      @blank <>
      @blank <>
      @blank <> @blank <> color <> color <> color <> color <> color <> color <> color <> color
  end

  def digit("7", color) do
    @blank <>
      @blank <>
      color <>
      color <>
      color <> color <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> color <> color
  end

  def digit("8", color) do
    color <>
      color <>
      color <>
      color <>
      color <> color <> color <> color <> color <> color <> color <> color <> color <> color
  end

  def digit("9", color) do
    color <>
      color <>
      color <>
      color <>
      color <> color <> color <> color <> @blank <> @blank <> @blank <> @blank <> color <> color
  end

  def digit("0", color) do
    color <>
      color <>
      color <>
      color <>
      color <> color <> @blank <> @blank <> color <> color <> color <> color <> color <> color
  end

  def digit(":", color) do
    color <> color
  end

  def digit(":off", _color) do
    @blank <> @blank
  end

  def digit(_number, _color) do
    @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <>
      @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank
  end
end
