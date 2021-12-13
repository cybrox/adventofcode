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
  def fold(points, []), do: clean_list(points)
  def fold(points, [h | t]), do: fold(fold_field(points, h), t)

  defp fold_field(field, {"x", at}), do: Enum.map(field, &fold_px(&1, at))
  defp fold_field(field, {"y", at}), do: Enum.map(field, &fold_py(&1, at))

  defp fold_px({x, y}, at) when x < at, do: {x, y}
  defp fold_px({x, y}, at), do: {at - (x - at), y}
  defp fold_py({x, y}, at) when y < at, do: {x, y}
  defp fold_py({x, y}, at), do: {x, at - (y - at)}

  defp clean_list(field) do
    field
    |> Enum.uniq()
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 end)
    |> Enum.map(fn {x, y} -> "#{x},#{y}" end)
    |> Enum.join("\n")
  end
end

# We just output all the visible points after completing all the folding
# operations, as the code expected as the puzzle solution is represented
# visually on the coordinate plane. - I used Google Sheets to view it.
IO.puts("The following points are visible after all folds:")
IO.puts(Solution.fold(points, rules))
