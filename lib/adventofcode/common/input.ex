defmodule AdventOfCode.Common.Input do
  @doc """
  Split the input file line by line
  """
  @spec split_by_line(binary()) :: [binary()]
  def split_by_line(input) do
    input |> String.split("\n")
  end

  @doc """
  Split the input file character by character
  """
  @spec split_by_character(binary()) :: [binary()]
  def split_by_character(input, delimiter \\ "") do
    input |> String.split(delimiter)
  end

  @doc """
  Trim the full input to remove any white spaces or line breaks
  """
  @spec trim_input(binary()) :: binary()
  def trim_input(input) do
    input
    |> String.trim(" ")
    |> String.trim("\r")
    |> String.trim("\n")
    |> String.trim("\t")
  end

  @doc """
  Remove empty lines or elements from input
  """
  @spec remove_empty([binary()]) :: [binary()]
  def remove_empty(input_list) do
    Enum.filter(input_list, &(&1 != ""))
  end
end
