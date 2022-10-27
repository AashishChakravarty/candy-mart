defmodule CandyMart.Orders.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @required ~W(name)a
  @optional ~W(id)a

  @all_fields @required ++ @optional

  schema "customers" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @all_fields)
    |> validate_required(@required)
  end
end
