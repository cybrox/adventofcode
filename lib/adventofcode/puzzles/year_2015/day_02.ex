defmodule AdventOfCode.Puzzles.Year2015.Day02 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to find the total area of wrapping paper needed, which is the surface area of the box
    # (2*l*w + 2*w*h + 2*h*l) plus the area of the smallest side of the box. (e.g. l*w)
    def solve(input) do
      data =
        input
        |> Input.trim_input()
        |> Input.split_by_line()
        |> Input.split_by_character("x", &String.to_integer/1)

      Enum.reduce(data, 0, fn [l, w, h], acc ->
        acc + surface_area(l, w, h) + smallest_side(l, w, h)
      end)
    end

    # Calculate the surface area of the box, which is 2*l*w + 2*w*h + 2*h*l.
    defp surface_area(l, w, h), do: 2 * l * w + 2 * w * h + 2 * h * l

    # Calculate the smallest side of the box, which is the smallest of l*w, w*h, and h*l.
    defp smallest_side(l, w, h), do: Enum.min([l * w, w * h, h * l])
  end

  defmodule PartB do
    # We want to find the total length of ribbon needed, which is the volume (l*w*h) of the
    # box plus the shortest distance around its sides which is the smallest of
    # the perimiters 2*l+2*w, 2*w+2*h, and 2*h+2*l.
    def solve(input) do
      data =
        input
        |> Input.trim_input()
        |> Input.split_by_line()
        |> Input.split_by_character("x", &String.to_integer/1)

      Enum.reduce(data, 0, fn [l, w, h], acc ->
        acc + shortest_perimiter(l, w, h) + volume(l, w, h)
      end)
    end

    # Calculate the shortest around a side of the box
    defp shortest_perimiter(l, w, h), do: Enum.min([2 * l + 2 * w, 2 * w + 2 * h, 2 * h + 2 * l])

    # Calculate the volume of the box
    defp volume(l, w, h), do: l * w * h
  end
end
