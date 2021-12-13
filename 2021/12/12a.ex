input =
  "./12.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "-"))

# Map input into a list of possible branches for each position
# Each traversal listed in the input is possible in both directions!
input =
  Enum.reduce(input, %{}, fn [f, t], acc ->
    acc
    |> Map.update(f, [t], &[t | &1])
    |> Map.update(t, [f], &[f | &1])
  end)

defmodule Solution do
  def number_of_paths(rules), do: traverse(rules) |> List.flatten() |> Enum.count(&(&1 == 1))

  defp traverse(rules), do: traverse(rules, "start", [], 0)
  defp traverse(_, "end", _, _), do: 1
  defp traverse(_, "start", [_, _], paths), do: paths

  defp traverse(rules, item, acc, paths) do
    if small_cave?(item) and item in acc do
      paths
    else
      Enum.map(rules[item], &traverse(rules, &1, [item | acc], paths))
    end
  end

  defp small_cave?(x) do
    a = :binary.first(x)
    a >= ?a and a <= ?z
  end
end

IO.puts("There are #{Solution.number_of_paths(input)} possible paths")
