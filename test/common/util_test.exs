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

  describe "intersect_onto/2" do
    test "returns correct value for different range constellations" do
      # Range B is fully outside of range A
      assert Testee.intersect_onto(20..50, 0..10) == nil
      assert Testee.intersect_onto(20..50, 60..100) == nil

      # Range B fully encapsulates range A
      assert Testee.intersect_onto(20..50, 0..100) == 20..50
      assert Testee.intersect_onto(20..50, 20..50) == 20..50

      # Range A fully encapsulates range B
      assert Testee.intersect_onto(20..50, 30..40) == 30..40
      assert Testee.intersect_onto(20..50, 35..45) == 35..45

      # Range B clips range A at the beginning
      assert Testee.intersect_onto(20..50, 0..20) == 20..20
      assert Testee.intersect_onto(20..50, 10..20) == 20..20

      # Range B intersects range A at the beginning
      assert Testee.intersect_onto(20..50, 0..30) == 20..30
      assert Testee.intersect_onto(20..50, 10..40) == 20..40

      # Range B clips range A at the end
      assert Testee.intersect_onto(20..50, 50..70) == 50..50
      assert Testee.intersect_onto(20..50, 50..100) == 50..50

      # Range B intersects range A at the end
      assert Testee.intersect_onto(20..50, 30..60) == 30..50
      assert Testee.intersect_onto(20..50, 40..100) == 40..50
    end
  end

  describe "complement_onto/2" do
    test "returns correct value for different range constellations" do
      # Range B is fully outside of range A
      assert Testee.complement_onto(20..50, 0..10) == 20..50
      assert Testee.complement_onto(20..50, 60..100) == 20..50

      # Range B fully encapsulates range A
      assert Testee.complement_onto(20..50, 0..100) == nil
      assert Testee.complement_onto(20..50, 20..50) == nil

      # Range A fully encapsulates range B
      assert Testee.complement_onto(20..50, 30..40) == [20..29, 41..50]
      assert Testee.complement_onto(20..50, 35..45) == [20..34, 46..50]

      # Range B clips range A at the beginning
      assert Testee.complement_onto(20..50, 0..20) == 21..50
      assert Testee.complement_onto(20..50, 10..20) == 21..50

      # Range B intersects range A at the beginning
      assert Testee.complement_onto(20..50, 0..30) == 31..50
      assert Testee.complement_onto(20..50, 10..40) == 41..50

      # Range B clips range A at the end
      assert Testee.complement_onto(20..50, 50..70) == 20..49
      assert Testee.complement_onto(20..50, 50..100) == 20..49

      # Range B intersects range A at the end
      assert Testee.complement_onto(20..50, 30..60) == 20..29
      assert Testee.complement_onto(20..50, 40..100) == 20..39
    end
  end
end
