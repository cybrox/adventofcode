input =
  "./5.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " -> "))
  |> Enum.map(fn [f, t] ->
    [fx, fy] = String.split(f, ",")
    [tx, ty] = String.split(t, ",")

    {
      {String.to_integer(fx), String.to_integer(fy)},
      {String.to_integer(tx), String.to_integer(ty)}
    }
  end)

defmodule Solution do
  def map_vents(input) do
    input
    |> Enum.map(&points_for/1)
    |> List.flatten()
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Enum.filter(fn {_, v} -> v >= 2 end)
    |> Enum.count()
  end

  defp points_for({{fx, fy}, {tx, ty}}) when fx == tx, do: points_v(fx, fy, ty)
  defp points_for({{fx, fy}, {tx, ty}}) when fy == ty, do: points_h(fy, fx, tx)
  defp points_for(_), do: []

  defp points_v(x, y1, y2), do: Enum.map(y1..y2, &{x, &1})
  defp points_h(y, x1, x2), do: Enum.map(x1..x2, &{&1, y})
end

IO.puts("There are #{Solution.map_vents(input)} very dangerous points")
