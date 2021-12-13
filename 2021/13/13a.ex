[input_points, input_rules] =
  "./13.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)

points =
  input_points
  |> String.split("\n")
  |> Enum.map(fn line ->
    [x, y] = String.split(line, ",")
    {String.to_integer(x), String.to_integer(y)}
  end)

rules =
  input_rules
  |> String.split("\n")
  |> Enum.map(fn line ->
    [dir, n] =
      line
      |> String.replace("fold along ", "")
      |> String.split("=")

    {dir, String.to_integer(n)}
  end)

defmodule Solution do
  def fold(points, []), do: clean_count(points)
  def fold(points, [h | t]), do: fold(fold_field(points, h), t)

  defp fold_field(field, {"x", at}), do: Enum.map(field, &fold_px(&1, at))
  defp fold_field(field, {"y", at}), do: Enum.map(field, &fold_py(&1, at))

  defp fold_px({x, y}, at) when x < at, do: {x, y}
  defp fold_px({x, y}, at), do: {at - (x - at), y}
  defp fold_py({x, y}, at) when y < at, do: {x, y}
  defp fold_py({x, y}, at), do: {x, at - (x - at), y}

  defp clean_count(field) do
    field
    |> Enum.uniq()
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 end)
    |> Enum.count()
  end
end

IO.puts("There are #{Solution.fold(points, [Enum.at(rules, 0)])} points after a fold")
