defmodule CandyMart.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :quantity, :integer, null: false
      add :unit_cost, :integer, null: false
      add :total_cost, :integer, null: false
      add :product_name, :string, null: false, index: true
      add :customer_id, :integer, null: false, index: true

      timestamps()
    end
  end
end
