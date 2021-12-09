input =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("", trim: true)

defmodule Solution do
  def traverse(list), do: traverse(list, 0, 1)
  def traverse([], _, _), do: -1
  def traverse(_, -1, n), do: n - 1
  def traverse(["(" | t], f, n), do: traverse(t, f + 1, n + 1)
  def traverse([")" | t], f, n), do: traverse(t, f - 1, n + 1)
end

IO.puts("Santa ended up in the basement at char #{Solution.traverse(input)}")
