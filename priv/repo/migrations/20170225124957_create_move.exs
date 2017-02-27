defmodule Chess.Repo.Migrations.CreateMove do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :from, :integer
      add :to, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end
    create index(:moves, [:user_id])
    create index(:moves, [:game_id])

  end
end
