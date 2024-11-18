import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :example_system, ExampleSystemWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JL4c7Q7dqI7U9rsUXOvjaHhGX8K9qYH87INr7dTIMB7+wUC/xYs/GsRQx6ChrdD2",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
