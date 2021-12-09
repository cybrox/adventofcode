input =
  "./7.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule Math do
  def median(list), do: get_median(Enum.sort(list), Enum.count(list))

  defp get_median(l, n) when rem(n, 2) == 0, do: get_avg_at(l, ceil_int(n / 2))
  defp get_median(l, n) when rem(n, 2) == 1, do: Enum.at(l, ceil_int(n / 2))

  defp get_avg_at(l, i), do: round_int((Enum.at(l, i) + Enum.at(l, i - 1)) / 2)

  defp ceil_int(i), do: i |> Float.ceil() |> trunc()
  defp round_int(i), do: i |> Float.round() |> trunc()
end

defmodule Solution do
  def align(list), do: align(list, Math.median(list), 0)
  def align([], _, fuel), do: fuel
  def align([h | t], med, fuel), do: align(t, med, fuel + abs(h - med))
end

IO.puts("Total fuel required to align is #{Solution.align(input)}")
