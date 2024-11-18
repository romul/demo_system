defmodule Mix.Tasks.ExampleSystem.Observer do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    node_longname = [System.get_env("NODE_NAME", "example_system"), get_hostname()] |> Enum.join("@") |> String.to_atom()
    Node.start(:observer, :shortnames)
    Node.set_cookie(get_cookie())
    true = Node.connect(node_longname)

    :observer.start()
    :timer.sleep(:infinity)
  end

  defp get_cookie() do
    File.read!("_build/prod/rel/example_system/releases/COOKIE") |> String.to_atom
  end

  defp get_hostname() do
    :net_adm.localhost() |> to_string |> String.split(".") |> List.first
  end
end
