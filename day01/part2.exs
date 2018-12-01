File.read!("input.txt")
|> String.trim
|> String.split("\n")
|> Enum.map(&Integer.parse/1)
|> Enum.map(&(elem(&1, 0)))
|> Stream.cycle
|> Enum.reduce_while([0], fn value, acc ->
  next = Enum.at(acc, 0) + value
  if Enum.member?(acc, next), do: {:halt, next}, else: {:cont, [next | acc]}
end)
|> IO.inspect
