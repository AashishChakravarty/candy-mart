defmodule CandyMartWeb.Api.ApiController do
  use CandyMartWeb, :controller

  def create_sale(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{status: "Not implemented"})
  end
end
