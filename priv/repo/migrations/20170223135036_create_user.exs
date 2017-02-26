defmodule Chess.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string
      add :password, :string
      add :name, :string

      timestamps()
    end

    create unique_index(:users, [:email])

  end
end
