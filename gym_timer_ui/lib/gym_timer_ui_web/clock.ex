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

  def count_up_mode() do
    GenServer.call(__MODULE__, {:count_up_mode, 10})
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

    clock = [
      digit(h1, color),
      digit(h2, color),
      digit(":", color),
      digit(m1, color),
      digit(m2, color)
    ]

    {:reply, clock, state}
  end

  @impl true
  def handle_call(:val, _from, state = %{mode: :count_up}) do
    current_time = Timex.now()
    start_time = Map.get(state, :start_time, current_time)

    time_diff = Time.diff(current_time, start_time)
    counting_in = time_diff < 0

    color =
      if counting_in do
        <<0, 255, 0>>
      else
        <<255, 0, 0>>
      end

    time_diff2 =
      if counting_in do
        time_diff * -1
      else
        time_diff
      end

    <<s1::binary-size(1)>> <> s2 =
      time_diff2
      |> Integer.mod(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    <<m1::binary-size(1)>> <> m2 =
      time_diff2
      |> Integer.floor_div(60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    clock = [
      digit(m1, color),
      digit(m2, color),
      digit(":", color),
      digit(s1, color),
      digit(s2, color)
    ]

    {:reply, clock, state}
  end

  @impl true
  def handle_call(:val, _from, state) do
    color = <<0, 0, 0>>

    clock = [
      digit(:off, color),
      digit(:off, color),
      digit(:off, color),
      digit(:off, color),
      digit(:off, color)
    ]

    {:reply, clock, state}
  end

  @impl true
  def handle_call(:clock_mode, _from, state) do
    new_state = Map.merge(state, %{mode: :clock})
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:count_up_mode, count_in}, _from, state) do
    start_time = Time.add(Timex.now(), count_in)
    new_state = Map.merge(state, %{mode: :count_up, start_time: start_time})
    {:reply, new_state, new_state}
  end

  def digit("1", color) do
    @blank <> @blank <> color <> @blank <> @blank <> @blank <> color <> @blank <> @blank
  end

  def digit("2", color) do
    @blank <> color <> color <> color <> color <> color <> @blank <> @blank <> @blank
  end

  def digit("3", color) do
    @blank <> color <> color <> color <> @blank <> color <> color <> @blank <> @blank
  end

  def digit("4", color) do
    color <> @blank <> color <> color <> @blank <> @blank <> color <> @blank <> @blank
  end

  def digit("5", color) do
    color <> color <> @blank <> color <> @blank <> color <> color <> @blank <> @blank
  end

  def digit("6", color) do
    color <> @blank <> @blank <> color <> color <> color <> color <> @blank <> @blank
  end

  def digit("7", color) do
    @blank <> color <> color <> @blank <> @blank <> @blank <> color <> @blank <> @blank
  end

  def digit("8", color) do
    color <> color <> color <> color <> color <> color <> color <> @blank <> @blank
  end

  def digit("9", color) do
    color <> color <> color <> color <> @blank <> @blank <> color <> @blank <> @blank
  end

  def digit("0", color) do
    color <> color <> color <> @blank <> color <> color <> color <> @blank <> @blank
  end

  def digit(":", color) do
    @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> color <> color
  end

  def digit(_number, _color) do
    @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank <> @blank
  end
end
