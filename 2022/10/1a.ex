lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  @offset 20
  @step 40

  def strength_sum(ops) do
    ops
    |> Enum.map(&parse_opt/1)
    |> run()
    |> Enum.slice((@offset - 1)..-1)
    |> Enum.chunk_every(@step)
    |> Enum.map(&(&1 |> Enum.at(0) |> strength()))
    |> Enum.sum()
  end

  defp run(ops, cycle \\ 0, x \\ 1, acc \\ [])
  defp run([], _, _, acc), do: acc
  defp run([{:noop, _} | t], c, x, acc), do: run(t, c + 1, x, acc ++ [{c + 1, x}])
  defp run([{:addx, y} | t], c, x, acc), do: run(t, c + 2, x + y, acc ++ [{c + 1, x}, {c + 2, x}])

  defp strength({cycle, x}), do: cycle * x

  defp parse_opt("noop"), do: {:noop, 0}
  defp parse_opt(<<"addx ", param::binary>>), do: {:addx, String.to_integer(param)}
end

IO.puts("The sum of all signal strengths is #{Solution.strength_sum(lines)}")
