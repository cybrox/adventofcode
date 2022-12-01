lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)
  |> Enum.map(fn elf -> elf |> String.split("\n") |> Enum.map(&String.to_integer/1) end)

defmodule Solution do
  def max_elf(list), do: max_elf(list, 0)
  def max_elf([], max), do: max
  def max_elf([h | t], max), do: max_elf(t, Enum.max([max, Enum.sum(h)]))
end

defmodule Solution2 do
  def max_elf(list), do: list |> Enum.map(&Enum.sum/1) |> Enum.max()
end

IO.puts("max elf is carrying #{Solution.max_elf(lines)} calories")
IO.puts("max elf is carrying #{Solution2.max_elf(lines)} calories")
