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
    halt(send_resp(conn, 404, "Not Found"))
  end

end

Plug.Adapters.Cowboy.http(Plrt, [])
