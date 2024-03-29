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
        {Day05.PartA, 379_811_651},
        {Day05.PartB, 27_992_443},
        {Day06.PartA, 1_159_152},
        {Day06.PartB, 41_513_103},
        {Day07.PartA, 250_232_501},
        {Day07.PartB, 249_138_943},
        {Day08.PartA, 11309},
        {Day08.PartB, 13_740_108_158_591},
        {Day09.PartA, 1_708_206_096},
        {Day09.PartB, 1050},
        {Day10.PartA, 7012},
        {Day10.PartB, 395},
        {Day11.PartA, 9_684_228},
        {Day11.PartB, 483_844_716_556},
        {Day14.PartA, 108_918},
        {Day14.PartB, 100_310},
        {Day13.PartA, 33735},
        {Day13.PartB, 38063},
        {Day15.PartA, 511_498},
        {Day15.PartB, 284_674},
        {Day16.PartA, 7798},
        {Day16.PartB, 8026},
        {Day18.PartA, 108_909},
        {Day18.PartB, 133_125_706_867_777},
        {Day19.PartA, 368_523},
        {Day19.PartB, 124_167_549_767_307}
      ]
    )
  end
end
