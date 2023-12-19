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

  @doc """
  Given two ranges A and B, get back a sub-range of range A with all the values that
  are also contained within range B. In other words, get the intersection of range A and B.
  """
  def intersect_onto(nil, _), do: nil
  def intersect_onto(_, nil), do: nil

  def intersect_onto(sa..ea = range_a, sb..eb = range_b) do
    cond do
      # match range is fully outside original range
      Range.disjoint?(range_a, range_b) -> nil
      # match range is fully inside original range
      sb > sa and eb < ea -> range_b
      # match range fully envelops original range
      sb <= sa and eb >= ea -> range_a
      # match range clips start of original range
      sb < sa and eb >= sb -> sa..eb
      # match range clips end of original range
      sb <= ea and eb > ea -> sb..ea
    end
  end

  @doc """
  Given two ranges A and B, get back a sub-range (or list of sub-ranges) of range A with all the
  values that are not also contained within range B. In other words, get the complement of range
  A with respect to range B.
  """
  def complement_onto(nil, _), do: nil
  def complement_onto(range_a, nil), do: range_a

  def complement_onto(sa..ea = range_a, sb..eb = range_b) do
    cond do
      # match range is fully outside original range
      Range.disjoint?(range_a, range_b) -> range_a
      # match range is fully inside original range
      sb > sa and eb < ea -> [sa..(sb - 1), (eb + 1)..ea]
      # match range fully envelops original range
      sb <= sa and eb >= ea -> nil
      # match range clips start of original range
      sb < sa and eb >= sb -> (eb + 1)..ea
      # match range clips end of original range
      sb <= ea and eb > ea -> sa..(sb - 1)
    end
  end
end
