defmodule AdventOfCode.Puzzles.Year2015.Day11 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    @invalid_chars [?i, ?o, ?l]

    # Keep incrementing passwords using `increment_password/1` until the next valid
    # password (according to `valid_password?/1`) is found.
    def find_next_password(chars) do
      if valid_password?(chars),
        do: chars,
        else: chars |> increment_password() |> find_next_password()
    end

    # Increment the chars of a password by one. This will increment the rightmost character
    # by one and traverse through the list, keeping any carry-over in case the incremented
    # character overflowed from a `z` back to an `a`. `abc` becomes `abd` and `abz` becomes `aca`.
    def increment_password(chars) do
      chars
      |> Enum.reverse()
      |> Enum.reduce({[], 1}, fn item, {acc, carry} ->
        if item + carry > ?z, do: {[?a | acc], 1}, else: {[item + carry | acc], 0}
      end)
      |> prune_password()
    end

    # Prune impossible combinations from the password searching progress for drastic speed up.
    # In some cases, entire segments of possible passwords can be skipped, if they would contain
    # an invalid character sometimes. For example `ai......` passwords are invalid due to the `i`
    # regardless of the characters following it. So if we find an `@invalid_chars` anywhere in
    # our generated password, we increment it by one and set all following characters to an `a`
    # to completely skip those possibilities.
    def prune_password({chars, _}) do
      case Enum.find_index(chars, &(&1 in @invalid_chars)) do
        nil ->
          chars

        any ->
          before_invalid = Enum.slice(chars, 0, any)
          invalid_char = Enum.at(chars, any)
          after_invalid = chars |> Enum.slice((any + 1)..-1) |> Enum.map(fn _ -> ?a end)
          before_invalid ++ [invalid_char + 1] ++ after_invalid
      end
    end

    # Check whether or not a password is valid by applying multiple checks
    def valid_password?(chars),
      do: not has_invalid_char?(chars) and has_char_blocks?(chars) and has_char_sequence?(chars)

    # Check whether or not the chars of a password contain an invalid character
    def has_invalid_char?(chars), do: Enum.any?(chars, &(&1 in @invalid_chars))

    # Check whether or not the chars of a password contain at least two blocks of two
    # of the same characters repeating that are not overlapping. E.g. `aaxaa` but not `aaa`.
    def has_char_blocks?(chars) do
      chars
      |> Enum.chunk_every(2, 1)
      |> Enum.with_index()
      |> Enum.filter(fn {block, _} -> same_chars?(block) end)
      |> Enum.map(fn {_, i} -> i end)
      |> Enum.chunk_every(2, 1)
      |> Enum.any?(&blocks_spaced?/1)
    end

    # Check whether or not the chars of a password contain a sequence of three consecutive
    # characters (e.g. `abc` or `def`) anywhere in their contents.
    def has_char_sequence?(chars) do
      chars
      |> Enum.chunk_every(3, 1)
      |> Enum.any?(&sequence_chars?/1)
    end

    # Check if two numbers in a list are at least `2` apart.
    # This is used to make sure repeating blocks are spaced properly and not overlapping.
    def blocks_spaced?([_]), do: false
    def blocks_spaced?([ia, ib]), do: abs(ia - ib) >= 2

    # Check whether or not a list of two characters contains the same character twice.
    # This will return false for lists with two items, for use with `chunk_every/3`.
    def same_chars?([_]), do: false
    def same_chars?([a, b]), do: a == b

    # Check whether or not a list of characters is three characters in sequence. E.g. `abc`.
    # This will return false for lists with one or two items, for use with `chunk_every/3`.
    def sequence_chars?([_]), do: false
    def sequence_chars?([_, _]), do: false
    def sequence_chars?([a, b, c]), do: c == b + 1 and c == a + 2
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the next valid password from a given starting password.
    # To do this, we find the next valid password and convert the result to a string.
    def solve(input) do
      input
      |> Input.clean_trim()
      |> String.to_charlist()
      |> find_next_password()
      |> List.to_string()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the next valid password twice from a given starting password.
    # To do this, we find the next valid password (which is the result of part A), then
    # manually increment it by one and then find the next valid password again.
    # We then convert the result to a string.
    def solve(input) do
      input
      |> Input.clean_trim()
      |> String.to_charlist()
      |> find_next_password()
      |> increment_password()
      |> find_next_password()
      |> List.to_string()
    end
  end
end
