defmodule Mix.Tasks.ExampleSystem.Upgrade do
  # Mix.Task behaviour is not in PLT since Mix is not a runtime dep, so we disable the warning
  @dialyzer :no_undefined_callbacks

  use Mix.Task

  def run(_args) do
    node_longname = [System.get_env("NODE_NAME", "example_system"), get_hostname()] |> Enum.join("@") |> String.to_atom() |> IO.inspect()
    Node.start(:upgrader, :shortnames)
    Node.set_cookie(get_cookie())
    true = Node.connect(node_longname)

    Enum.each(
      [ExampleSystemWeb.Math.Sum, ExampleSystem.Math],
      fn module ->
        :ok =
          File.cp!(
            "_build/prod/lib/example_system/ebin/#{module}.beam",
            "_build/prod/rel/example_system/lib/example_system-0.1.0/ebin/#{module}.beam"
          )

        {:module, ^module} = :rpc.call(node_longname, :code, :load_file, [module])
        :rpc.call(node_longname, :code, :purge, [module])
      end
    )

    Mix.Shell.IO.info("Upgrade finished successfully.")
  end

  defp get_cookie() do
    File.read!("_build/prod/rel/example_system/releases/COOKIE") |> String.to_atom
  end

  defp get_hostname() do
    :net_adm.localhost() |> to_string |> String.split(".") |> List.first
  end
end
