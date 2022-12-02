lines =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn turn -> turn |> String.split(" ") end)

defmodule Solution do
  def count_points(turns), do: Enum.reduce(turns, 0, fn t, acc -> acc + points_for(t) end)

  defp points_for(["A", "X"]), do: 0 + 3
  defp points_for(["A", "Y"]), do: 3 + 1
  defp points_for(["A", "Z"]), do: 6 + 2
  defp points_for(["B", "X"]), do: 0 + 1
  defp points_for(["B", "Y"]), do: 3 + 2
  defp points_for(["B", "Z"]), do: 6 + 3
  defp points_for(["C", "X"]), do: 0 + 2
  defp points_for(["C", "Y"]), do: 3 + 3
  defp points_for(["C", "Z"]), do: 6 + 1
end

defmodule Solution2 do
  def count_points(turns), do: Enum.reduce(turns, 0, fn t, acc -> acc + points_for(t) end)

  defp points_for([<<x::8>>, <<y::8>>]), do: points_for2(x - (?A - 1), y - ?A - (?X - ?A))
  defp points_for2(x, r), do: counter_for(x, r) + r * 3
  defp counter_for(x, 0), do: Enum.at([0, 3, 1, 2], x)
  defp counter_for(x, 1), do: x
  defp counter_for(x, 2), do: Enum.at([0, 2, 3, 1], x)
end

IO.puts("your final score is #{Solution.count_points(lines)}")
IO.puts("your final score is #{Solution2.count_points(lines)}")
