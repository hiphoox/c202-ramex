defmodule CompiladorCTest do
  use ExUnit.Case
  doctest CompiladorC

  test "greets the world" do
    assert CompiladorC.hello() == :world
  end
end
