defmodule ExampleSystemWeb.Math.Sum do
  use ExampleSystemWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, operations: [], data: data())}
  end

  @impl Phoenix.LiveView
  def handle_event("submit", %{"data" => %{"to" => str_input}}, socket) do
    {:noreply, start_sum(socket, str_input)}
  end

  @impl Phoenix.LiveView
  def handle_info({:sum, pid, sum}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, sum))}

  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket),
    do: {:noreply, update(socket, :operations, &set_result(&1, pid, :error))}

  defp start_sum(socket, str_input) do
    operation =
      case Integer.parse(str_input) do
        :error ->
          %{pid: nil, input: str_input, result: "invalid input"}

        {_input, remaining} when byte_size(remaining) > 0 ->
          %{pid: nil, input: str_input, result: "invalid input"}

        # FIXME: Uncomment to fix an endless calculation error
        # {input, ""} when input <= 0 ->
        #  %{pid: nil, input: input, result: "invalid input"}

        {input, ""} ->
          do_start_sum(input)
      end

    socket |> update(:operations, &[operation | &1]) |> assign(:data, data())
  end

  defp do_start_sum(input) do
    {:ok, pid} = ExampleSystem.Math.sum(input)
    %{pid: pid, input: input, result: :calculating}
  end

  defp set_result(operations, pid, result) do
    case Enum.split_with(operations, &match?(%{pid: ^pid, result: :calculating}, &1)) do
      {[operation], rest} -> [%{operation | result: result} | rest]
      _other -> operations
    end
  end

  defp data(), do: %{"to" => 0}
end
