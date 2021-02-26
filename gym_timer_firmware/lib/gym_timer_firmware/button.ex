defmodule GymTimerFirmware.Button do
  use GenServer

  require Logger

  @moduledoc """
  This GenServer starts the wizard if a button is depressed for long enough.
  """

  alias Circuits.GPIO

  @doc """
  Start the button monitor
  Pass an index to the GPIO that's connected to the button.
  """
  @spec start_link(non_neg_integer()) :: GenServer.on_start()
  def start_link(gpio_pin) do
    GenServer.start_link(__MODULE__, gpio_pin)
  end

  @impl GenServer
  def init(gpio_pin) do
    {:ok, gpio} = GPIO.open(gpio_pin, :input)
    :ok = GPIO.set_interrupts(gpio, :both)
    {:ok, %{pin: gpio_pin, gpio: gpio}}
  end

  @impl GenServer
  def handle_info({:circuits_gpio, gpio_pin, _timestamp, 1}, %{pin: gpio_pin} = state) do
    # Button pressed. Start a timer to launch the wizard when it's long enough

    Logger.info('button push')
    {:noreply, state, 5_000}
  end

  def handle_info({:circuits_gpio, gpio_pin, _timestamp, 0}, %{pin: gpio_pin} = state) do
    # Button released. The GenServer timer is implicitly cancelled by receiving this message.
    Logger.info('button released')
    {:noreply, state}
  end

  def handle_info(:timeout, state) do
    config =
      Application.get_env(:gym_timer_ui, GymTimerUiWeb.Endpoint) |> Keyword.merge(server: false)

    Application.put_env(:gym_timer_ui, GymTimerUiWeb.Endpoint, config)

    Application.stop(:gym_timer_ui)

    Application.start(:gym_timer_ui)

    :ok = VintageNetWizard.run_wizard(on_exit: {__MODULE__, :handle_wizard_exit, []})

    Logger.info('button timeout')

    {:noreply, state}
  end

  def handle_wizard_exit() do
    Logger.info("handle_on_exit")

    config =
      Application.get_env(:gym_timer_ui, GymTimerUiWeb.Endpoint) |> Keyword.merge(server: true)

    Application.put_env(:gym_timer_ui, GymTimerUiWeb.Endpoint, config)

    Application.stop(:gym_timer_ui)
    Application.start(:gym_timer_ui)
  end
end
