defmodule AdventOfCode.Puzzles.Year2015.Day08 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule PartA do
    # We want to find the difference between the number of characters in the full input
    # strings (e.g. the actual byte size) and the text encoded within them. The text length
    # does not account for the leading and trailing quote (`"`) and counds `\\`, `\"` and
    # hex literals in the format `\x00` as a single character.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)

      data
      |> Enum.map(&get_line_sizes/1)
      |> Enum.reduce(0, fn {code_size, char_size}, acc -> acc + code_size - char_size end)
    end

    # Get the size of a line by calculating its byte size and the size of its content
    defp get_line_sizes(line), do: {get_code_size(line), get_char_size(line)}

    # Get the code / byte size of the line
    defp get_code_size(line), do: byte_size(line)

    # Get the size of the content of the line. This first trims the leading and trailing
    # quotes and then just replaces all escaped sequences with a single `?` so they are
    # counted as a single character, since we don't care about their actual value.
    defp get_char_size(line) do
      line
      |> String.trim("\"")
      |> String.replace("\\\"", "?")
      |> String.replace("\\\\", "?")
      |> String.replace(~r/\\x[a-f0-9]{2}/, "?")
      |> byte_size()
    end
  end

  defmodule PartB do
    # We want to find the difference between the number of characters in the full input
    # strings (e.g. the actual byte size) and the re-encoded input strings. Re-encoding
    # simply means replacing `\` with `\\` and `"` with `\"`. Hex values are not affected.
    def solve(input) do
      data =
        input
        |> Input.split_by_line(trim: true)

      data
      |> Enum.map(&get_line_sizes/1)
      |> Enum.reduce(0, fn {old_size, new_size}, acc -> acc + new_size - old_size end)
    end

    # Get the size of a line by calculating its byte size and the re-encoded size
    defp get_line_sizes(line), do: {get_code_size(line), get_encoded_size(line)}

    # Get the code / byte size of the line
    defp get_code_size(line), do: byte_size(line)

    # Get the re-encoded size of the line. This replaces `\` with `\\` and `"` with `\"`
    # and calculates the byte site, adding 2 for the hypothetical leading and trailing `"`.
    defp get_encoded_size(line) do
      line
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> byte_size()
      |> Kernel.+(2)
    end
  end
end
