defmodule AdventOfCode.Common.UtilTest do
  use ExUnit.Case, async: true

  alias AdventOfCode.Common.Util, as: Testee

  describe "permutations_of/1" do
    test "generates correct permutations for list" do
      assert Testee.permutations_of([]) == [[]]
      assert Testee.permutations_of([1, 2]) == [[1, 2], [2, 1]]

      assert Testee.permutations_of([1, 2, 3]) == [
               [1, 2, 3],
               [1, 3, 2],
               [2, 1, 3],
               [2, 3, 1],
               [3, 1, 2],
               [3, 2, 1]
             ]

      assert Testee.permutations_of([1, 2, 3, 4, 5, 6]) |> Enum.count() == 720
    end
  end

  describe "str2int/1" do
    test "properly converts string even with surrounding characters" do
      assert Testee.str2int("1") == 1
      assert Testee.str2int(" 1") == 1
      assert Testee.str2int("  78") == 78
      assert Testee.str2int("78,", ",") == 78
    end
  end
end
