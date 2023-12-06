defmodule AdventOfCode.Puzzles.Year2020.Day15 do
  require Logger

  alias AdventOfCode.Common.Input
  alias AdventOfCode.Common.Util

  defmodule Shared do
    # Solve the puzzle by playing the game for `max_turns - 1` turns.
    # We build an initial lookup map of `number->turn` values to know when each number was
    # last spoken, by mapping the given starting numbers and their indices into a map.
    # We remove the last number, because in the actual game a spoken number is only added
    # on the subsequent turn, so that we don't override the time it was last said to the
    # previous turn every time. Then we play the game.
    def solve(input, max_turns) do
      data =
        input
        |> Input.clean_trim()
        |> Input.split_by_char(",", trim: true)
        |> Enum.map(&Util.str2int/1)

      lookup =
        data
        |> Enum.with_index(1)
        |> Enum.slice(0..-2)
        |> Enum.into(%{})

      # Play turns until the desired turn is reached
      play_turn(Enum.count(data) + 1, max_turns, data |> Enum.at(-1), lookup)
    end

    # Each turn, we increment the turn counter by one, store the last spoken number from the
    # previous turn in the lookup table and speak a new number, which is either the difference
    # of turns between now and the last time that was spoken or `0`.
    # We use `turn - 1` as the default value for `Map.get/3` here, which will cancel the whole
    # calculation out to `0` to facilitate this without additional branching.
    # If we reached the maximum number of turns, we return the last spoken number.
    defp play_turn(turn, turn, spoken, _acc), do: spoken

    defp play_turn(turn, max_turn, spoken, acc) do
      play_turn(
        turn + 1,
        max_turn,
        turn - Map.get(acc, spoken, turn - 1) - 1,
        Map.put(acc, spoken, turn - 1)
      )
    end
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    @turns 2020 + 1

    # We want to find the last spoken number in the game after 2020 turns.
    # since part A and part B are identical except for the number of turns,
    # this simply calls the shared solve method.
    def solve(input), do: solve(input, @turns)
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    @turns 30_000_000 + 1

    # We want to find the last spoken number in the game after 30'000'000 turns.
    # since part A and part B are identical except for the number of turns,
    # this simply calls the shared solve method.
    def solve(input), do: solve(input, @turns)
  end
end
