input =
  "./10.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

defmodule Solution do
  @match %{"(" => ")", "[" => "]", "{" => "}", "<" => ">"}
  @score %{")" => 1, "]" => 2, "}" => 3, ">" => 4}
  @opens Map.keys(@match)

  def complete_lines(input), do: complete_lines(input, [])
  def complete_lines([], acc), do: middle_score(acc)
  def complete_lines([h | t], acc), do: complete_lines(t, [find_errors(h, []) | acc])

  defp find_errors([], []), do: nil
  defp find_errors([], stack), do: complete_stack(stack, 0)
  defp find_errors([h | t], stack) when h in @opens, do: find_errors(t, [h | stack])

  defp find_errors([h | t], [c | s]) do
    if @match[c] == h, do: find_errors(t, s), else: nil
  end

  defp complete_stack([], acc), do: acc
  defp complete_stack([h | t], acc), do: complete_stack(t, acc * 5 + @score[@match[h]])

  defp middle_score(s), do: s |> Enum.filter(&(&1 != nil)) |> Enum.sort() |> middle_pick()
  defp middle_pick(s), do: Enum.at(s, trunc(Float.floor(Enum.count(s) / 2)))
end

IO.puts("The current autocomplete score is #{Solution.complete_lines(input)}")
