defmodule GymTimerFirmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    VintageNetWizard.run_wizard(on_exit: {__MODULE__, :handle_wizard_exit, []})

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GymTimerFirmware.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: GymTimerFirmware.Worker.start_link(arg)
        # ,
        # {GymTimerFirmware.Worker}
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def handle_on_exit() do
    # new_config =
    #  Application.get_env(:gym_timer_ui, GymTimerUiWeb.Endpoint) |> Keyword.put(:server, true)

    # Application.put_env(:gym_timer_ui, GymTimerUiWeb.Endpoint, new_config, persistent: true)
    # Application.stop(:gym_timer_ui)
    # Application.ensure_all_started(:gym_timer_ui)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: GymTimerFirmware.Worker.start_link(arg)
      # {GymTimerFirmware.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: GymTimerFirmware.Worker.start_link(arg)
      # {GymTimerFirmware.Worker, arg},
      #      GymTimerFirmware.Box
    ]
  end

  def target() do
    Application.get_env(:gym_timer_firmware, :target)
  end
end
