defmodule Chess.Web.GameView do
  use Chess.Web, :view
  alias Chess.Web.GameView
  alias Chess.Games.{Participant, Game}

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", game = %Game{}) do
    render("game.json", %{game: game})
  end
  def render("game.json", %{game: game}) do
    {:ok, white} = game.white |> Participant.dump
    {:ok, black} = game.black |> Participant.dump

    who = game |> Game.whos_turn

    %{id: game.id,
      white: white |> Poison.decode!,
      black: black |> Poison.decode!,
      actions: game.actions,
      rule_set: game.rule_set,
      board: game.board,
      who: who}
  end
end
