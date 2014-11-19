defmodule DynamoDB do

  now = Timex.Date.now()
  date      = now |> Timex.DateFormat.format!("{ISOdate}") |> String.replace("-", "")
  datetime  = now |> Timex.DateFormat.format!("{ISOz}") |> String.replace(~r{[-:]}, "")

  access_key_id     = "key_id"
  secret_access_key = "secret"

  region        = "us-east-1"
  host          = "dynamodb.#{region}.amazonaws.com"

  service     = "DynamoDB"
  api_version = "DynamoDB"
  action      = "ListTables"
  target      = "#{service}_#{api_version}.#{action}"

  payload = ""

  algorithm   = "AWS4-HMAC-SHA256"
  credential  = "#{access_key_id}/#{date}/#{region}/dynamodb/aws4_request"
  signed_headers = "host;x-amz-date;x-amz-target"

  canonical_request = """
POST
/

can_headers
host: #{host}
x-amz-date: #{date}
x-amz-target: #{target}

#{signed_headers}
#{:crypto.hash(:sha256, payload)}
"""
  hashed_canonical_request = :crypto.hash(:sha256, canonical_request) |> Base.encode16

  string_to_sign = """
AWS4-HMAC-SHA256
#{date}
#{credential}
#{hashed_canonical_request}
"""

  signature     = :crypto.hmac(:sha256, secret_access_key, string_to_sign) |> Base.encode16

  authorization = "#{algorithm} Credential=#{credential},SignedHeaders=#{signed_headers},Signature=#{signature}"

  headers = %{
    "Authorization" => authorization,
    "Content-Type"  => "application/x-amz-json-1.0",
    "x-amz-date"    => datetime,
    "x-amz-target"  => target
  }

  IO.puts(inspect(headers))

end
