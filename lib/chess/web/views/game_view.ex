defmodule Chess.Web.GameView do
  use Chess.Web, :view
  alias Chess.Web.GameView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{id: game.id,
      white: game.white,
      black: game.black,
      actions: game.actions,
      rule_set: game.rule_set}
  end
end
