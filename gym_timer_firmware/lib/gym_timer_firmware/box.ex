defmodule GymTimerFirmware.Box do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def terminate(_reason, state) do
    :timer.cancel(Map.get(state, :timer))
    {:stop, state}
  end

  def init(_opts) do
    {:ok, timer_ref} = :timer.send_interval(100, self(), :tick)
    {:ok, %{timer: timer_ref}}
  end

  def handle_info(:tick, state) do
    %{clock: clock} = GymTimerUiWeb.Clock.val()
    colors = for <<r::8, g::8, b::8 <- clock>>, do: %Blinkchain.Color{r: r, g: g, b: b}

    colors
    |> Enum.with_index(0)
    |> Enum.map(fn {color, x} -> Blinkchain.set_pixel(%Blinkchain.Point{x: x, y: 0}, color) end)

    Blinkchain.render()

    {:noreply, state}
  end
end
