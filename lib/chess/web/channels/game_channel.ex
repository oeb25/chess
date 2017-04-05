defmodule Chess.Web.GameChannel do
  use Phoenix.Channel

  alias Chess.Games
  alias Chess.Web.GameView

  def join("game:" <> game_id, _, socket) do
    id = with {id, _} <- Integer.parse(game_id),
          do: id

    game =
      id
      |> Games.get_game!
      |> Games.Game.compute_board

    game = Chess.Web.GameView.render("game.json", game)

    send(self, "get_game_state")

    {:ok, game, socket
      |> assign(:id, game.id)}
  end

  def handle_in("get_game_state", _, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Games.Game.compute_board

    game = GameView.render("game.json", %{game: game})

    broadcast! socket, "gamestate", game

    {:reply, {:ok, game}, socket}
  end

  def handle_in("get_moves_for", %{"for" => [r, c]}, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Games.Game.compute_board

    moves = for m <- Games.moves_for(game, [r, c] |> Games.Square.cast!) do
      {r, c} = m |> Games.Square.to_indicies
      [r, c]
    end

    {:reply, {:ok, %{"moves" => moves}}, socket}
  end

  def handle_in("move", %{"from" => from, "to" => to}, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Games.Game.compute_board

    [from, to] = for sq <- [from, to], do: sq |> Games.Square.cast!

    case Games.move game, from, to do
      {:ok, game} ->
        game = game |> Games.Game.recompute_board
        game = GameView.render("game.json", %{game: game})

        broadcast! socket, "gamestate", game

        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, :error, socket}
      :error ->
        {:reply, :error, socket}
    end
  end
end
