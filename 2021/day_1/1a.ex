lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule Solution do
  def reduced(l), do: reduced(l, 0)
  def reduced([_ | []], a), do: a
  def reduced([h | t], a), do: reduced(t, a + sunk(h, Enum.at(t, 0)))

  defp sunk(from, to) do
    if from < to, do: 1, else: 0
  end
end

IO.puts("sunk #{Solution.reduced(lines)} times")
