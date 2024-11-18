import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/example_system start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :example_system, ExampleSystemWeb.Endpoint, server: true
end

port = System.get_env("PHX_PORT", "4000") |> String.to_integer


# The secret key base is used to sign/encrypt cookies and other secrets.
# A default value is used in config/dev.exs and config/test.exs but you
# want to use a different value for prod and you most likely don't want
# to check this value into version control, so we use an environment
# variable instead.
secret_key_base =
  System.get_env("SECRET_KEY_BASE") || "Rsbn7aXVk/DTt2Ehsq6E0mhF0mQz+DjXumVrjdxezDqFgvoOgTjwoh9VR4Mjf+Vj"

config :example_system, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

config :example_system, ExampleSystemWeb.Endpoint,
  http: [port: port],
  secret_key_base: secret_key_base
