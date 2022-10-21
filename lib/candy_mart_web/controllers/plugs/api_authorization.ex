defmodule CandyMartWeb.Plugs.APIAuthorization do
  @moduledoc """
    This plug ensures that an API has a valid token before accessing a given service
  """
  use CandyMartWeb, :controller
  import Plug.Conn
  alias CandyMart.Users

  @invalid_token_msg "Invalid token. Unauthorized to perform this action."
  @missing_token_msg "Missing token. Unauthorized to perform this action."

  def init(default), do: default

  def call(conn, _default) do
    token =
      conn
      |> get_token()

    if !is_nil(token) do
      Users.get_user_by_api_token(token)
      |> case do
        {:ok, user} -> assign(conn, :current_user, user)
        _ -> send_error_halt(conn, :unauthorized, @invalid_token_msg)
      end
    else
      send_error_halt(conn, :unauthorized, @missing_token_msg)
    end
  end

  def get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

  def send_error_halt(conn, status_code, message) do
    body = Jason.encode!(%{message: message, status: false})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, body)
    |> halt()
  end
end
