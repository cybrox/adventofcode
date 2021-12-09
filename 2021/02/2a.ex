lines =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " "))
  |> Enum.map(fn [i, n] -> {i, String.to_integer(n)} end)

defmodule Solution do
  def navigate(inputs), do: navigate(inputs, 0, 0)
  def navigate([], x, z), do: x * z
  def navigate([h | t], x, z), do: navigate(t, glide(h, x), sink(h, z))

  defp glide({"forward", n}, x), do: x + n
  defp glide({"backward", n}, x), do: x - n
  defp glide(_, x), do: x

  defp sink({"up", n}, h), do: h - n
  defp sink({"down", n}, h), do: h + n
  defp sink(_, h), do: h
end

IO.puts("Multiplied final position is #{Solution.navigate(lines)}")
