defmodule CandyMart.AddCustomers do
  alias CandyMart.Orders

  def run() do
    Orders.list_orders()
    |> Enum.map(fn %{customer_id: customer_id} ->
      Orders.get_or_create_customer(%{id: customer_id, name: Orders.generate_string()})
    end)
  end
end

CandyMart.AddCustomers.run()
