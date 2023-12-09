defmodule AdventOfCode.Puzzles.Year2015.Day12 do
  require Logger

  defmodule PartA do
    # We want to find the sum of all numeric elements in the JSON document, regardless
    # of their position or role within the document. To do so, we unwrap each structure
    # into a list of values recursively, flatten that and then sum their values, which
    # are either the number's value for numbers or zero for any non-numbers.
    def solve(input) do
      data = input |> Jason.decode!()

      data
      |> json_elements()
      |> List.flatten()
      |> Enum.map(&json_value/1)
      |> Enum.sum()
    end

    # Get all elements in a specific data structure recursively
    defp json_elements(data) when is_nil(data), do: nil
    defp json_elements(data) when is_binary(data), do: data
    defp json_elements(data) when is_number(data), do: data
    defp json_elements(data) when is_list(data), do: Enum.map(data, &json_elements/1)
    defp json_elements(data) when is_map(data), do: Enum.map(data, &json_elements/1)

    defp json_elements(data) when is_tuple(data),
      do: data |> Tuple.to_list() |> Enum.map(&json_elements/1)

    # Get the value of an element within the document
    defp json_value(v) when is_number(v), do: v
    defp json_value(_), do: 0
  end

  # We want to find the sum of all numeric elements in the JSON document, except for any
  # ones within a map where one value is "red". To do so, we still unwrap each structure
  # into a list of values recursively, flatten that and then sum their values, which
  # are either the number's value for numbers or zero for any non-numbers.
  # The only difference is that the unwrapping will now ignore maps with "red" values.
  defmodule PartB do
    def solve(input) do
      data =
        input
        |> Jason.decode!()

      data
      |> json_elements()
      |> List.flatten()
      |> Enum.map(&json_value/1)
      |> Enum.sum()
    end

    # Get all elements in a specific data structure recursively
    # This works the same as in part A, expect for maps, which we first map into a list of
    # their values and proceed to ignore them completely, if any of their keys are "red".
    defp json_elements(data) when is_nil(data), do: nil
    defp json_elements(data) when is_binary(data), do: data
    defp json_elements(data) when is_number(data), do: data
    defp json_elements(data) when is_list(data), do: Enum.map(data, &json_elements/1)

    defp json_elements(data) when is_map(data) do
      red_values = data |> Enum.filter(fn {_k, v} -> v == "red" end)
      if Enum.empty?(red_values), do: Enum.map(data, &json_elements/1), else: 0
    end

    defp json_elements(data) when is_tuple(data),
      do: data |> Tuple.to_list() |> Enum.map(&json_elements/1)

    # Get the value of an element within the document
    defp json_value(v) when is_number(v), do: v
    defp json_value(_), do: 0
  end
end
