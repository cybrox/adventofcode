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
    {_, chars} = grow({pairs(chain), chars(chain)}, rules, times)
    occurences = Enum.sort(chars, fn {_, v1}, {_, v2} -> v1 >= v2 end)

    most = occurences |> Enum.at(0) |> elem(1)
    least = occurences |> Enum.take(-1) |> Enum.at(0) |> elem(1)

    most - least
  end

  defp pairs(chain), do: pairs(chain, %{})
  defp pairs([a, b | t], acc), do: pairs([b | t], Map.update(acc, "#{a}#{b}", 1, &(&1 + 1)))
  defp pairs(_, acc), do: acc

  defp chars(chain), do: chars(chain, %{})
  defp chars([h | t], acc), do: chars(t, Map.update(acc, h, 1, &(&1 + 1)))
  defp chars([], acc), do: acc

  defp grow({pairs, chars}, rules, times), do: grow({pairs, chars}, rules, times, 0)
  defp grow({pairs, chars}, _, times, n) when n >= times, do: {pairs, chars}

  defp grow({pairs, chars}, rules, times, n),
    do: grow(replace(pairs, {pairs, chars}, rules), rules, times, n + 1)

  defp replace(list, pc, [h | t]), do: replace(list, apply_rule(list, pc, h), t)
  defp replace(_, pc, []), do: pc

  defp apply_rule(list, {pairs, chars}, {[a, b], c}),
    do: add_to_lists(pairs, chars, a, b, c, Map.get(list, "#{a}#{b}", 0))

  defp add_to_lists(pairs, chars, _, _, _, n) when n == 0, do: {pairs, chars}

  defp add_to_lists(pairs, chars, a, b, c, n) do
    new_pairs =
      pairs
      |> Map.update("#{a}#{b}", 0, &(&1 - n))
      |> Map.update("#{a}#{c}", n, &(&1 + n))
      |> Map.update("#{c}#{b}", n, &(&1 + n))

    new_chars = Map.update(chars, c, n, &(&1 + n))
    {new_pairs, new_chars}
  end
end

IO.puts("Most common occurence minus least common is #{Solution.analyze(chain, rules, 40)}")
