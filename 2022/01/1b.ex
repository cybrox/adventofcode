lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n\n", trim: true)
  |> Enum.map(fn elf -> elf |> String.split("\n") |> Enum.map(&String.to_integer/1) end)

defmodule Solution do
  def max_elfs(list), do: max_elfs(list, [0, 0, 0])
  def max_elfs([], maxs), do: Enum.sum(maxs)
  def max_elfs([h | t], maxs), do: max_elfs(t, put_elf_sum(maxs, Enum.sum(h)))

  defp put_elf_sum([a, b, c], n), do: [a, b, c, n] |> Enum.sort(&(&1 >= &2)) |> Enum.slice(0..2)
end

defmodule Solution2 do
  def max_elfs(list),
    do: list |> Enum.map(&Enum.sum/1) |> Enum.sort(&(&1 >= &2)) |> Enum.slice(0..2) |> Enum.sum()
end

IO.puts("max 3 elfs are carrying #{Solution.max_elfs(lines)} calories")
IO.puts("max 3 elfs are carrying #{Solution2.max_elfs(lines)} calories")
