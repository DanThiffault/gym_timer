defmodule GymTimerUiWeb.TimerLive do
  use GymTimerUiWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    socket = assign_current_time(socket)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    socket = assign_current_time(socket)

    {:noreply, socket}
  end

  def assign_current_time(socket) do
    clock = GymTimerUiWeb.Clock.val()

    assign(socket, clock: clock)
  end
end
