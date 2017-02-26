# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chess.Repo.insert!(%Chess.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Chess.{Repo, User, Game, Move}

bob =
  %User{
    email: "bob@email.com",
    name: "Bob",
    password: "password",
  }
  |> Ecto.Changeset.change()
  |> Repo.insert!

alice =
  %User{
    email: "alice@email.com",
    name: "Alice",
    password: "password",
  }
  |> Ecto.Changeset.change()
  |> Repo.insert!

game1 =
  Game.changeset(%Game{}, %{
    initial_state: %{
      board: Game.standard_chess_board,
    },
    game_type: "chess",
    moves: [],
  })
  |> Ecto.Changeset.change()
  |> Repo.insert!

game1
|> Repo.preload(:users)
|> Ecto.Changeset.change()
|> Ecto.Changeset.put_assoc(:users, [bob, alice])
|> Repo.update!

moves = [
  %{from: :A2, to: :A4, user: bob, game: game1},
  %{from: :E7, to: :E5, user: alice, game: game1},
]

for move <- moves do
  Move.changeset(%Move{}, move)
  |> Ecto.Changeset.put_assoc(:game, move.game)
  |> Ecto.Changeset.put_assoc(:user, move.user)
  |> Repo.insert!
end
