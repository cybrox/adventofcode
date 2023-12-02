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
        {Day02.PartB, 77021}
      ]
    )
  end
end
