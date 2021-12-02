defmodule CaseSwapTest do
  use ExUnit.Case
  doctest CaseSwap

  test "greets the world" do
    assert CaseSwap.hello() == :world
  end
end
