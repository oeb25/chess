defmodule Chess.Games.Game do
  use Ecto.Schema

  schema "games_games" do
    field :white, Chess.Games.Participant
    field :black, Chess.Games.Participant
    field :actions, {:array, Chess.Games.Action}
    field :rule_set, Chess.Games.RuleSet
    field :board, Chess.Games.Board, virtual: true

    timestamps()
  end
end
