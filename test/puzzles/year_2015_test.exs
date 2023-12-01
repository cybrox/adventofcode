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
        {Day07.PartB, 14710}
      ]
    )
  end
end
