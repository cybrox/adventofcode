lines =
  "./15.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  @min 0
  @max 4_000_000

  def scan(lines) do
    data = Enum.map(lines, &parse_line/1)

    sensors = data |> Enum.map(fn {{sr, sc}, _, d} -> {sr, sc, d} end)
    points = data |> Enum.map(fn {s, b, _} -> [s, b] end) |> List.flatten()

    @min..@max
    |> Stream.map(&eval_line(&1, sensors, points))
    |> Stream.filter(fn {_, c} -> c != -1 end)
    |> Enum.at(0)
    |> tune_freq()
  end

  defp eval_line(l, sensors, points) do
    close_enough = sensors |> Enum.filter(fn {r, _, d} -> abs(l - r) <= d end)

    scanned =
      close_enough
      |> Enum.map(fn {r, c, d} ->
        dist = d - abs(l - r)
        {clamp(c - dist), clamp(c + dist)}
      end)

    occupied =
      points
      |> Enum.filter(fn {r, _} -> r == l end)
      |> Enum.map(fn {_, c} -> {clamp(c), clamp(c)} end)

    ranges = Enum.sort(scanned ++ occupied, fn {f1, _}, {f2, _} -> f1 < f2 end)

    {l, gap_at(ranges)}
  end

  defp tune_freq({r, c}), do: c * 4_000_000 + r

  defp clamp(n) when n < @min, do: @min
  defp clamp(n) when n > @max, do: @max
  defp clamp(n), do: n

  defp gap_at(list, lim \\ 0)
  defp gap_at([], _), do: -1
  defp gap_at([{c1, c2} | t], max) when c1 <= max and c2 <= max, do: gap_at(t, max)
  defp gap_at([{c1, c2} | t], max) when c1 <= max and c2 > max, do: gap_at(t, c2)
  defp gap_at([{c1, c2} | _], max) when c1 > max + 1 and c2 > max, do: max + 1
  defp gap_at([{c1, c2} | t], max) when c1 > max and c2 > max, do: gap_at(t, c2)

  defp mh_dist({r1, c1}, {r2, c2}), do: abs(r1 - r2) + abs(c1 - c2)

  defp parse_line(line) do
    [sensor, beacon] =
      line
      |> String.replace("Sensor at ", "")
      |> String.replace("closest beacon is ", "")
      |> String.split(" at ")
      |> Enum.map(&parse_position/1)

    {sensor, beacon, mh_dist(sensor, beacon)}
  end

  defp parse_position(pos) do
    pos
    |> String.split(" ")
    |> Enum.map(fn p -> p |> String.replace(~r/[^0-9\-]/, "") |> String.to_integer() end)
    |> Enum.reverse()
    |> List.to_tuple()
  end
end

# Part one was solved with creating lists and removing elements from them. This would take
# a few years to complete this task. Part two instead uses a parallel approach creating a
# stream where each line is evaluated on its own and uses iteration of ranges instead of lists.
IO.puts("The tuning frequency of the only possible target is #{Solution.scan(lines)}")
