lines =
  "./1.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  @crt_width 40

  def solve(ops) do
    ops
    |> Enum.map(&parse_opt/1)
    |> run()
    |> Enum.chunk_every(@crt_width)
    |> Enum.map(fn l -> Enum.map(l, &get_pixel/1) |> Enum.join("") end)
  end

  defp run(ops, cycle \\ -1, x \\ 1, acc \\ [])
  defp run([], _, _, acc), do: acc
  defp run([{:noop, _} | t], c, x, acc), do: run(t, c + 1, x, acc ++ [{c + 1, x}])
  defp run([{:addx, y} | t], c, x, acc), do: run(t, c + 2, x + y, acc ++ [{c + 1, x}, {c + 2, x}])

  defp get_pixel({cycle, x}) when abs(rem(cycle, @crt_width) - x) <= 1, do: "█"
  defp get_pixel({_, _}), do: " "

  defp parse_opt("noop"), do: {:noop, 0}
  defp parse_opt(<<"addx ", param::binary>>), do: {:addx, String.to_integer(param)}
end

IO.puts("The CRT screen output is:")
IO.inspect(Solution.solve(lines), limit: :infinity)
