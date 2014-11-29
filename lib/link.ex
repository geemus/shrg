defmodule Link do
  def expand(code) do
    response = DynamoDB.request(
      "GetItem",
      %{
        "Key"       => %{
          "code" => %{
            "S" => code
          }
        },
        "TableName" => System.get_env("DYNAMO_DB_TABLE")
      }
    )
    Poison.decode!(response.body)["Item"]["url"]["S"]
  end

  def shorten(url) do
    # atomically update and grab new value
    response = DynamoDB.request(
      "UpdateItem",
      %{
        "ExpressionAttributeValues" => %{
          ":inc" => %{"N" => "1"}
        },
        "Key"               => %{
          "code" => %{
            "S" => "__NEXT__"
          }
        },
        "ReturnValues"      => "UPDATED_NEW",
        "TableName"         => System.get_env("DYNAMO_DB_TABLE"),
        "UpdateExpression"  => "add id :inc"
      }
    )
    code = Poison.decode!(response.body)["Attributes"]["id"]["N"]

    # use new value as code to write short link
    DynamoDB.request(
      "UpdateItem",
      %{
        "ExpressionAttributeNames"  => %{
          "#url" => "url"
        },
        "ExpressionAttributeValues" => %{
          ":url" => %{"S" => url}
        },
        "Key"               => %{
          "code" => %{
            "S" => code
          }
        },
        "ReturnValues"      => "UPDATED_NEW",
        "TableName"         => System.get_env("DYNAMO_DB_TABLE"),
        "UpdateExpression"  => "set #url = :url"
      }
    )

    # return code
    code
  end
end
