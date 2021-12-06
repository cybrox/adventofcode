input =
  "./4.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.replace(~r/ +/, " ")
  |> String.split("\n\n", trim: true)

[number_list | fields] = input

numbers = number_list |> String.split(",") |> Enum.map(&String.to_integer/1)

fields =
  fields
  |> Enum.map(fn f ->
    f
    |> String.split("\n")
    |> Enum.map(fn n ->
      n
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end)

defmodule Solution do
  def play_bingo(draws, fields), do: play_bingo(draws, [], fields)
  def play_bingo([], _, _), do: raise("Nobody got a bingo!")

  def play_bingo([h | t], drawn, fields) do
    wins = Enum.filter(fields, &field_wins(drawn, &1))

    if !Enum.empty?(wins) do
      sum = wins |> List.flatten() |> Enum.filter(&(!(&1 in drawn))) |> Enum.sum()
      [last | _] = drawn
      sum * last
    else
      play_bingo(t, [h | drawn], fields)
    end
  end

  defp field_wins(draws, field) do
    flip_field = field |> Enum.zip() |> Enum.map(&Tuple.to_list/1)
    Enum.any?(field, &row_wins(draws, &1)) or Enum.any?(flip_field, &row_wins(draws, &1))
  end

  defp row_wins(draws, row), do: Enum.all?(row, &(&1 in draws))
end

IO.puts("Final score of winning board is #{Solution.play_bingo(numbers, fields)}")
