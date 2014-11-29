defmodule DynamoDB do

  def request(action, payload) do
    payload = Poison.encode!(payload)

    now = Timex.Date.now()
    date      = now |> Timex.DateFormat.format!("{ISOdate}") |> String.replace("-", "")
    datetime  = now |> Timex.DateFormat.format!("{ISOz}") |> String.replace(~r{[-:]}, "")

    access_key_id     = System.get_env("ACCESS_KEY_ID")
    secret_access_key = System.get_env("SECRET_ACCESS_KEY")

    region        = "us-east-1"
    host          = "dynamodb.#{region}.amazonaws.com"

    service     = "dynamodb"
    target      = "DynamoDB_20120810.#{action}"

    algorithm         = "AWS4-HMAC-SHA256"
    credential_scope  = "#{date}/#{region}/dynamodb/aws4_request"
    signed_headers    = "host;x-amz-date;x-amz-target"

    canonical_request = """
POST
/

host:#{host}
x-amz-date:#{datetime}
x-amz-target:#{target}

#{signed_headers}
#{:crypto.hash(:sha256, payload) |> Base.encode16 |> String.downcase}
"""
    canonical_request = String.rstrip(canonical_request)

    hashed_canonical_request = :crypto.hash(:sha256, canonical_request) |> Base.encode16 |> String.downcase

    string_to_sign = """
AWS4-HMAC-SHA256
#{datetime}
#{credential_scope}
#{hashed_canonical_request}
"""
    string_to_sign = String.rstrip(string_to_sign)

    derived_signing_key = :crypto.hmac(:sha256, "AWS4#{secret_access_key}", date)
    derived_signing_key = :crypto.hmac(:sha256, derived_signing_key, region)
    derived_signing_key = :crypto.hmac(:sha256, derived_signing_key, service)
    derived_signing_key = :crypto.hmac(:sha256, derived_signing_key, "aws4_request")

    signature = :crypto.hmac(:sha256, derived_signing_key, string_to_sign) |> Base.encode16 |> String.downcase

    authorization = "#{algorithm} Credential=#{access_key_id}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

    headers = %{
      "Authorization" => authorization,
      "Content-Type"  => "application/x-amz-json-1.0",
      "x-amz-date"    => datetime,
      "x-amz-target"  => target
    }

    HTTPoison.start

    HTTPoison.request!(
      :post,
      "https://#{host}/",
      payload,
      headers
    )
  end

end
