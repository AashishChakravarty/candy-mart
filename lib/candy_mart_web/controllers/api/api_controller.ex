defmodule CandyMartWeb.Api.ApiController do
  use CandyMartWeb, :controller
  alias CandyMart.Orders

  def create_sale(conn, params) do
    case Orders.add_order(params) do
      {:ok, _order} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "Order created successfully."})

      {:error, _} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "Something went wrong"})
    end
  end
end
