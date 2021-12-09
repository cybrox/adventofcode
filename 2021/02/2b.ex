lines =
  "./2.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " "))
  |> Enum.map(fn [i, n] -> {i, String.to_integer(n)} end)

defmodule Solution do
  def navigate(inputs), do: navigate(inputs, 0, 0, 0)
  def navigate([], x, z, _), do: x * z
  def navigate([h | t], x, z, a), do: navigate(t, glide(h, x), sink(h, z, a), aim(h, a))

  defp glide({"forward", n}, x), do: x + n
  defp glide({"backward", n}, x), do: x - n
  defp glide(_, x), do: x

  defp sink({"forward", n}, h, a), do: h + n * a
  defp sink({"backward", n}, h, a), do: h - n * a
  defp sink(_, h, _), do: h

  defp aim({"up", n}, a), do: a - n
  defp aim({"down", n}, a), do: a + n
  defp aim(_, a), do: a
end

IO.puts("Multiplied final position is #{Solution.navigate(lines)}")
