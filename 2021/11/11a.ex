input =
  "./11.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
  end)

defmodule Solution do
  def simulate(g, n), do: simulate({g, 0}, n, 0)
  def simulate({_, f}, n, i) when i >= n, do: f
  def simulate(gf, n, i), do: simulate(evolve(gf), n, i + 1)

  defp evolve({g, f}), do: evolve(g, 0, 0, g |> Enum.at(0) |> Enum.count(), g |> Enum.count(), f)
  defp evolve(g, _, y, w, h, f) when y >= h, do: flash(g, 0, 0, w, h, f, false)
  defp evolve(g, x, y, w, h, f) when x >= w, do: evolve(g, 0, y + 1, w, h, f)
  defp evolve(g, x, y, w, h, f), do: evolve(charge(g, x, y, w, h), x + 1, y, w, h, f)

  defp charge(g, x, y, w, h), do: put_at(g, x, y, w, h, &(&1 + 1))

  defp flash(g, _, y, _, h, f, done) when y >= h and done, do: {g, f}
  defp flash(g, _, y, w, h, f, _) when y >= h, do: flash(g, 0, 0, w, h, f, true)
  defp flash(g, x, y, w, h, f, done) when x >= w, do: flash(g, 0, y + 1, w, h, f, done)

  defp flash(g, x, y, w, h, f, done) do
    {ng, nf, nd} = do_flash(g, x, y, w, h)
    flash(ng, x + 1, y, w, h, f + nf, nd and done)
  end

  defp do_flash(g, x, y, w, h) do
    if get_at(g, x, y, w, h) > 9 do
      {fash_adj(g, x, y, w, h), 1, false}
    else
      {g, 0, true}
    end
  end

  defp fash_adj(g, x, y, w, h) do
    g
    |> put_at(x, y, w, h, fn _ -> 0 end)
    |> put_at(x - 1, y - 1, w, h, &inc_if_nn/1)
    |> put_at(x, y - 1, w, h, &inc_if_nn/1)
    |> put_at(x + 1, y - 1, w, h, &inc_if_nn/1)
    |> put_at(x - 1, y, w, h, &inc_if_nn/1)
    |> put_at(x + 1, y, w, h, &inc_if_nn/1)
    |> put_at(x - 1, y + 1, w, h, &inc_if_nn/1)
    |> put_at(x, y + 1, w, h, &inc_if_nn/1)
    |> put_at(x + 1, y + 1, w, h, &inc_if_nn/1)
  end

  defp inc_if_nn(v) when v > 0, do: v + 1
  defp inc_if_nn(v), do: v

  defp get_at(_, x, y, _, _) when x < 0 or y < 0, do: -1
  defp get_at(_, x, y, w, h) when y >= h or x >= w, do: -1
  defp get_at(g, x, y, _, _), do: g |> Enum.at(y) |> Enum.at(x)

  defp put_at(g, x, y, _, _, _) when x < 0 or y < 0, do: g
  defp put_at(g, x, y, w, h, _) when y >= h or x >= w, do: g
  defp put_at(g, x, y, _, _, v), do: List.update_at(g, y, fn r -> List.update_at(r, x, v) end)
end

IO.puts("There have been a total of #{Solution.simulate(input, 100)} flashes")
