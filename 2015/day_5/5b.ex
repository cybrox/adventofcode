input =
  "./5.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  def filter_nice(list), do: filter_nice(list, 0)
  def filter_nice([], acc), do: acc
  def filter_nice([h | t], acc), do: filter_nice(t, acc + is_nice(h))

  defp is_nice(str) do
    slist = String.split(str, "", trim: true)
    if has_pair?(slist) and has_repeat?(slist), do: 1, else: 0
  end

  defp has_pair?(str), do: has_pair?(str, [])
  defp has_pair?([a, b | t], l), do: has_pair?([b | t], ["#{a}#{b}" | l])
  defp has_pair?(_, l), do: eval_pairs(l)

  defp eval_pairs(l) do
    l
    |> Enum.dedup()
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.max()
    |> Kernel.>(1)
  end

  defp has_repeat?(str), do: has_repeat?(str, false)
  defp has_repeat?([a, _, c | _], _) when a == c, do: true
  defp has_repeat?([_, b, c | t], _), do: has_repeat?([b, c | t], false)
  defp has_repeat?(_, found), do: found
end

IO.puts("There are #{Solution.filter_nice(input)} nice strings")
