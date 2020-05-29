defmodule Counter do

  def new do
    spawn fn -> loop(0) end
  end

  @spec click(atom | pid | port | {atom, atom}) :: any
  def click(pid) do
    send(pid, {:next, self()})
    receive do x -> x end
  end

  def get(pid) do
    send(pid, {:get, self()})
    receive do x -> x end
  end

  defp loop(n) do
    receive do
      {:next, from} ->
        send(from, n+1)
        loop(n+1)
      {:get, from} ->
        send(from, n)
        loop(n)
      end
  end
end
