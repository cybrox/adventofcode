input =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("", trim: true)

defmodule Solution do
  def gift_to(list), do: gift_to(list, 0, 0, [])
  def gift_to([], x, y, l), do: [[x, y] | l] |> Enum.uniq() |> Enum.count()
  def gift_to([h | t], x, y, l), do: gift_to(t, new_x(h, x), new_y(h, y), [[x, y] | l])

  defp new_x("<", x), do: x - 1
  defp new_x(">", x), do: x + 1
  defp new_x(_, x), do: x

  defp new_y("v", y), do: y - 1
  defp new_y("^", y), do: y + 1
  defp new_y(_, y), do: y
end

IO.puts("Santa delivered a present to #{Solution.gift_to(input)} houses")
