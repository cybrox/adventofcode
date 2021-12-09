input =
  "./8.input.txt"
  |> File.read!()
  |> String.trim()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line |> String.split(" | ") |> Enum.map(&String.split(&1, " "))
  end)

defmodule Solution do
  def sum_of_outputs(list), do: sum_of_outputs(list, [])
  def sum_of_outputs([], acc), do: Enum.sum(acc)
  def sum_of_outputs([h | t], acc), do: sum_of_outputs(t, [output_of(h) | acc])

  defp output_of([inputs, outputs]) do
    outputs
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.map(&identify_number(&1, filters_for(inputs)))
    |> Enum.join("")
    |> String.to_integer()
  end

  # The numbers that were used in part one can be identified
  # by their used digits. We can compute filters from them.
  defp filters_for(inputs) do
    in1 = inputs_for_size(inputs, 2)
    in4 = inputs_for_size(inputs, 4)
    in7 = inputs_for_size(inputs, 3)
    in8 = inputs_for_size(inputs, 7)

    # The filters are f1 = aa, f2 = bb|dd, f3 = ee|gg
    {in7 -- in1, in4 -- in1, (in8 -- in7) -- in4}
  end

  defp inputs_for_size(input, len) do
    input
    |> Enum.filter(&(String.length(&1) == len))
    |> Enum.at(0)
    |> String.split("", trim: true)
  end

  defp identify_number(s, {f1, f2, f3}) do
    cond do
      is_len?(s, 2) -> 1
      is_len?(s, 4) -> 4
      is_len?(s, 3) -> 7
      is_len?(s, 7) -> 8
      is_len?(s, 5) && matches?(s, f1) && matches?(s, f3) -> 2
      is_len?(s, 5) && matches?(s, f1) && matches?(s, f2) -> 5
      is_len?(s, 5) -> 3
      is_len?(s, 6) && matches?(s, f2) && !matches?(s, f3) -> 9
      is_len?(s, 6) && matches?(s, f1) && !matches?(s, f2) -> 0
      true -> 6
    end
  end

  defp matches?(input, sides), do: Enum.all?(sides, &(&1 in input))
  defp is_len?(input, len), do: Enum.count(input) == len
end

IO.puts("The total is #{Solution.sum_of_outputs(input)}")
