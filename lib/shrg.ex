defmodule Shrg do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  get ":code" do
    response = DynamoDB.request(
      "GetItem",
      %{
        "TableName" => System.get_env("DYNAMO_DB_TABLE"),
        "Key"       => %{
          "code" => %{
            "S" => code
          }
        }
      }
    )

    if location = Poison.decode!(response.body)["Item"]["url"]["S"] do
      conn
      |> put_resp_header("Location", location)
      |> send_resp(307, "Temporary Redirect")
    else
      send_resp(conn, 404, "Not Found")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

end

Plug.Adapters.Cowboy.http(Shrg, [])
