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
    cond do
      !has_vowels(str) -> 0
      !has_doubled(str) -> 0
      has_forbidden(str) -> 0
      true -> 1
    end
  end

  defp has_vowels(str) do
    chars = String.split(str, "", trim: true)
    Enum.count(chars, &(&1 in ["a", "e", "i", "o", "u"])) >= 3
  end

  defp has_doubled(str) do
    {found, _} =
      str
      |> String.split("", trim: true)
      |> Enum.reduce({false, ""}, fn x, {found, last} ->
        {found or x == last, x}
      end)

    found
  end

  defp has_forbidden(str) do
    String.match?(str, ~r/(ab|cd|pq|xy)/)
  end
end

IO.puts("There are #{Solution.filter_nice(input)} nice strings")
