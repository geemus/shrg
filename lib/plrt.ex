defmodule Base62 do

  def encode(integer, string \\ "")

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

defmodule Plrt do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  get ":code" do
    conn
    |> put_resp_header("Location", "https://google.com#q=#{code}")
    |> send_resp(307, "Temporary Redirect")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

end

Plug.Adapters.Cowboy.http(Plrt, [])
