defmodule Sleigh do
  def assemble(order \\ [], instructions)

  def assemble(order, instructions) when instructions == %{} do
    Enum.reverse(order)
  end

  def assemble(order, instructions) do
    {runable, _} = Enum.find(instructions, fn {_, precon} -> Enum.empty?(precon) end)
    new_order = [runable | order]
    new_instructions = Enum.reduce(instructions, %{}, fn {step, precons}, acc ->
      if step == runable do
        acc
      else
        put_in acc[step], Enum.reject(precons, &(&1 == runable))
      end
    end)

    assemble(new_order, new_instructions)
  end
end

steps = File.read!("input.txt")
        |> String.trim
        |> (&Regex.scan(~r/tep ([A-Z])/, &1, capture: :all_but_first)).()
        |> List.flatten
        |> Enum.uniq
        |> Enum.sort

instructions = Enum.reduce(steps, %{}, fn s, acc -> put_in acc[s], [] end)

instructions = File.read!("input.txt")
                |> String.trim
                |> String.split("\n")
                |> Enum.reduce(instructions, fn line, acc ->
                  key = Regex.scan(~r/step ([A-Z])/, line, capture: :all_but_first) |> List.flatten |> List.first
                  new_value = Regex.scan(~r/Step ([A-Z])/, line, capture: :all_but_first) |> List.flatten |> List.first
                  put_in acc[key], [new_value | acc[key]]
                end)
                |> Enum.sort

Sleigh.assemble(instructions) |> Enum.join |> IO.inspect
