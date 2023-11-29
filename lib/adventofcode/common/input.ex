defmodule AdventOfCode.Common.Input do
  @doc """
  Split the full input string by line or if it was already split before, split each segment by
  line again. This works recursively, so if you have a list of lists of strings, it will split
  each list of strings by line.
  This function allows passing optional arguments to the String.split function.
  Additionally, opts.mapper can be passed to transform each line.
  """
  @spec split_by_line(binary() | list(), keyword()) :: [binary()] | [list()]
  def split_by_line(input, opts \\ []), do: split_by_char(input, "\n", opts)

  @doc """
  Split the full input string by a char or if it was already split before, split each segment by
  that char again. This works recursively, so if you have a list of lists of strings, it will split
  each list of strings by that char.
  This function allows passing optional arguments to the String.split function.
  Additionally, opts.mapper can be passed to transform each split chunk.
  """
  @spec split_by_char(binary() | list(), binary(), keyword()) :: [binary()] | [list()]
  def split_by_char(input, delimiter \\ "", opts \\ [])

  def split_by_char(input, delimiter, opts) when is_list(input) do
    input |> Enum.map(&split_by_char(&1, delimiter, opts))
  end

  def split_by_char(input, delimiter, opts) do
    input
    |> String.split(delimiter, opts_without_mapper(opts))
    |> Enum.map(mapper_from(opts))
  end

  @doc """
  Trim the input to remove any white spaces, line breaks or tabs from the beginning and end.
  This is a more sohpisticated version of String.trim/1, suited for the input of the Advent of Code.
  """
  @spec clean_trim(binary()) :: binary()
  def clean_trim(input) do
    input
    |> String.replace(~r/^[ \t\n\r]*/, "")
    |> String.replace(~r/[ \t\n\r]*?/, "")
  end

  @doc """
  Remove empty elements from a an input list.
  This function allows passing the filters to remove as an optional argument.
  This function does not work recursively, so if you have a list of lists of lists, it will
  only remove empty elements from the first list, not the nested lists.
  """
  @spec remove_empty([binary()], [any()]) :: [binary()]
  def remove_empty(input_list, filters \\ [nil, [], ""]) do
    input_list
    |> Enum.filter(&(&1 not in filters))
  end

  defp mapper_from(opts), do: Keyword.get(opts, :mapper, & &1)
  defp opts_without_mapper(opts), do: Keyword.delete(opts, :mapper)
end
