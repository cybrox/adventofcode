defmodule AdventOfCode.Puzzles.Year2015.Day05 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    @naughty_sequences ["ab", "cd", "pq", "xy"]
    @vowels ["a", "e", "i", "o", "u"]

    # We want to find the number of "nice" strings in the puzzle input. Nice strings
    # are defined by containing at least 3 vowels (aeiou), contain at least one letter
    # twice in a row and do not contain `ab`, `cd`, `pq` or `xy`
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)

      data
      |> Enum.filter(&is_nice_string?/1)
      |> Enum.count()
    end

    # Check if a string is nice by combining multiple required checks
    defp is_nice_string?(input) do
      has_three_vowlels?(input) and
        has_letter_tuple?(input) and
        not has_naughty_sequences?(input)
    end

    # Check if a string contains at least three vowels
    defp has_three_vowlels?(input) do
      n_vowels =
        input
        |> Input.split_by_char("", trim: true)
        |> Enum.filter(&(&1 in @vowels))
        |> Enum.count()

      n_vowels >= 3
    end

    # Check if a string contains one or more letters twice in a row
    # We can ignore the last case where only one character is left because that is already
    # handled by the previous check that compares the last and second-to-last character.
    defp has_letter_tuple?(<<_::binary-size(1)>>), do: false

    defp has_letter_tuple?(<<a::binary-size(1), b::binary-size(1), rest::binary>>) do
      if a == b, do: true, else: has_letter_tuple?(b <> rest)
    end

    # Check if a string contains one or more naughty sequences
    defp has_naughty_sequences?(input) do
      @naughty_sequences |> Enum.any?(&String.contains?(input, &1))
    end
  end

  defmodule PartB do
    # We want to find the number of "nice" strings in the puzzle input. Nice strings
    # are defined by containing any pair of two same characters twice (non overlapping)
    # and containing at least one letter which repeats with exactly one letter between.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)

      data
      |> Enum.filter(&is_nice_string?/1)
      |> Enum.count()
    end

    # Check if a string is nice by combining multiple required checks
    defp is_nice_string?(input) do
      has_two_letter_tuples?(input) and has_repeating_gap?(input)
    end

    # Check if a string has at least two non-overlapping character tuples
    # To achieve this, we shift through the string and generate a list of all possible two-letter
    # combinations. Once we reach the end of the string, we group the list by the different chunks
    # and see if any of them occur more than twice. For the ones that do, we check their spacing.
    defp has_two_letter_tuples?(_input, acc \\ [])

    defp has_two_letter_tuples?(<<_::binary-size(1)>>, acc) do
      acc
      |> Enum.with_index()
      |> Enum.group_by(fn {chunk, _i} -> chunk end)
      |> Enum.filter(fn {_chunk, occurences} -> Enum.count(occurences) >= 2 end)
      |> Enum.any?(fn {_chunk, occurences} -> valid_spacing?(occurences) end)
    end

    defp has_two_letter_tuples?(input, acc) do
      has_two_letter_tuples?(String.slice(input, 1..-1), [String.slice(input, 0..1) | acc])
    end

    # The spacing between two repeating chunks is deemed valid, when it is greated than one.
    # This means "aaa" does not match the requirement for two "aa" chunks, because chunkt one
    # will begin at index 0 and chunk two at index 1 (overlapping), which fails this check.
    defp valid_spacing?(occurences) do
      indices =
        occurences
        |> Enum.map(fn {_chunk, i} -> i end)

      Enum.max(indices) - Enum.min(indices) > 1
    end

    # Check if the string has a repeating letter with a gap in between it.
    # To achieve this, we shift through the string and generate a list of all possible three-letter
    # combinations. Once we reach the end of the string, we check if any three-letter combination
    # matches the condition where the first and last character are the same.
    defp has_repeating_gap?(_input, acc \\ [])

    defp has_repeating_gap?(<<_::binary-size(2)>>, acc) do
      acc
      |> Enum.filter(fn chunk -> String.at(chunk, 0) == String.at(chunk, 2) end)
      |> Enum.any?()
    end

    defp has_repeating_gap?(input, acc) do
      has_repeating_gap?(String.slice(input, 1..-1), [String.slice(input, 0..2) | acc])
    end
  end
end
