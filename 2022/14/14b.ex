lines =
  "./14.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " -> ", trim: true))

defmodule Solution do
  def drizzle(lines) do
    rocks =
      lines
      |> Enum.map(&parse_rocks/1)
      |> List.flatten()
      |> Enum.map(fn {c, r} -> {{r, c}, :rock} end)
      |> Enum.into(%{})

    ground = (rocks |> Enum.map(fn {{r, _}, _} -> r end) |> Enum.max()) + 2

    tick(rocks, ground)
  end

  defp tick(objects, ground, s \\ 0) do
    case get_sand(objects) do
      [] -> tick(objects |> Map.put({0, 500}, :sand), ground, s + 1)
      [{{r, c}, _}] -> sand_flow(objects, ground, {r, c}, s)
    end
  end

  defp sand_flow(objects, ground, {r, c}, s) do
    {nr, nc, nt} =
      cond do
        r + 1 == ground -> {r, c, :rest}
        objects[{r + 1, c}] == nil -> {r + 1, c, :sand}
        objects[{r + 1, c - 1}] == nil -> {r + 1, c - 1, :sand}
        objects[{r + 1, c + 1}] == nil -> {r + 1, c + 1, :sand}
        true -> {r, c, :rest}
      end

    if nr == 0 and nc == 500 and nt == :rest do
      s
    else
      objects |> Map.delete({r, c}) |> Map.put({nr, nc}, nt) |> tick(ground, s)
    end
  end

  defp get_sand(objects), do: objects |> Enum.filter(fn {_, t} -> t == :sand end)

  defp parse_rocks(points) do
    points
    |> Enum.map(&parse_point/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&parse_line/1)
    |> List.flatten()
  end

  defp parse_point(point),
    do: point |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

  defp parse_line([{r, c}, {r, c}]), do: [{r, c}]
  defp parse_line([{r, c1}, {r, c2}]), do: c1..c2 |> Enum.map(&{r, &1})
  defp parse_line([{r1, c}, {r2, c}]), do: r1..r2 |> Enum.map(&{&1, c})
end

# This is very slow and inefficient. The solution can probably be obtained mathematically using
# The output of Part 1 and the outmost edges of the shape plus the height of the pile so far.
IO.puts("Sand starts blocking itself after #{Solution.drizzle(lines)} pieces of sand")
