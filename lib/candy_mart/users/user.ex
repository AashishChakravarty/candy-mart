defmodule CandyMart.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    pow_user_fields()

    timestamps()
  end

  def authenticate(%{password_hash: password_hash}, password),
    do: Pow.Ecto.Schema.Password.pbkdf2_verify(password, password_hash)
end
