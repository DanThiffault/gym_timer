defmodule GymTimerUiWeb.TimerLive do
  use GymTimerUiWeb, :live_view
  alias GymTimerUiWeb.Clock

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(100, self(), :tick)
    end

    socket =
      assign_current_time(socket)
      |> assign(:form, nil)
      |> assign(:count_in_input, 10)
      |> assign(:work_input, 30)
      |> assign(:rest_input, 30)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    socket = assign_current_time(socket)

    {:noreply, socket}
  end

  def handle_event("pause", _value, socket) do
    Clock.pause()

    {:noreply, socket}
  end

  def handle_event("unpause", _value, socket) do
    Clock.unpause()

    {:noreply, socket}
  end

  def handle_event("save_form_state", values, socket) do
    new_count_in = values |> Map.get("count_in_input", socket.assigns.count_in_input)
    new_work = values |> Map.get("work_input", socket.assigns.work_input)
    new_rest = values |> Map.get("rest_input", socket.assigns.rest_input)

    new_socket =
      socket
      |> assign(:count_in_input, new_count_in)
      |> assign(:work_input, new_work)
      |> assign(:rest_input, new_rest)

    {:noreply, new_socket}
  end

  def handle_event("count_up_form", _value, socket) do
    {:noreply, assign(socket, form: :count_up)}
  end

  def handle_event("interval_form", _value, socket) do
    {:noreply, assign(socket, form: :interval)}
  end

  def handle_event("count_up_mode", values, socket) do
    values |> Map.get("count_in_input", "3") |> String.to_integer() |> Clock.count_up_mode()
    {:noreply, assign(socket, form: nil)}
  end

  def handle_event("interval_mode", values, socket) do
    count_in = values |> Map.get("count_in_input", "3") |> String.to_integer()
    work_period = values |> Map.get("work_input", "30") |> String.to_integer()
    rest_period = values |> Map.get("rest_input", "30") |> String.to_integer()

    Clock.interval_mode(work_period, rest_period, count_in)
    {:noreply, assign(socket, form: nil)}
  end

  def handle_event("clock_mode", _value, socket) do
    Clock.clock_mode()
    {:noreply, assign(socket, form: nil)}
  end

  def handle_event("interval_mode", _value, socket) do
    Clock.interval_mode(30, 30, socket.count_in)
    {:noreply, socket}
  end

  def assign_current_time(socket) do
    state = %{clock: clock} = GymTimerUiWeb.Clock.val()
    paused = Map.has_key?(state, :pause_start)

    assign(socket, clock: clock, paused: paused)
  end
end
