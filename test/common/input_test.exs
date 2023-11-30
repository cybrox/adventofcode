defmodule AdventOfCode.Common.InputTest do
  use ExUnit.Case, async: true

  alias AdventOfCode.Common.Input, as: Testee

  describe "split_by_line/2" do
    test "properly splits string by line" do
      assert Testee.split_by_line("a\nb\nc") == ["a", "b", "c"]
      assert Testee.split_by_line("abc") == ["abc"]
      assert Testee.split_by_line("abc\n") == ["abc", ""]
    end

    test "properly splits list by line" do
      assert Testee.split_by_line(["a\nb\nc", "d\ne\nf"]) == [["a", "b", "c"], ["d", "e", "f"]]
      assert Testee.split_by_line(["abc", "def"]) == [["abc"], ["def"]]
      assert Testee.split_by_line(["abc\n", "def\n"]) == [["abc", ""], ["def", ""]]
    end

    test "properly maps each line" do
      assert Testee.split_by_line("a\nb\nc", mapper: &String.upcase/1) == ["A", "B", "C"]

      assert Testee.split_by_line(["a\nb\nc", "d\ne\nf"], mapper: &String.upcase/1) == [
               ["A", "B", "C"],
               ["D", "E", "F"]
             ]
    end
  end

  describe "split_by_char/3" do
    test "properly splits by character" do
      assert Testee.split_by_char("a,b,c", ",") == ["a", "b", "c"]
      assert Testee.split_by_char("abc", ",") == ["abc"]
      assert Testee.split_by_char("abc,", ",") == ["abc", ""]
      assert Testee.split_by_char("abc") == ["", "a", "b", "c", ""]
      assert Testee.split_by_char("abc", "", trim: true) == ["a", "b", "c"]
    end

    test "properly splits list by character" do
      assert Testee.split_by_char(["a,b,c", "d,e,f"], ",") == [
               ["a", "b", "c"],
               ["d", "e", "f"]
             ]

      assert Testee.split_by_char(["abc", "def"], ",") == [["abc"], ["def"]]
      assert Testee.split_by_char(["abc,", "def,"], ",") == [["abc", ""], ["def", ""]]

      assert Testee.split_by_char(["abc", "def"]) == [
               ["", "a", "b", "c", ""],
               ["", "d", "e", "f", ""]
             ]
    end

    test "properly maps each chunk" do
      assert Testee.split_by_char("a,b,c", ",", mapper: &String.upcase/1) == ["A", "B", "C"]

      assert Testee.split_by_char(["a,b,c", "d,e,f"], ",", mapper: &String.upcase/1) == [
               ["A", "B", "C"],
               ["D", "E", "F"]
             ]
    end
  end

  describe "clean_trim/1" do
    test "properly trims input" do
      assert Testee.clean_trim(" a ") == "a"
      assert Testee.clean_trim("\r\na\r\n") == "a"
      assert Testee.clean_trim("\t a \t") == "a"
    end
  end

  describe "remove_empty/1" do
    test "properly removes empty lines" do
      assert Testee.remove_empty(["a", "", "b", ""]) == ["a", "b"]
      assert Testee.remove_empty(["a", "b"]) == ["a", "b"]
    end
  end
end
