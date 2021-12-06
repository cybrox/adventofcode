input =
  "./6.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)
  |> Enum.reduce([0, 0, 0, 0, 0, 0, 0, 0, 0], fn x, acc -> List.update_at(acc, x, &(&1 + 1)) end)

defmodule Solution do
  def evolve(ages, limit), do: evolve(ages, limit, 0)
  def evolve(ages, limit, round) when round >= limit, do: Enum.sum(ages)

  def evolve([a, b, c, d, e, f, g, h, i], limit, round),
    do: evolve([b, c, d, e, f, g, h + a, i, a], limit, round + 1)
end

# Since there are a finite number of possible age states for each fish, we switch to
# shifting through these age states, instead of growing the array, as I do not have
# >1.5TB of memory available on my machine.

days = 256
IO.puts("There are #{Solution.evolve(input, days)} fish after #{days} days")
