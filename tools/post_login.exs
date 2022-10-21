endpoint = "127.0.0.1:4000/api/login"
http_headers = [
  "Content-Type": "application/json"
]



json = %{
  email:    "owner@candymart.com",
  password: "candyland"
}

payload = Jason.encode!(json)

_response =
  endpoint
  |> HTTPotion.post(body: payload, headers: http_headers)
  |> IO.inspect()
