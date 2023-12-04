defmodule AdventOfCode.Common.Util do
  @doc """
  Get all possible permutations for a list
  """
  def permutations_of([]), do: [[]]

  def permutations_of(list),
    do: for(elem <- list, rest <- permutations_of(list -- [elem]), do: [elem | rest])

  @doc """
  Get an integer from a number while also triming whitespace.
  Characters to trim can be passed in an optional second parameter.

  These two steps occur in a lot of puzzles
  """
  def str2int(str, trim \\ " "), do: str |> String.trim(trim) |> String.to_integer()
end
