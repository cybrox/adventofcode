lines =
  "./8.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn l -> l |> String.split("", trim: true) |> Enum.map(&String.to_integer/1) end)

defmodule Solution do
  def count_visible_trees(field) do
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
    |> Enum.count(&(&1 == true))
  end

  defp check_tree(field, r, c, h) do
    left_of = left_of(field, r, c) |> visible?(h)
    right_of = right_of(field, r, c) |> visible?(h)
    top_of = top_of(field, r, c) |> visible?(h)
    bottom_of = bottom_of(field, r, c) |> visible?(h)
    left_of or right_of or top_of or bottom_of
  end

  defp left_of(f, r, c), do: f |> Enum.at(r) |> Enum.slice(0..c) |> Enum.drop(-1)
  defp right_of(f, r, c), do: f |> Enum.at(r) |> Enum.slice(c..-1) |> Enum.drop(1)
  defp top_of(f, r, c), do: f |> Enum.map(&Enum.at(&1, c)) |> Enum.slice(0..r) |> Enum.drop(-1)
  defp bottom_of(f, r, c), do: f |> Enum.map(&Enum.at(&1, c)) |> Enum.slice(r..-1) |> Enum.drop(1)

  defp visible?([], _max), do: true
  defp visible?(l, max), do: Enum.max(l) < max
end

IO.puts("There are #{Solution.count_visible_trees(lines)} trees visible from the outside.")
