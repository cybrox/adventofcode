input =
  "./9.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
  end)

defmodule Solution do
  def find_basins(g) do
    w = g |> Enum.at(0) |> Enum.count()
    h = g |> Enum.count()
    lows = find_low(g, w, h)

    basins =
      Enum.map(lows, fn {x, y, v} ->
        build_basin(g, w, h, [{x, y, v}], v)
      end)

    basins
    |> Enum.map(&Enum.count/1)
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.product()
  end

  defp build_basin(_, _, _, l, m) when m >= 8, do: l

  defp build_basin(g, w, h, l, m) do
    branches =
      Enum.map(l, fn {x, y, v} ->
        get_around(g, x, y, w, h)
        |> Enum.filter(fn {_, _, nv} -> nv > v && nv < 9 end)
      end)

    basins = Enum.uniq(l ++ List.flatten(branches))

    build_basin(g, w, h, basins, m + 1)
  end

  defp find_low(g, w, h), do: find_low(g, 0, 0, w, h, [])
  defp find_low(_, _, y, _, h, l) when y >= h, do: l
  defp find_low(g, x, y, w, h, l) when x >= w, do: find_low(g, 0, y + 1, w, h, l)
  defp find_low(g, x, y, w, h, l), do: find_low(g, x + 1, y, w, h, add_low(g, x, y, w, h, l))

  defp get_at(_, x, y, _, _) when x < 0 or y < 0, do: 10
  defp get_at(_, x, y, w, h) when y >= h or x >= w, do: 10
  defp get_at(g, x, y, _, _), do: g |> Enum.at(y) |> Enum.at(x)

  defp add_low(g, x, y, w, h, l) do
    self = get_at(g, x, y, w, h)
    around = get_around(g, x, y, w, h) |> Enum.map(&elem(&1, 2))

    if self < Enum.min(around), do: [{x, y, self} | l], else: l
  end

  defp get_around(g, x, y, w, h) do
    [
      {x - 1, y, get_at(g, x - 1, y, w, h)},
      {x + 1, y, get_at(g, x + 1, y, w, h)},
      {x, y - 1, get_at(g, x, y - 1, w, h)},
      {x, y + 1, get_at(g, x, y + 1, w, h)}
    ]
  end
end

IO.puts("The product of the area of the three largest basins is #{Solution.find_basins(input)}")
