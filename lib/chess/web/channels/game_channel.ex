defmodule Chess.Web.GameChannel do
  use Phoenix.Channel

  alias Chess.Games
  alias Games.{Game, Square}
  alias Chess.Web.GameView

  @type action :: String.t

  @spec render_game(Game.t) :: String.t
  def render_game(game), do: GameView.render("game.json", %{game: game})

  def join("game:" <> game_id, _, socket) do
    game =
      with {id, _} <- Integer.parse(game_id), do: id
      |> Games.get_game!
      |> Game.compute_board
      |> render_game

    {:ok, game, socket
      |> assign(:id, game.id)}
  end

  # @spec handle_in(action, msg :: map, Phoenix.Socket.t) ::
  #   {:noreply, Phoenix.Socket.t} |
  #   {:reply, reply, Phoenix.Socket.t} |
  #   {:stop, reason :: term, Phoenix.Socket.t} |
  #   {:stop, reason :: term, reply, Phoenix.Socket.t}
  def handle_in("get_game_state", _, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Game.compute_board
      |> render_game

    broadcast! socket, "gamestate", game

    {:reply, {:ok, game}, socket}
  end

  def handle_in("get_moves_for", %{"for" => [r, c]}, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Game.compute_board

    moves = for m <- Games.moves_for(game, [r, c] |> Square.cast!) do
      {r, c} = m |> Square.to_indicies
      [r, c]
    end

    {:reply, {:ok, %{"moves" => moves}}, socket}
  end

  def handle_in("move", %{"from" => from, "to" => to}, socket) do
    game =
      socket.assigns.id
      |> Games.get_game!
      |> Game.compute_board

    [from, to] = for sq <- [from, to], do: sq |> Square.cast!

    case Games.move game, from, to do
      {:ok, game} ->
        game = game |> Game.recompute_board
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
