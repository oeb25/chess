defmodule Chess.Repo.Migrations.CreateChess.Auth.User do
  use Ecto.Migration

  def change do
    create table(:auth_users) do
      add :name, :string
      add :email, :string
      add :hashed_password, :string

      timestamps()
    end

  end
end
