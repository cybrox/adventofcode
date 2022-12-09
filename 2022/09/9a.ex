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
  def swing(lines), do: step(lines, {{0, 0}, {0, 0}, []}) |> Enum.uniq() |> Enum.count()

  defp step([], {_, _, seen}), do: seen
  defp step([{_, 0} | t], {{hr, hc}, {tr, tc}, seen}), do: step(t, {{hr, hc}, {tr, tc}, seen})

  defp step([{dir, dist} | t], {{hr, hc}, {tr, tc}, seen}),
    do: step([{dir, dist - 1} | t], move(dir, {hr, hc}, {tr, tc}, seen))

  defp move(dir, {hr, hc}, {tr, tc}, seen) do
    {nhr, nhc} = move_h(dir, {hr, hc})
    {ntr, ntc} = move_t({nhr, nhc}, {tr, tc})
    {{nhr, nhc}, {ntr, ntc}, [{ntr, ntc} | seen]}
  end

  defp move_h("U", {hr, hc}), do: {hr - 1, hc}
  defp move_h("L", {hr, hc}), do: {hr, hc - 1}
  defp move_h("D", {hr, hc}), do: {hr + 1, hc}
  defp move_h("R", {hr, hc}), do: {hr, hc + 1}

  defp move_t({hr, hc}, {tr, tc}) when abs(hr - tr) <= 1 and abs(hc - tc) <= 1, do: {tr, tc}

  defp move_t({hr, hc}, {tr, tc}) do
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
