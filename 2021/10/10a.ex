input =
  "./10.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

defmodule Solution do
  @match %{"(" => ")", "[" => "]", "{" => "}", "<" => ">"}
  @score %{")" => 3, "]" => 57, "}" => 1197, ">" => 25137}
  @opens Map.keys(@match)

  def error_score(input), do: error_score(input, [])
  def error_score([], acc), do: acc |> Enum.map(&Map.get(@score, &1, 0)) |> Enum.sum()
  def error_score([h | t], acc), do: error_score(t, [find_errors(h, []) | acc])

  defp find_errors([], stack), do: nil
  defp find_errors([h | t], stack) when h in @opens, do: find_errors(t, [h | stack])

  defp find_errors([h | t], [c | s]) do
    if @match[c] == h, do: find_errors(t, s), else: h
  end
end

IO.puts("The current total error score is #{Solution.error_score(input)}")
