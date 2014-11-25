defmodule Base62Test do
  use ExUnit.Case

  test "encode(0) succeeds" do
    assert Base62.encode(0) == "0"
  end

  test "encode(10) succeeds" do
    assert Base62.encode(10) == "A"
  end

  test "encode succeeds" do
    assert Base62.encode(100) == "1c"
  end
end
