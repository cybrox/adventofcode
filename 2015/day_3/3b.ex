input =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("", trim: true)

defmodule Solution do
  def gift_to_both(list), do: gift_to_both(list, [], [])
  def gift_to_both([a, b | t], l1, l2), do: gift_to_both(t, l1 ++ [a], l2 ++ [b])
  def gift_to_both([a | t], l1, l2), do: gift_to_both(t, l1 ++ [a], l2)
  def gift_to_both([], l1, l2), do: count_unique(gift_to(l1) ++ gift_to(l2))

  defp count_unique(l), do: l |> Enum.uniq() |> Enum.count()

  defp gift_to(list), do: gift_to(list, 0, 0, [])
  defp gift_to([], x, y, l), do: [[x, y] | l]
  defp gift_to([h | t], x, y, l), do: gift_to(t, new_x(h, x), new_y(h, y), [[x, y] | l])

  defp new_x("<", x), do: x - 1
  defp new_x(">", x), do: x + 1
  defp new_x(_, x), do: x

  defp new_y("v", y), do: y - 1
  defp new_y("^", y), do: y + 1
  defp new_y(_, y), do: y
end

IO.puts("Santas delivered a present to #{Solution.gift_to_both(input)} houses")
