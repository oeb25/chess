defmodule Chess.Game do
  use Chess.Web, :model

  @game_types ["chess"]

  schema "games" do
    field :initial_state, Chess.Game.State
    field :game_type, :string

    many_to_many :users, Chess.User, join_through: "games_users"
    has_many :moves, Chess.Move

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:initial_state, :game_type])
    |> validate_required([:initial_state, :game_type])
    |> validate_inclusion(:game_type, ["chess"])
  end

  def white(piece), do: {:white, piece}
  def black(piece), do: {:black, piece}

  def standard_chess_board, do: [
    [[:black, :rook], [:black, :knight], [:black, :bishop], [:black, :queen], [:black, :king], [:black, :bishop], [:black, :knight], [:black, :rook]],
    [[:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn]],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [[:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn]],
    [[:white, :rook], [:white, :knight], [:white, :bishop], [:white, :king], [:white, :queen], [:white, :bishop], [:white, :knight], [:white, :rook]]
  ]

  def empty_chess_board, do: [
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
    [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
  ]

  alias Chess.{Move, Move.Position}

  def piece_at(%Chess.Game{} = game, pos) do
    state =
      game
      |> compute_current_state

    Chess.Game.State.piece_at(state, pos)
  end

  def compute_current_state(%Chess.Game{} = game) do
    compute_current_state(game.initial_state, game.moves)
  end
  def compute_current_state(%{board: board}, moves) when is_list(moves) do
    board =
      moves
      |> Enum.reduce(board, fn(move, board) ->
        Chess.Game.State.move(board, move.from, move.to)
      end)

    %{board: board}
  end
end
