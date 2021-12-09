input =
  "./9.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
  end)

defmodule Solution do
  def find_low(g), do: find_low(g, 0, 0, g |> Enum.at(0) |> Enum.count(), g |> Enum.count(), [])
  def find_low(_, _, y, _, h, l) when y >= h, do: l |> Enum.map(&(&1 + 1)) |> Enum.sum()
  def find_low(g, x, y, w, h, l) when x >= w, do: find_low(g, 0, y + 1, w, h, l)
  def find_low(g, x, y, w, h, l), do: find_low(g, x + 1, y, w, h, add_low(g, x, y, w, h, l))

  defp get_at(_, x, y, _, _) when x < 0 or y < 0, do: 10
  defp get_at(_, x, y, w, h) when y >= h or x >= w, do: 10
  defp get_at(g, x, y, _, _), do: g |> Enum.at(y) |> Enum.at(x)

  defp add_low(g, x, y, w, h, l) do
    self = get_at(g, x, y, w, h)

    around = [
      get_at(g, x - 1, y, w, h),
      get_at(g, x + 1, y, w, h),
      get_at(g, x, y - 1, w, h),
      get_at(g, x, y + 1, w, h)
    ]

    if self < Enum.min(around), do: [self | l], else: l
  end
end

IO.puts("The total risk level is #{Solution.find_low(input)}")
