input =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end)

defmodule Solution do
  def paperfor(list), do: paperfor(list, 0)
  def paperfor([], acc), do: acc

  def paperfor([[l, w, h] | t], acc),
    do: paperfor(t, acc + 2 * l * w + 2 * w * h + 2 * h * l + slack([l, w, h]))

  defp slack(l) do
    [a, b, _] = Enum.sort(l)
    a * b
  end
end

IO.puts("The elves use a total of #{Solution.paperfor(input)}ft^2")
