lines =
  "./4.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, ","))

defmodule Solution do
  def find_overlaps(pairs) do
    pairs
    |> Enum.map(&find_overlap/1)
    |> Enum.filter(&partial/1)
    |> Enum.count()
  end

  defp find_overlap(pair), do: Enum.map(pair, &get_range/1)

  defp get_range(input), do: input |> String.split("-") |> Enum.map(&String.to_integer/1)

  defp partial([[af, at], [bf, bt]]) when at < bf or bt < af, do: false
  defp partial([[af, at], [bf, bt]]) when af > bt or bf > at, do: false
  defp partial([[_, _], [_, _]]), do: true
end

IO.puts("There are #{Solution.find_overlaps(lines)} overlaps")
