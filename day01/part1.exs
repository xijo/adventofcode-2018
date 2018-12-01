File.read!("input.txt")
|> String.trim
|> String.split("\n")
|> Enum.map(&Integer.parse/1)
|> Enum.map(&(elem(&1, 0)))
|> Enum.reduce(fn(value, acc) -> value + acc end)
|> IO.inspect
