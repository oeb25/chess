defmodule Chess.Games do
  @moduledoc """
  The boundary for the Games system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias Chess.Repo

  alias Chess.Games.Game
  alias Chess.Games.Board
  alias Chess.Games.Square
  alias Chess.Games.Action

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    for game <- Repo.all(Game), do: game |> Game.compute_board
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(game, %{field: value})
      {:ok, %Game{}}

      iex> create_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> game_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> game_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    game_changeset(game, %{})
  end

  defp game_changeset(%Game{} = game, attrs) do
    game
    |> cast(attrs, [:white, :black, :actions, :rule_set])
    |> validate_required([:white, :black, :actions, :rule_set])
  end

  def moves_for(%Game{} = game, sq) do
    game = game |> Game.compute_board

    Board.moves_for game.board, sq
  end

  @spec move(Game.t, Square.t, Square.T) :: {:ok, Game.t} | {:error, %Ecto.Changeset{}} | :error
  def move(%Game{} = game, from, to) do
    game = game |> Game.compute_board
    whos_turn = game |> Game.whos_turn

    case game.board |> Board.at(from) do
      :empty -> :error
      {color, _} when color != whos_turn -> :error
      _ ->
        if to in Board.moves_for game.board, from do
          actions = game.actions ++ [%{type: :move, from: from, to: to} |> Action.cast!]

          update_game(game, %{actions: actions})
        else
          :error
        end
    end
  end
end
