lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule Solution do
  def reduced(l), do: reduced(l, 0)

  def reduced([a, b, c, d | t], acc),
    do: reduced([b, c, d] ++ t, acc + sunk(a + b + c, b + c + d))

  def reduced(_, acc), do: acc

  defp sunk(from, to) do
    if from < to, do: 1, else: 0
  end
end

IO.puts("sunk #{Solution.reduced(lines)} times")
