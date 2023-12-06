defmodule AdventOfCode.Puzzles.Year2023Test do
  use ExUnit.Case, async: true

  require YearTestGenerator

  describe "solutions for year 2023" do
    YearTestGenerator.generate_test_blocks(
      AdventOfCode.Puzzles.Year2023,
      [
        {Day01.PartA, 54605},
        {Day01.PartB, 55429},
        {Day02.PartA, 2285},
        {Day02.PartB, 77021},
        {Day03.PartA, 532_428},
        {Day03.PartB, 84_051_670},
        {Day04.PartA, 28538},
        {Day04.PartB, 9_425_061},
        {Day06.PartA, 1_159_152},
        {Day06.PartB, 41_513_103}
      ]
    )
  end
end
