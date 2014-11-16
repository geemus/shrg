defmodule Base62Test do
  use ExUnit.Case

  test "encode succeeds" do
    assert Base62.encode(100) == "1c"
  end
end
