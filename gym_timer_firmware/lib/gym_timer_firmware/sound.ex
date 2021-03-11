defmodule GymTimerFirmware.Sound do
  use GenServer

  require Logger

  @moduledoc """
  This Genserver controls the AdaFruit Sound FX board
  """

  alias Circuits.UART

  @doc """
  Start the sound monitor
  """
  @spec start_link(non_neg_integer()) :: GenServer.on_start()
  def start_link(serial_port) do
    GenServer.start_link(__MODULE__, serial_port, name: __MODULE__)
  end

  def play_sound(sound_file) do
    GenServer.call(__MODULE__, {:play_sound, sound_file})
  end

  def list_files() do
    GenServer.call(__MODULE__, :list_files)
  end

  def increase_volume do
    GenServer.call(__MODULE__, {:change_volume, "+"})
  end

  def decrease_volume do
    GenServer.call(__MODULE__, {:change_volume, "-"})
  end

  @impl GenServer
  def init(serial_port) do
    {:ok, uart_pid} = UART.start_link()
    UART.open(uart_pid, serial_port, speed: 9600, active: true)

    {:ok, %{uart_pid: uart_pid}}
  end

  @impl true
  def handle_call({:play_sound, sound_file}, _from, state = %{uart_pid: pid}) do
    case sound_file do
      :count_in ->
        UART.write(pid, "\n#6\n")

      :rest ->
        UART.write(pid, "\n#10\n")

      :work ->
        UART.write(pid, "\n#7\n")

      :go ->
        UART.write(pid, "\n#8\n")

      :end_time ->
        UART.write(pid, "\n#9\n")
    end

    UART.write(pid, "\n##{sound_file}\n")
    {:reply, state, state}
  end

  @impl true
  def handle_call(:list_files, _from, state = %{uart_pid: pid}) do
    UART.write(pid, "\nL\n")
    {:reply, state, state}
  end

  @impl true
  def handle_call({:change_volume, volume_amount}, _from, state = %{uart_pid: pid}) do
    Enum.each(0..8, fn i -> UART.write(pid, "\n#{volume_amount}\n") end)
    {:reply, state, state}
  end

  def handle_info({:circuits_uart, _port, output}, state) do
    Logger.info(output)
    {:noreply, state}
  end
end
