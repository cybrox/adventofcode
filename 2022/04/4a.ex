lines =
  "./4.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, ","))

defmodule Solution do
  def find_full_overlaps(pairs) do
    pairs
    |> Enum.map(&find_full_overlap/1)
    |> Enum.filter(&fully/1)
    |> Enum.count()
  end

  defp find_full_overlap(pair), do: Enum.map(pair, &get_range/1)

  defp get_range(input), do: input |> String.split("-") |> Enum.map(&String.to_integer/1)

  defp fully([[af, at], [bf, bt]]) when af >= bf and at <= bt, do: true
  defp fully([[af, at], [bf, bt]]) when bf >= af and bt <= at, do: true
  defp fully([[_, _], [_, _]]), do: false
end

IO.puts("There are #{Solution.find_full_overlaps(lines)} full overlaps")
