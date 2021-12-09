input =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end)

defmodule Solution do
  def paperfor(list), do: paperfor(list, 0)
  def paperfor([], acc), do: acc

  def paperfor([[a, b, c] | t], acc),
    do: paperfor(t, acc + 2 * a + 2 * b + a * b * c)
end

IO.puts("The elves use a total of #{Solution.paperfor(input)}ft")
