[stack, ops] =
  "./5.input.txt"
  |> File.read!()
  |> String.split("\n\n", trim: true)
  |> Enum.map(&String.split(&1, "\n"))

defmodule Solution do
  def process(stack, ops) do
    stack = parse_stack(stack)
    ops = parse_ops(ops)

    stack |> move_around(ops) |> get_top()
  end

  defp move_around(stack, []), do: stack

  defp move_around(stack, [[n, s, d] | t]) do
    source_rest = stack |> Map.get(s, []) |> Enum.slice(n..-1)
    source_taken = stack |> Map.get(s, []) |> Enum.slice(0..(n - 1)) |> Enum.reverse()

    new_stack =
      stack
      |> Map.put(s, source_rest)
      |> Map.put(d, source_taken ++ Map.get(stack, d, []))

    move_around(new_stack, t)
  end

  defp get_top(stack), do: Enum.map(stack, fn {_, v} -> Enum.at(v, 0) end) |> Enum.join("")

  defp parse_stack(stack) do
    stack
    |> Enum.map(&parse_stack_line/1)
    |> List.flatten()
    |> Enum.reduce(%{}, fn {v, s}, acc ->
      Map.put(acc, s, Map.get(acc, s, []) ++ [v])
    end)
  end

  defp parse_stack_line(line) do
    line
    |> String.split("")
    |> Enum.with_index()
    |> Enum.filter(fn {v, _} -> v != "" end)
    |> Enum.filter(fn {<<v::8>>, _} -> v >= ?A and v <= ?Z end)
    |> Enum.map(fn {v, i} -> {v, floor((i + 2) / 4)} end)
  end

  defp parse_ops(ops) do
    ops
    |> Enum.map(&parse_op_line/1)
    |> Enum.filter(&(&1 != []))
  end

  defp parse_op_line(line) do
    line
    |> String.replace(~r/[a-z]/, "")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

IO.puts("The top crates are #{Solution.process(stack, ops)}")
