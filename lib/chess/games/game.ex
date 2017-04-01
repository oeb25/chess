defmodule Chess.Games.Game do
  use Ecto.Schema

  alias Chess.Games.{Participant, Action, RuleSet, Board}

  schema "games_games" do
    field :white, Participant
    field :black, Participant
    field :actions, {:array, Action}
    field :rule_set, RuleSet
    field :board, Board, virtual: true, default: :not_computed

    timestamps()
  end

  # defstruct [:white, :black, :actions, :rule_set, :board]
  @type t :: %__MODULE__{white: Piece.t, black: Piece.t, actions: Actions.t, rule_set: RuleSet.t, board: Board.t}

  @spec recompute_board(t) :: t
  def recompute_board(%__MODULE__{actions: actions} = game) do
    actions |> Enum.reduce(%{game | board: Board.standard_board}, &perform_action(&2, &1))
  end

  @spec compute_board(t) :: t
  def compute_board(%__MODULE__{board: :not_computed, actions: actions} = game) do
    recompute_board(game)
  end
  def compute_board(%__MODULE__{} = game) do
    game
  end

  @spec perform_action(t, Action.t) :: t
  def perform_action(%__MODULE__{board: board} = game, %Action.Move{from: from, to: to}) do
    %{game | board: board |> Board.move(from, to)}
  end

  def whos_turn(%__MODULE__{actions: actions} = game) do
    i =
      actions
      |> Enum.count(fn a -> a.__struct__ == Action.Move end)
      |> Integer.mod(2)

    case i do
      0 -> :white
      1 -> :black
    end
  end
end
