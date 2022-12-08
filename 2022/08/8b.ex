lines =
  "./8.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn l -> l |> String.split("", trim: true) |> Enum.map(&String.to_integer/1) end)

defmodule Solution do
  def find_best_tree(field) do
    field
    |> Enum.with_index()
    |> Enum.map(fn {row, r} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {col, c} ->
        check_tree(field, r, c, col)
      end)
    end)
    |> List.flatten()
    |> Enum.max()
  end

  defp check_tree(field, r, c, h) do
    left_of = left_of(field, r, c) |> view_distance(h)
    right_of = right_of(field, r, c) |> view_distance(h)
    top_of = top_of(field, r, c) |> view_distance(h)
    bottom_of = bottom_of(field, r, c) |> view_distance(h)
    left_of * right_of * top_of * bottom_of
  end

  defp left_of(f, r, c), do: f |> Enum.at(r) |> Enum.slice(0..c) |> remr()
  defp right_of(f, r, c), do: f |> Enum.at(r) |> Enum.slice(c..-1) |> reml()
  defp top_of(f, r, c), do: f |> Enum.map(&Enum.at(&1, c)) |> Enum.slice(0..r) |> remr()
  defp bottom_of(f, r, c), do: f |> Enum.map(&Enum.at(&1, c)) |> Enum.slice(r..-1) |> reml()

  defp view_distance(f, h), do: f |> Enum.find_index(&(&1 >= h)) |> dist2num(Enum.count(f))

  defp reml(list), do: list |> Enum.drop(1)
  defp remr(list), do: list |> Enum.drop(-1) |> Enum.reverse()

  defp dist2num(nil, max), do: max
  defp dist2num(n, _max), do: n + 1
end

IO.puts("The tree with the best view has a score of #{Solution.find_best_tree(lines)}.")
