defmodule Chess.RoomChannel do
  use Phoenix.Channel
  alias Chess.{Game, Repo, Move}

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("room:" <> game_id, _params, socket) do
    {:ok, socket |> assign(:game, Repo.get!(Chess.Game, game_id) |> Repo.preload(:moves))}
  end

  def handle_in("select", pos, socket) do
    game = socket.assigns[:game]
    game = Repo.get!(Chess.Game, game.id) |> Repo.preload(:moves)
    state =
      game
      |> Chess.Game.compute_current_state

    moves =
      state
      |> Chess.Game.State.valid_moves(pos)

    {:reply, {:ok, %{moves: moves}}, socket}
  end

  def handle_in("move", %{"from" => from, "to" => to}, socket) do
    game = socket.assigns[:game]
    game = Repo.get!(Chess.Game, game.id) |> Repo.preload(:moves)
    state =
      game
      |> Chess.Game.compute_current_state

    if to in Chess.Game.State.valid_moves(state, from) do
      Move.changeset(%Move{}, %{from: from, to: to})
      |> Ecto.Changeset.put_assoc(:game, game)
      # |> Ecto.Changeset.put_assoc(:user, move.user)
      |> Repo.insert!

      broadcast! socket, "move", %{from: from, to: to}
    end

    {:noreply, socket}
  end
end
