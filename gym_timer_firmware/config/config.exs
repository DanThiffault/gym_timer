# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :gym_timer_firmware, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1606057517"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack, :nerves_ssh],
  app: Mix.Project.config()[:app]

if Mix.target() != :host do
  import_config "target.exs"
end

config :tzdata, :data_dir, "/root/storage"

config :gym_timer_ui, GymTimerUiWeb.Endpoint,
  # Nerves root filesystem is read-only, so disable the code reloader
  code_reloader: false,
  http: [port: 80],
  # Use compile-time Mix config instead of runtime environment variables
  load_from_system_env: false,
  # Start the server since we're running in a release instead of through `mix`
  server: true,
  url: [host: "gym_timer.local", port: 80],
  secret_key_base: "UB31SyWoXqhUbvYQ30YPrdQ4m133/2aPvhUkPka6LI1QBqOWVwBM7el5imZ1+fF5",
  render_errors: [view: GymTimerUiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GymTimerUi.PubSub,
  live_view: [signing_salt: "h2XE/BM1"]

config :blinkchain, canvas: {30, 2}, dma_channel: 9

config :blinkchain, :channel0,
  pin: 18,
  type: :rgb,
  brightness: 100,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 0},
      count: 30,
      direction: :right
    }
  ]

config :blinkchain, :channel1,
  pin: 13,
  type: :rgb,
  brightness: 100,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 1},
      count: 30,
      direction: :right
    }
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nerves_time, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
]
