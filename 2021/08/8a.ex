input =
  "./8.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line |> String.split(" | ") |> Enum.map(&String.split(&1, " "))
  end)

defmodule Solution do
  @lenmap %{1 => 2, 2 => 5, 3 => 5, 4 => 4, 5 => 5, 6 => 6, 7 => 3, 8 => 7, 9 => 6}

  def findnum(input, numbers), do: findnum(input, numbers, 0)
  def findnum([], _numbers, acc), do: acc
  def findnum([[_, h] | t], numbers, acc), do: findnum(t, numbers, acc + seg_with(h, numbers))

  defp seg_with(l, numbers), do: num_with(l, Enum.map(numbers, &@lenmap[&1]))
  defp num_with(l, lengths), do: l |> Enum.filter(&(String.length(&1) in lengths)) |> Enum.count()
end

IO.puts("There are #{Solution.findnum(input, [1, 4, 7, 8])} instances of 1, 4, 7, 8")
