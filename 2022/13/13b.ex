lines =
  "./13.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.filter(&(&1 != ""))

defmodule Solution do
  @dividers [[[2]], [[6]]]

  def find_dividers(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.concat(@dividers)
    |> Enum.sort(&in_order?/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {v, _i} -> v in @dividers end)
    |> Enum.map(fn {_v, i} -> i end)
    |> Enum.reduce(&(&1 * &2))
  end

  defp parse_line(line), do: Code.eval_string(line) |> elem(0)

  defp in_order?(l, l) when is_integer(l), do: :next
  defp in_order?(l, r) when is_integer(l) and is_integer(r), do: l < r
  defp in_order?(l, r) when is_integer(l) and not is_integer(r), do: in_order?([l], r)
  defp in_order?(l, r) when not is_integer(l) and is_integer(r), do: in_order?(l, [r])
  defp in_order?(l, r) when is_list(l) and is_list(r), do: in_order_list?(l, r)

  defp in_order_list?([], []), do: :next
  defp in_order_list?([], _r), do: true
  defp in_order_list?(_l, []), do: false
  defp in_order_list?([lh | lt], [rh | rt]), do: in_order_list_result(in_order?(lh, rh), lt, rt)

  defp in_order_list_result(:next, lt, rt), do: in_order_list?(lt, rt)
  defp in_order_list_result(result, _, _), do: result
end

IO.puts("The product of indices of divider packets is #{Solution.find_dividers(lines)}")
