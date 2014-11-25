defmodule Base62 do

  def encode(integer, string \\ "")

  def encode(0, "") do
    "0"
  end

  def encode(integer, string) when integer == 0 do
    string
  end

  def encode(integer, string) do
    encode(
      div(integer, 62),
      String.at(
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
        rem(integer, 62)
      ) <> string
    )
  end

end
