lines =
  "./3.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  def find_badges(rucksacks) do
    rucksacks
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.chunk_every(3)
    |> Enum.map(fn [r1, r2, r3] ->
      r1 |> Enum.filter(fn i -> Enum.member?(r2, i) and Enum.member?(r3, i) end) |> Enum.uniq()
    end)
    |> List.flatten()
    |> Enum.map(&prio_for/1)
    |> Enum.sum()
  end

  defp prio_for(<<char::8>>) when char >= ?A and char <= ?Z, do: char - ?A + 27
  defp prio_for(<<char::8>>) when char >= ?a and char <= ?z, do: char - ?a + 1
  defp prio_for(_), do: 0
end

IO.puts("Priority sum of all basge items in rucksacks is #{Solution.find_badges(lines)}")
