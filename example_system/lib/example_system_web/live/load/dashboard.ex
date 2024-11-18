defmodule ExampleSystemWeb.Load.Dashboard do
  use ExampleSystemWeb, :live_view
  import ExampleSystemWeb.LoadHTML

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "Dashboard LiveView mounting (subscribes to Metrics). PID is")

    if connected?(socket) do
      IO.inspect(self(), label: "Dashboard LiveView mouting - socket connected!")
    end

    {:ok,
     assign(socket,
       load: to_form_data(LoadControl.load()),
       schedulers: to_form_data(:erlang.system_info(:schedulers_online)),
       metrics: ExampleSystem.Metrics.subscribe(),
       data: %{},
       highlighted: nil
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("change_load", %{"data" => %{"value" => load}}, socket) do
    with {load, ""} when load >= 0 <- Integer.parse(load) do
      Task.start_link(fn -> LoadControl.change_load(load) end)
      {:noreply, assign(socket, :load, to_form_data(load))}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("change_schedulers", %{"data" => %{"value" => schedulers}}, socket) do
    with {schedulers, ""} when schedulers > 0 <- Integer.parse(schedulers) do
      Task.start_link(fn -> LoadControl.change_schedulers(schedulers) end)
      {:noreply, assign(socket, :schedulers, to_form_data(schedulers))}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("reset", _params, socket) do
    me = self()

    Task.start_link(fn ->
      ExampleSystem.Metrics.subscribe()

      LoadControl.change_load(0)

      fn -> ExampleSystem.Metrics.await_next() end
      |> Stream.repeatedly()
      |> Stream.drop_while(&(&1.jobs_rate > 0))
      |> Enum.take(1)

      LoadControl.change_schedulers(1)
      Process.sleep(1000)

      send(me, :clear_history)
    end)

    {:noreply, socket}
  end

  def handle_event("highlight_" <> what, _params, socket) do
    highlighted = if socket.assigns.highlighted == what, do: nil, else: what
    {:noreply, assign(socket, :highlighted, highlighted)}
  end

  @impl Phoenix.LiveView
  def handle_info({:metrics, metrics}, socket), do: {:noreply, assign(socket, :metrics, metrics)}

  def handle_info(:clear_history, socket) do
    ExampleSystem.Metrics.clear_history()

    {:noreply,
     assign(socket,
       load: to_form_data(LoadControl.load()),
       schedulers: to_form_data(:erlang.system_info(:schedulers_online))
     )}
  end

  defp to_form_data(value) do
    %{"value" => to_string(value)}
  end

  defp highlight_class(a, a), do: "highlight"
  defp highlight_class(_, _), do: ""
end
