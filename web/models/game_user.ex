defmodule Chess.GameUser do
  use Chess.Web, :model

  schema "games_users" do
    belongs_to :user, Chess.User, type: :binary_id
    belongs_to :game, Chess.Game
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :game_id])
    |> validate_required([:user_id, :game_id])
  end
end
