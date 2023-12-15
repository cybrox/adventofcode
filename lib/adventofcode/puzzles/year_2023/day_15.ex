defmodule AdventOfCode.Puzzles.Year2023.Day15 do
  require Logger

  alias AdventOfCode.Common.Input

  defmodule Shared do
    # Calculate the "Holiday ASCII String Helper" hash of a given string.
    # This pops the first character off a string until it is empty and applies
    # `+?h`, `*17` and `rem(256)` on it on every iteration.
    def hash(data), do: hash(data, 0)

    defp hash("", acc), do: acc
    defp hash(<<h::utf8, rest::binary>>, acc), do: hash(rest, rem((acc + h) * 17, 256))
  end

  defmodule PartA do
    use AdventOfCode.Common.Shared

    # We want to find the sum of the hash values of all the instructions in the input.
    # To do this, we simply hash each value and sum up their resulting hashes.
    def solve(input) do
      data =
        input
        |> Input.clean_trim()
        |> Input.split_by_char(",")

      data
      |> Enum.map(&hash/1)
      |> Enum.sum()
    end
  end

  defmodule PartB do
    use AdventOfCode.Common.Shared

    # We want to find the total lense power of all lenses in boxes, assuming we apply the
    # given instructions one by one and then calculate the total lense power of the resulting
    # arrangement of boxes and lesnses.
    def solve(input) do
      data =
        input
        |> Input.clean_trim()
        |> Input.split_by_char(",")
        |> Enum.map(&parse_instruction/1)

      data
      |> Enum.reduce(%{}, fn instruction, boxes -> apply_instruction(boxes, instruction) end)
      |> total_lense_power()
    end

    # Apply an instruction to the map of boxes.
    # For a `{:-, label, box}` instruction, we remove the lens with the given label if present.
    # For a `{:=, label, f_length, box} instruction, we either add that label/f_length pair to the
    # box or replace the existing lense labelled `label` with a new one using the new `f_length`.
    defp apply_instruction(boxes, {:-, label, box}) do
      Map.update(boxes, box, [], fn lenses ->
        Enum.filter(lenses, fn {l, _} -> l != label end)
      end)
    end

    defp apply_instruction(boxes, {:=, label, f_length, target_box}) do
      Map.update(boxes, target_box, [{label, f_length}], fn lenses ->
        has_lense = Enum.any?(lenses, fn {l, _} -> l == label end)

        if has_lense do
          Enum.map(lenses, fn
            {^label, _n} -> {label, f_length}
            other -> other
          end)
        else
          lenses ++ [{label, f_length}]
        end
      end)
    end

    # Calculate the total focusing power of all of our lsenses.
    # This is done by going through each non-empty box and summing the lenses inside
    # by `1` plus the box number times the index (1 based) of the lens times its focal length.
    defp total_lense_power(lens_boxes) do
      lens_boxes
      |> Enum.map(fn {box, lenses} ->
        lenses
        |> Enum.with_index(1)
        |> Enum.map(fn {{_, focus}, i} -> (1 + box) * i * focus end)
      end)
      |> List.flatten()
      |> Enum.sum()
    end

    # Parse a single instruction depending on the last character.
    # If that is a `-`, the instruction is in the format `label-`, for which we return
    # the label and its hash, which is the target box number.
    # Otherwise, the instruction is in the format `label=focus`, for which we return
    # the label and its hash as well as the focal lenth (`f_length`) of the lense.
    defp parse_instruction(instruction) do
      if String.ends_with?(instruction, "-") do
        label = String.replace(instruction, "-", "")
        {:-, label, hash(label)}
      else
        [label, f_length] = String.split(instruction, "=", parts: 2)
        {:=, label, String.to_integer(f_length), hash(label)}
      end
    end
  end
end
