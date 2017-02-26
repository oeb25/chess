defmodule Chess.Repo.Migrations.CreateGame do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :initial_state, :map
      add :game_type, :string
      add :moves, {:array, :map}

      timestamps()
    end

    # create table(:games_users, primay_key: false) do
    #   add :user_id, references(:users)
    #   add :game_id, references(:games)
    # end

  end
end
