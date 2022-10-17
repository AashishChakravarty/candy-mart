endpoint = "127.0.0.1:4000/api/sales"
http_headers = [
  "Content-Type": "application/json"
]

base_cost = 25
variance = 10

# keep product costs consistent across tests
:random.seed(1)

generateUnitCost = fn() ->
  :random.uniform() * base_cost + variance
end

product_keys = ~w(
  toffee
  caramel
  chocolate
  butter_creme
  dark_chocolate
)a

products =
  product_keys
  |> Enum.map(&{&1, generateUnitCost.()})
  |> Map.new()

# reset the seed or the customer id and quantity will always be the same
:random.seed(
  :erlang.phash2([node()]),
  :erlang.monotonic_time(),
  :erlang.unique_integer())

product =
  products
  |> Map.keys()
  |> Enum.random()

quantity    = :random.uniform(100)
unit_cost   = products[product]
total_cost  = unit_cost * quantity
customer_id = :random.uniform(500) + 1

json = %{
  product:     product,
  quantity:    quantity,
  unit_cost:   unit_cost,
  total_cost:  total_cost,
  customer_id: customer_id
}

payload = Jason.encode!(json)

_response =
  endpoint
  |> HTTPotion.post(body: payload, headers: http_headers)
  |> IO.inspect()
