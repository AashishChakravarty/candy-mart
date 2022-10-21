defmodule CandyMartWeb.Api.ApiController do
  use CandyMartWeb, :controller
  alias CandyMart.Orders
  alias CandyMart.Users

  def create_sale(conn, params) do
    case Orders.add_order(params) do
      {:ok, _order} ->
        conn
        |> put_status(:ok)
        |> json(%{status: true, message: "Order created successfully."})

      {:error, _} ->
        conn
        |> put_status(:ok)
        |> json(%{status: false, message: "Something went wrong"})
    end
  end

  def user_login(conn, %{"email" => email, "password" => password}) do
    case Users.authenticate(email, password) do
      {:ok, user} ->
        token = Users.generate_user_api_token(user)

        user =
          user
          |> Map.from_struct()
          |> Map.drop([
            :__meta__,
            :password_hash
          ])
          |> Map.put(:token, token)

        conn
        |> put_status(:ok)
        |> json(%{status: true, message: "Login Successfully", data: user})

      _ ->
        conn
        |> put_status(:ok)
        |> json(%{status: false, message: "Invalid Email or Password"})
    end
  end
end
