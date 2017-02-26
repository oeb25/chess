defmodule Chess.User do
  use Chess.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :password, :string
    field :name, :string

    has_many :moves, Chess.Move
    many_to_many :games, Chess.Game, join_through: "games_users"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :email, :password, :name])
    |> unique_constraint(:email)
    |> validate_required([:email, :password, :name])
  end
end
