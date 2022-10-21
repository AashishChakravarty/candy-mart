defmodule CandyMart.Users.UserToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_tokens" do
    field :context, :string
    field :token, :binary

    belongs_to(:user, CandyMart.Users.User)

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:token, :context, :user_id])
    |> validate_required([:token, :context, :user_id])
  end
end
