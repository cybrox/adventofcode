lines =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  def find_duplicates(rucksacks) do
    rucksacks
    |> Enum.map(fn rucksack ->
      rucksack |> String.split("", trim: true) |> Enum.chunk_every(floor(byte_size(rucksack) / 2))
    end)
    |> Enum.map(fn [left, right] ->
      left |> Enum.filter(&Enum.member?(right, &1)) |> Enum.uniq() |> Enum.map(&prio_for/1)
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  defp prio_for(<<char::8>>) when char >= ?A and char <= ?Z, do: char - ?A + 27
  defp prio_for(<<char::8>>) when char >= ?a and char <= ?z, do: char - ?a + 1
  defp prio_for(_), do: 0
end

IO.puts("Priority sum of all duplicate items in rucksacks is #{Solution.find_duplicates(lines)}")
