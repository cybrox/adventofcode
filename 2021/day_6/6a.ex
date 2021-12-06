input =
  "./6.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule Solution do
  def evolve(fishes, limit), do: evolve(fishes, limit, 0)
  def evolve(fishes, limit, round) when round >= limit, do: Enum.count(fishes)
  def evolve(fishes, limit, round), do: evolve(evolve_fishes(fishes), limit, round + 1)

  defp evolve_fishes(fishes), do: fishes |> Enum.map(&evolve_fish/1) |> List.flatten()

  defp evolve_fish(0), do: [6, 8]
  defp evolve_fish(a), do: [a - 1]
end

days = 80
IO.puts("There are #{Solution.evolve(input, days)} fish after #{days} days")
