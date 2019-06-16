defmodule Commanded.ShredderTest do
  use ExUnit.Case
  doctest Commanded.Shredder

  test "greets the world" do
    assert Commanded.Shredder.hello() == :world
  end
end
