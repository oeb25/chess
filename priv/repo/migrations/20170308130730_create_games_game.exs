defmodule Chess.Repo.Migrations.CreateChess.Games.Game do
  use Ecto.Migration

  def change do
    create table(:games_games) do
      add :white, :json
      add :black, :json
      add :actions, {:array, :map}
      add :rule_set, :json

      timestamps()
    end

  end
end
