defmodule Box do
  def contains_count?(str, count) do
    chars = String.graphemes(str)
    Enum.any?(chars, fn c -> Enum.count(chars, &(&1 == c)) == count end)
  end
end

File.read!("input.txt")
|> String.trim
|> String.split("\n")
|> Enum.reduce({0, 0}, fn value, acc ->
  {twos, threes} = acc
  twos = twos + if Box.contains_count?(value, 2), do: 1, else: 0
  threes = threes + if Box.contains_count?(value, 3), do: 1, else: 0
  {twos, threes}
end)
|> (fn({a, b}) -> a * b end).()
|> IO.inspect
