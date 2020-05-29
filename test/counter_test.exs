defmodule CounterTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok,
     result: [1]}
  end

  #####test to pass#######
  test "get next number", state do
    c=Counter.new
    operation=[Counter.click(c)]

    assert operation == state[:result]
  end

  test "get 0", state do
    c=Counter.new
    operation=[Counter.get(c)]
    expected_result=List.update_at(state[:result], 0, fn _ -> 0 end)

    assert operation == expected_result
  end

  test "get 3", state do
    c=Counter.new
    _operation=Counter.click(c)
    _operation=Counter.click(c)
    operation=[Counter.click(c)]
    expected_result=List.update_at(state[:result], 0, fn _ -> 3 end)

    assert operation == expected_result
  end
end
