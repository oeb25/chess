defmodule Chess.Web.GameView do
  use Chess.Web, :view
  alias Chess.Web.GameView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", game = %Chess.Games.Game{}) do
    render("game.json", %{game: game})
  end
  def render("game.json", %{game: game}) do
    {:ok, white} = game.white |> Chess.Games.Participant.dump
    {:ok, black} = game.black |> Chess.Games.Participant.dump

    who = game |> Chess.Games.Game.whos_turn

    %{id: game.id,
      white: white |> Poison.decode!,
      black: black |> Poison.decode!,
      actions: game.actions,
      rule_set: game.rule_set,
      board: game.board,
      who: who}
  end
end
