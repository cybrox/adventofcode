[input_chain, input_rules] =
  "./14.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)

chain = String.split(input_chain, "", trim: true)

rules =
  input_rules
  |> String.split("\n")
  |> Enum.map(fn line ->
    [from, to] = String.split(line, " -> ")
    {String.split(from, "", trim: true), to}
  end)

defmodule Solution do
  def analyze(chain, rules, times) do
    occurences =
      grow(chain, rules, times)
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
      |> Enum.sort(fn {_, v1}, {_, v2} -> v1 >= v2 end)

    most = occurences |> Enum.at(0) |> elem(1)
    least = occurences |> Enum.take(-1) |> Enum.at(0) |> elem(1)

    most - least
  end

  defp grow(chain, rules, times), do: grow(chain, rules, times, 0)
  defp grow(chain, _, times, n) when n >= times, do: chain
  defp grow(chain, rules, times, n), do: grow(replace(chain, rules), rules, times, n + 1)

  defp replace(chain, rules), do: replace(chain, [Enum.at(chain, 0)], rules)
  defp replace([a, b | t], acc, rules), do: replace([b | t], acc ++ repl(a, b, rules), rules)
  defp replace(_, acc, _), do: acc

  defp repl(_, b, []), do: [b]

  defp repl(a, b, [{[na, nb], to} | t]) do
    if a == na and b == nb, do: [to, b], else: repl(a, b, t)
  end
end

IO.puts("Most common occurence minus least common is #{Solution.analyze(chain, rules, 10)}")
