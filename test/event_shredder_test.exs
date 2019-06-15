defmodule Commanded.Event.ShredderTest do
  use ExUnit.Case
  doctest Commanded.Event.Shredder

  test "greets the world" do
    assert Commanded.Event.Shredder.hello() == :world
  end
end
