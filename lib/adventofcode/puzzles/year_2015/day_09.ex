defmodule AdventOfCode.Puzzles.Year2015.Day09 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Parse a single line of distance info into an `{a, b, d}` tuple where `a` and `b` are the
    # `from` and `to` locations o the route and `d` is the distance between them as a number.
    def parse_distance_info(line) do
      [from, to, distance] = line |> String.split([" = ", " to "]) |> Enum.map(&String.trim/1)
      {from, to, String.to_integer(distance)}
    end

    # This takes a list of distances in the format `{a, b, d}` where `a` and `b` are
    # locations and `d` is the distance between them and generates a list of all possible
    # route permutations. E.g. `[{a, b, d}]` -> `[[a, b], [b, a]]`.
    # This does not account for distance.
    def all_possible_routes(route_data) do
      route_data
      |> Enum.map(fn {a, b, _d} -> [a, b] end)
      |> List.flatten()
      |> Enum.uniq()
      |> Util.permutations_of()
    end

    # This takes a list of distances in the format `{a, b, d}` where `a` and `b` are
    # locations and `d` is the distance between them and adds the inverse of every route
    # to the list. E.g. `[{a, b, d}]` -> `[{a, b, d}, {b, a, d}]
    #
    # This allows easier lookup in the future, as the direction travelled does not matter.
    def full_route_data(route_data) do
      route_data
      |> Enum.map(fn {a, b, d} -> [{{a, b}, d}, {{b, a}, d}] end)
      |> List.flatten()
      |> Enum.into(%{})
    end

    # Convert a list of locations into a list of individual travel steps.
    # E.g. a list of `[a, b, c]` will be converted into `[{a,b}, {b,c}]`
    def route_to_steps([_], acc), do: acc
    def route_to_steps([a, b | t], acc), do: route_to_steps([b | t], [{a, b} | acc])
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the shortest route that covers all stops using a list of
    # travel times between two stops. This is essentially the travelling salesman problem.
    # See: https://en.wikipedia.org/wiki/Travelling_salesman_problem
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_distance_info/1)

      # Get a list of all possible routes in any direction
      full_data = data |> full_route_data()

      # Map the instructions into a list of all possible routes (permutations) and traverse
      # each one of them location by location, accumulating the total distance. Then pick
      # the length of the shortest possible route
      data
      |> all_possible_routes()
      |> Enum.map(fn route ->
        route_to_steps(route, [])
        |> Enum.map(fn {a, b} -> Map.get(full_data, {a, b}) end)
        |> Enum.sum()
      end)
      |> Enum.min()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # In this puzzle, part A and part B are virtually identical. Instead of picking the
    # shortest path to deliver presents efficiently, Santa has been promoted and is now
    # looking to pick the longest path to simply show off to his superiors.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_distance_info/1)

      # Get a list of all possible routes in any direction
      full_data = data |> full_route_data()

      # Map the instructions into a list of all possible routes (permutations) and traverse
      # each one of them location by location, accumulating the total distance. Then pick
      # the length of the shortest possible route
      data
      |> all_possible_routes()
      |> Enum.map(fn route ->
        route_to_steps(route, [])
        |> Enum.map(fn {a, b} -> Map.get(full_data, {a, b}) end)
        |> Enum.sum()
      end)
      |> Enum.max()
    end
  end
end
