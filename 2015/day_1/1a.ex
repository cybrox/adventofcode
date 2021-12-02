input =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("", trim: true)

defmodule Solution do
  def traverse(list), do: traverse(list, 0)
  def traverse([], f), do: f
  def traverse(["(" | t], f), do: traverse(t, f + 1)
  def traverse([")" | t], f), do: traverse(t, f - 1)
end

IO.puts("Santa ended up on floor #{Solution.traverse(input)}")
