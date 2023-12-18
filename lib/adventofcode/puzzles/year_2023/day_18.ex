defmodule AdventOfCode.Puzzles.Year2023.Day18 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Polygon

  defmodule Shared do
    # Given a `{r, c}` point, get the next depending on the given direction and dinstance `d`.
    def next_from_dir({r, c}, "R", d), do: {r, c + d}
    def next_from_dir({r, c}, "L", d), do: {r, c - d}
    def next_from_dir({r, c}, "D", d), do: {r + d, c}
    def next_from_dir({r, c}, "U", d), do: {r - d, c}
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the total area of the lava pool from the directions for walking around
    # its perimiter. We first transform the walk instructions into a list of vertices of the
    # polygon that represents the pool and then calculate its ares.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(fn [dir, num, _color] ->
          {dir, String.to_integer(num)}
        end)

      vertices =
        data
        |> Enum.reduce([{0, 0}], fn {dir, num}, acc ->
          acc ++ [acc |> Enum.at(-1) |> next_from_dir(dir, num)]
        end)

      Polygon.area(vertices)
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We still want to find the total area of the lava pool from the directions for walking around
    # its perimiter. We first transform the modified walk instructions into a list of vertices of
    # the polygon that represents the pool and then calculate its ares.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Input.split_by_char(" ", trim: true)
        |> Enum.map(fn [_dir, _num, color] ->
          number = color |> String.slice(2..6) |> String.to_integer(16)
          dir = color |> String.at(7) |> dir_for()
          {dir, number}
        end)

      vertices =
        data
        |> Enum.reduce([{0, 0}], fn {dir, num}, acc ->
          acc ++ [acc |> Enum.at(-1) |> next_from_dir(dir, num)]
        end)

      Polygon.area(vertices)
    end

    # Get the previous direction code from the new hex value code.
    defp dir_for("0"), do: "R"
    defp dir_for("1"), do: "D"
    defp dir_for("2"), do: "L"
    defp dir_for("3"), do: "U"
  end
end
