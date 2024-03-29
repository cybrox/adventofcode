defmodule AdventOfCode.Puzzles.Year2015Test do
  use ExUnit.Case, async: true

  require YearTestGenerator

  describe "solutions for year 2015" do
    YearTestGenerator.generate_test_blocks(
      AdventOfCode.Puzzles.Year2015,
      [
        {Day01.PartA, 280},
        {Day01.PartB, 1797},
        {Day02.PartA, 1_586_300},
        {Day02.PartB, 3_737_498},
        {Day03.PartA, 2592},
        {Day03.PartB, 2360},
        {Day04.PartA, 282_749},
        {Day04.PartB, 9_962_624},
        {Day05.PartA, 236},
        {Day05.PartB, 51},
        {Day06.PartA, 400_410},
        {Day06.PartB, 15_343_601},
        {Day07.PartA, 3176},
        {Day07.PartB, 14710},
        {Day08.PartA, 1333},
        {Day08.PartB, 2046},
        {Day09.PartA, 117},
        {Day09.PartB, 909},
        {Day10.PartA, 329_356},
        {Day10.PartB, 4_666_278},
        {Day11.PartA, "cqjxxyzz"},
        {Day11.PartB, "cqkaabcc"},
        {Day12.PartA, 119_433},
        {Day12.PartB, 68466},
        {Day13.PartA, 664},
        {Day13.PartB, 640},
        {Day14.PartA, 2660},
        {Day14.PartB, 1256},
        {Day16.PartA, 40},
        {Day16.PartB, 241}
      ]
    )
  end
end
