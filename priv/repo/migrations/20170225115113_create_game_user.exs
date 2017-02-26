defmodule Chess.Repo.Migrations.CreateGameUser do
  use Ecto.Migration

  def change do
    create table(:games_users, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing, type: :uuid)
      add :game_id, references(:games, on_delete: :nothing)
    end
    create index(:games_users, [:user_id])
    create index(:games_users, [:game_id])

  end
end
