defmodule ExampleSystem.Top do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def subscribe(), do: GenServer.call(__MODULE__, :subscribe)

  @impl GenServer
  def init(_) do
    Process.send_after(self(), :notify_subscribers, 1_000)

    {:ok, %{subscribers: MapSet.new(), top: []}}
  end

  @impl GenServer
  def handle_call(:subscribe, {pid, _ref}, state) do
    Process.monitor(pid)
    {:reply, state.top, update_in(state.subscribers, &MapSet.put(&1, pid))}
  end

  @impl GenServer
  def handle_info(:notify_subscribers, state) do
    new_top = Runtime.top(:timer.seconds(1))
    Enum.each(state.subscribers, &send(&1, {:top, new_top}))
    Process.send_after(self(), :notify_subscribers, 1_000)

    {:noreply, %{state | top: new_top}}
  end

  def handle_info({:DOWN, _mref, :process, pid, _reason}, state),
    do: {:noreply, update_in(state.subscribers, &MapSet.delete(&1, pid))}

end
