lines =
  "./7.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)

defmodule Solution do
  @fs_total_size 70_000_000
  @fs_needs_free 30_000_000

  def dirsize(list) do
    tree = parse_lines(list)

    dirs = tree |> Enum.map(fn {d, _, _} -> d end) |> Enum.uniq()
    sizes = dirs |> Enum.map(fn d -> {d, sum_for(tree, d)} end)

    {_, root_size} = sizes |> Enum.filter(fn {k, _} -> k == "/" end) |> Enum.at(0)
    space_needed = @fs_needs_free - (@fs_total_size - root_size)

    dirs
    |> Enum.map(fn d -> {d, sum_for(tree, d)} end)
    |> Enum.filter(fn {_d, s} -> s >= space_needed end)
    |> Enum.map(fn {_d, s} -> s end)
    |> Enum.min()
  end

  defp sum_for(tree, dir) do
    tree
    |> Enum.filter(fn {d, _n, _s} -> d == dir end)
    |> Enum.map(fn {d, n, s} -> if s > 0, do: s, else: sum_for(tree, Path.join([d, n])) end)
    |> Enum.sum()
  end

  defp parse_lines(list, stackacc \\ {[], []})
  defp parse_lines([], {_stack, acc}), do: acc
  defp parse_lines([h | t], {stack, acc}), do: parse_lines(t, parse_line(h, stack, acc))

  defp parse_line("$ ls", stack, acc), do: {stack, acc}
  defp parse_line(<<"$ cd ", to::binary>>, stack, acc), do: {parse_cd(stack, to), acc}
  defp parse_line(line, stack, acc), do: line |> String.split(" ") |> parse_file(stack, acc)

  defp parse_file(["dir", n], stack, acc), do: {stack, acc ++ [{Path.join(stack), n, 0}]}

  defp parse_file([s, n], stack, acc),
    do: {stack, acc ++ [{Path.join(stack), n, String.to_integer(s)}]}

  defp parse_cd(_stack, "/"), do: ["/"]
  defp parse_cd(stack, ".."), do: Enum.slice(stack, 0..-2)
  defp parse_cd(stack, dir), do: stack ++ [dir]
end

IO.puts("The smallest directory that can be deleted is #{Solution.dirsize(lines)}")
