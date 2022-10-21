defmodule CandyMart.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :token, :binary
      add :context, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end
  end
end
