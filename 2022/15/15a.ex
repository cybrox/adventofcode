lines =
  "./15.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  @line 2_000_000

  def scan(lines) do
    data = Enum.map(lines, &parse_line/1)

    impossible_fields =
      data
      |> Enum.map(fn [sensor, beacon] -> covererd_by(sensor, mh_dist(sensor, beacon)) end)
      |> List.flatten()
      |> Enum.filter(fn {r, _, _} -> r == @line end)
      |> Enum.map(fn {_, c1, c2} -> Enum.to_list(c1..c2) end)
      |> List.flatten()
      |> Enum.uniq()

    occupied_fields =
      data
      |> List.flatten()
      |> Enum.filter(fn {r, _} -> r == @line end)
      |> Enum.map(fn {_, c} -> c end)
      |> Enum.uniq()

    Enum.count(impossible_fields -- occupied_fields)
  end

  defp mh_dist({r1, c1}, {r2, c2}), do: abs(r1 - r2) + abs(c1 - c2)

  defp covererd_by({r, c}, d) do
    (r - d)..(r + d)
    |> Enum.map(fn sr -> {sr, c - (d - abs(sr - r)), c + (d - abs(sr - r))} end)
  end

  defp parse_line(line) do
    line
    |> String.replace("Sensor at ", "")
    |> String.replace("closest beacon is ", "")
    |> String.split(" at ")
    |> Enum.map(&parse_position/1)
  end

  defp parse_position(pos) do
    pos
    |> String.split(" ")
    |> Enum.map(fn p -> p |> String.replace(~r/[^0-9\-]/, "") |> String.to_integer() end)
    |> Enum.reverse()
    |> List.to_tuple()
  end
end

IO.puts("There are #{Solution.scan(lines)} positions in r=2'000'000 that cannot contain a beacon")
