Code.require_file("../lib/grid.exs")

defmodule Fabric do
  def claim(grid, id, {startx, starty}, {sizex, sizey}) do
    rangex = startx..(startx+sizex-1)
    rangey = starty..(starty+sizey-1)
    Enum.reduce(rangex, grid, fn x, grid ->
      Enum.reduce(rangey, grid, fn y, grid ->
        Grid.update(grid, {x, y}, &(if &1, do: [id, &1], else: [id]))
      end)
    end)
  end
end

claims = File.read!("input.txt")
|> String.trim
|> (&Regex.scan(~r/#(\d+) @ (\d+,\d+): (\d+x\d+)/, &1, capture: :all_but_first)).()
|> Enum.map(fn [id, rawpos, rawsize] ->
  [x, y] = String.split(rawpos, ",") |> Enum.map(&String.to_integer/1)
  [sizex, sizey] = String.split(rawsize, "x") |> Enum.map(&String.to_integer/1)
  [id, {x,y}, {sizex, sizey}]
end)

claimed = Enum.reduce(claims, Grid.build(1000), fn [id, start, size], acc ->
  Fabric.claim(acc, id, start, size)
end)

claimed
|> Grid.count_if(fn x -> length(x) > 1 end)
|> IO.inspect

[{id, _}] = Enum.map(claims, fn [id, start, size] ->
  {id, Grid.slice(claimed, start, size)}
end)
|> Enum.filter(fn {id, slice} ->
  Grid.all?(slice, fn v -> v == [id] end)
end)

IO.inspect id
