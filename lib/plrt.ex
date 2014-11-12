defmodule Plrt do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    halt(send_resp(conn, 200, "Hello world"))
  end

end

Plug.Adapters.Cowboy.http(Plrt, [])
