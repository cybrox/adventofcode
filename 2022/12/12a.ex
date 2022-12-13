lines =
  "./12.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))

defmodule Solution do
  def dijkstra(lines) do
    field = parse_field(lines)

    [{{sr, sc}, _}] = get_of_type(field, :start)
    [{{er, ec}, _}] = get_of_type(field, :end)

    step(field, {sr, sc}, {er, ec})
  end

  defp step(field, {r, c}, {r, c}), do: field[{r, c}] |> elem(2)

  defp step(field, {r, c}, {er, ec}) do
    {type, h, d, _} = field[{r, c}]
    adjecant = get_adj(field, r, c, h)

    field =
      adjecant
      |> Enum.reduce(field, fn {key, {type, xh, xd, seen}}, acc ->
        Map.put(acc, key, {type, xh, Enum.min([xd, d + 1]), seen})
      end)
      |> Map.put({r, c}, {type, h, d, true})

    {{nr, nc}, _} =
      field
      |> Enum.filter(fn {_, {_, _, _, seen}} -> not seen end)
      |> Enum.sort(fn {_, {_, _, d1, _}}, {_, {_, _, d2, _}} -> d1 < d2 end)
      |> Enum.at(0)

    step(field, {nr, nc}, {er, ec})
  end

  defp get_adj(field, r, c, h) do
    [
      {{r - 1, c}, field[{r - 1, c}]},
      {{r, c + 1}, field[{r, c + 1}]},
      {{r + 1, c}, field[{r + 1, c}]},
      {{r, c - 1}, field[{r, c - 1}]}
    ]
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.filter(fn {_, {_, xh, _, seen}} -> xh <= h + 1 and not seen end)
  end

  defp parse_field(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {h, c} ->
        {{r, c}, {type_of(h), height_of(h), dist_of(h), false}}
      end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp get_of_type(field, type), do: field |> Enum.filter(fn {_, {t, _, _, _}} -> t == type end)

  defp dist_of("S"), do: 0
  defp dist_of(_), do: :infinity

  defp type_of("S"), do: :start
  defp type_of("E"), do: :end
  defp type_of(_), do: :node

  defp height_of("S"), do: ?a
  defp height_of("E"), do: ?z
  defp height_of(<<n::8>>), do: n
end

IO.puts("The shortest path through this mess is #{Solution.dijkstra(lines)}")
