defmodule AdventOfCode.Puzzles.Year2023.Day02 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    # Parse a single line as a game by obtaining its game id from the beginning of the
    # line and the list of rounds with shown cubes from the rest parsed via parse_game_info/1
    def parse_game(line) do
      [<<"Game ", game_id::binary>>, game_info] = String.split(line, ": ", parts: 2)
      {String.to_integer(game_id), parse_game_info(game_info)}
    end

    # Parse the game info string by splitting it into its individual rounds and parsing
    # each round using parse_game_round/1. Rounds are separated by a semicolon (`;`)
    defp parse_game_info(game_info),
      do: game_info |> String.split(";") |> Enum.map(&parse_game_round/1)

    # Parse each round by splitting its instructions and mapping them into a map in the
    # format `cube colors => number shown`. Multiple shows of the same color per round
    # are supported, even though this does not occur in my puzzle input.
    defp parse_game_round(round_data) do
      round_data
      |> String.split(" ", trim: true)
      |> Enum.chunk_every(2)
      |> Enum.reduce(%{}, fn [number_of_cube, color_of_cube], acc ->
        number = String.to_integer(number_of_cube)
        color = String.trim(color_of_cube, ",")
        Map.update(acc, color, number, fn n -> n + number end)
      end)
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    @cube_limits %{
      "red" => 12,
      "green" => 13,
      "blue" => 14
    }

    # We want to find the sum of the IDs of all games that are possible when adhering to the
    # limits set by `@cube_limits`. A game is deemed valid when no more cubes of a single color
    # are shown in a round than specified by `@cube_limits`.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_game/1)

      data
      |> Enum.filter(fn {_, game_data} -> game_possible?(game_data, @cube_limits) end)
      |> Enum.map(fn {game_id, _} -> game_id end)
      |> Enum.sum()
    end

    # Determine whether or not a game is possible by checking if all its rounds are possible.
    defp game_possible?(game_data, cube_limits),
      do: game_data |> Enum.all?(&round_possible?(&1, cube_limits))

    # Determining whether or not a round is possible by checking all of the cube batches shown
    # during the round and checking that none of them exceed the set `cube_limits`.
    defp round_possible?(round_data, cube_limits),
      do: round_data |> Enum.all?(fn {color, number} -> number <= Map.get(cube_limits, color) end)
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the sum of the cube powers of each game played. The cube power is
    # determined by the product of the minimum number of cubes needed for playing each
    # game. So if a game has two rounds where 2 and 6 red cubes and 4 and 8 blue cubes
    # are shown, the cube power is 6 * 8 = 48.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)
        |> Enum.map(&parse_game/1)

      data
      |> Enum.map(fn {_game_id, game_data} -> cube_power(game_data, %{}) end)
      |> Enum.sum()
    end

    # Calculate the cube power by taking the product of the lowest number of cubes
    # required for each color played at least once in any round of the game.
    defp cube_power([], lowest),
      do: lowest |> Enum.map(fn {_, n} -> n end) |> Enum.product()

    defp cube_power([h | t], lowest),
      do: cube_power(t, Map.merge(lowest, h, fn _k, a, b -> max(a, b) end))
  end
end
