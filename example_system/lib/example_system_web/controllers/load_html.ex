defmodule ExampleSystemWeb.LoadHTML do
  use ExampleSystemWeb, :html

  embed_templates "load_html/*"

  defp data_points(graph) do
    graph.data_points
    |> Stream.map(&"#{x(&1.x)},#{y(&1.y)}")
    |> Enum.join(" ")
  end

  defp x(relative_x), do: min(round(relative_x * graph_width()), graph_width())
  defp y(relative_y), do: graph_height() - min(round(relative_y * graph_height()), graph_height())

  defp graph_width(), do: 600
  defp graph_height(), do: 500
end
