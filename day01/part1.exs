File.read!("input.txt")
|> String.trim
|> String.split("\n")
|> Enum.map(&Integer.parse/1)
|> Enum.map(&(elem(&1, 0)))
|> Enum.sum
|> IO.inspect
