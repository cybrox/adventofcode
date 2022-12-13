lines =
  "./13.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.split(&1, "\n", trim: true))

defmodule Solution do
  def find_sum(lines) do
    lines
    |> Enum.with_index(1)
    |> Enum.map(fn {[left, right], i} ->
      {i, in_order?(parse_line(left), parse_line(right))}
    end)
    |> Enum.filter(fn {_i, v} -> v end)
    |> Enum.map(fn {i, _v} -> i end)
    |> Enum.sum()
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

IO.puts("The sum of indices in the right order is #{Solution.find_sum(lines)}")
