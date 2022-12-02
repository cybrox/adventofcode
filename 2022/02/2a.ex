lines =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn turn -> turn |> String.split(" ") end)

defmodule Solution do
  def count_points(turns), do: Enum.reduce(turns, 0, fn t, acc -> acc + points_for(t) end)

  defp points_for(["A", "X"]), do: 1 + 3
  defp points_for(["A", "Y"]), do: 2 + 6
  defp points_for(["A", "Z"]), do: 3 + 0
  defp points_for(["B", "X"]), do: 1 + 0
  defp points_for(["B", "Y"]), do: 2 + 3
  defp points_for(["B", "Z"]), do: 3 + 6
  defp points_for(["C", "X"]), do: 1 + 6
  defp points_for(["C", "Y"]), do: 2 + 0
  defp points_for(["C", "Z"]), do: 3 + 3
end

defmodule Solution2 do
  def count_points(turns), do: Enum.reduce(turns, 0, fn t, acc -> acc + points_for(t) end)

  defp points_for([<<x::8>>, <<y::8>>]), do: points_for2(x - (?A - 1), y - (?A - 1) - (?X - ?A))
  defp points_for2(x, y), do: points_for2(x, y, y - x)
  defp points_for2(_, y, 0), do: 3 + y
  defp points_for2(_, y, 1), do: 6 + y
  defp points_for2(_, y, -2), do: 6 + y
  defp points_for2(_, y, _), do: 0 + y
end

IO.puts("your final score is #{Solution.count_points(lines)}")
IO.puts("your final score is #{Solution2.count_points(lines)}")
