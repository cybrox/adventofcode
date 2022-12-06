line =
  "./6.input.txt"
  |> File.read!()
  |> String.trim()

defmodule Solution do
  @seq_len 4
  @mid_len @seq_len - 1

  def find_marker(<<head::binary-size(1), mid::binary-size(@mid_len), tail::binary>>, i \\ 0) do
    if distinct(head <> mid), do: i + @seq_len, else: find_marker(mid <> tail, i + 1)
  end

  defp distinct(chars) when is_binary(chars), do: chars |> String.to_charlist() |> distinct()
  defp distinct(chars), do: chars |> Enum.uniq() |> Enum.count() == @seq_len
end

IO.puts("Start of protocol is at position #{Solution.find_marker(line)}")
