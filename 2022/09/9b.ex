lines =
  "./9.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [dir, dist] = String.split(line, " ", trim: true)
    {dir, String.to_integer(dist)}
  end)

defmodule Solution do
  @rope Enum.map(0..9, fn _ -> {0, 0} end)

  def swing(lines), do: step(lines, {@rope, []}) |> Enum.uniq() |> Enum.count()

  defp step([], {_, seen}), do: seen
  defp step([{_, 0} | t], {knots, seen}), do: step(t, {knots, seen})

  defp step([{dir, dist} | t], {knots, seen}),
    do: step([{dir, dist - 1} | t], move(dir, knots, seen))

  defp move(dir, knots, seen) do
    new_knots =
      Enum.reduce(knots, [], fn pos, acc -> acc ++ [move_k(pos, Enum.at(acc, -1), dir)] end)

    {new_knots, [new_knots |> Enum.at(-1) | seen]}
  end

  defp move_k({hr, hc}, nil, "U"), do: {hr - 1, hc}
  defp move_k({hr, hc}, nil, "L"), do: {hr, hc - 1}
  defp move_k({hr, hc}, nil, "D"), do: {hr + 1, hc}
  defp move_k({hr, hc}, nil, "R"), do: {hr, hc + 1}

  defp move_k({tr, tc}, {hr, hc}, _) when abs(hr - tr) <= 1 and abs(hc - tc) <= 1, do: {tr, tc}

  defp move_k({tr, tc}, {hr, hc}, _) do
    cond do
      hr == tr && hc < tc -> {tr, tc - 1}
      hr == tr && hc > tc -> {tr, tc + 1}
      hc == tc && hr < tr -> {tr - 1, tc}
      hc == tc && hr > tr -> {tr + 1, tc}
      hr > tr && hc > tc -> {tr + 1, tc + 1}
      hr > tr && hc < tc -> {tr + 1, tc - 1}
      hr < tr && hc > tc -> {tr - 1, tc + 1}
      hr < tr && hc < tc -> {tr - 1, tc - 1}
    end
  end
end

IO.puts("The tail visits a total of #{Solution.swing(lines)} locations.")
