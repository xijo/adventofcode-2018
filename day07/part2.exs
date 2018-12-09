defmodule Sleigh do
  def assemble_time(instructions, remaining_work, time \\ 0)

  def assemble_time(instructions, remaining_work, time) do
    workers = 5
    runable = Enum.filter(instructions, fn {_, precon} -> Enum.empty?(precon) end) |> Enum.map(&(elem(&1, 0))) |> Enum.take(workers)

    new_remaining_work = Enum.reduce(runable, remaining_work, fn s, acc ->
      put_in acc[s], acc[s] - 1
    end)

    new_instructions = Enum.reduce(instructions, %{}, fn {step, precons}, acc ->
      if new_remaining_work[step] == 0 do
        # Throw out step (by not taking it into the new map)
        acc
      else
        finished = new_remaining_work |> Enum.filter(fn {_, v} -> v == 0 end) |> Enum.map(&(elem(&1, 0)))
        put_in acc[step], Enum.reject(precons, &(Enum.member?(finished, &1)))
      end
    end)

    if Enum.any?(Map.values(new_remaining_work), &(&1 > 0)) do
      assemble_time(new_instructions, new_remaining_work, time + 1)
    else
      time + 1
    end
  end
end

steps = File.read!("input.txt")
        |> String.trim
        |> (&Regex.scan(~r/tep ([A-Z])/, &1, capture: :all_but_first)).()
        |> List.flatten
        |> Enum.uniq
        |> Enum.sort

remaining_work = Enum.reduce(steps, %{}, fn s, acc -> put_in acc[s], (List.first(to_charlist(s)) - 64 + 60) end)

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

Sleigh.assemble_time(instructions, remaining_work) |> IO.inspect
