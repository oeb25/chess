defmodule Chess.GamesTest do
  use Chess.DataCase

  alias Chess.Games
  alias Chess.Games.{Game, Participant, RuleSet, Action, Board}
  alias Action.Move

  @create_attrs %{
    actions: [
      %{type: :move, from: :A2, to: :A3}
    ],
    black: %{
      type: :anonymus,
      user_id: "retrstrdiuoaupyoift"
    },
    rule_set: %{
      type: :standard,
      time_limit: :infinite
    },
    white: %{
      type: :anonymus,
      user_id: "retrstrdiuoaupyoift"
    }
  }
  @update_attrs %{
    actions: [
      %{type: :move, from: :A2, to: :A3},
      %{type: :move, from: :A7, to: :A5}
    ],
    black: %{
      type: :user,
      user_id: "retrstrdiuoaupyoift"
    },
    rule_set: %{
      type: :standard,
      time_limit: 12364,
    },
    white: %{
      type: :user,
      user_id: "retrstrdiuoaupyoift"
    }
  }
  @invalid_attrs %{actions: nil, black: nil, rule_set: nil, white: nil}

  def fixture(:game, attrs \\ @create_attrs) do
    {:ok, game} = Games.create_game(attrs)
    game
  end

  test "list_games/1 returns all games" do
    game = fixture(:game)
    assert Games.list_games() == [game]
  end

  test "get_game! returns the game with given id" do
    game = fixture(:game)
    assert Games.get_game!(game.id) == game
  end

  test "create_game/1 with valid data creates a game" do
    assert {:ok, %Game{} = game} = Games.create_game(@create_attrs)

    assert game.actions == [
      %Move{from: :A2, to: :A3},
    ]
    assert game.black == %Participant{
      type: :anonymus,
      user_id: "retrstrdiuoaupyoift"
    }
    assert game.rule_set == %RuleSet{
      type: :standard,
      time_limit: :infinite
    }
    assert game.white == %Participant{
      type: :anonymus,
      user_id: "retrstrdiuoaupyoift"
    }
  end

  test "create_game/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
  end

  test "update_game/2 with valid data updates the game" do
    game = fixture(:game)
    assert {:ok, game} = Games.update_game(game, @update_attrs)
    assert %Game{} = game

    assert game.actions == [
      %Move{from: :A2, to: :A3},
      %Move{from: :A7, to: :A5}
    ]
    assert game.black == %Participant{
      type: :user,
      user_id: "retrstrdiuoaupyoift"
    }
    assert game.rule_set == %RuleSet{
      type: :standard,
      time_limit: 12364,
    }
    assert game.white == %Participant{
      type: :user,
      user_id: "retrstrdiuoaupyoift"
    }
  end

  test "update_game/2 with invalid data returns error changeset" do
    game = fixture(:game)
    assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
    assert game == Games.get_game!(game.id)
  end

  test "delete_game/1 deletes the game" do
    game = fixture(:game)
    assert {:ok, %Game{}} = Games.delete_game(game)
    assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
  end

  test "change_game/1 returns a game changeset" do
    game = fixture(:game)
    assert %Ecto.Changeset{} = Games.change_game(game)
  end

  test "bishop movement" do
    board =
      Board.standard_board
      |> Board.move(:C1, :E4)

    assert board |> Board.at(:E4) == {:white, :bishop}
    assert board |> Board.moves_for(:E4) == [:D5, :D3, :F5, :F3, :C6, :G6]
  end

  test "rook movement" do
    board =
      Board.standard_board
      |> Board.move(:A1, :E4)
      |> Board.move(:E8, :E6)

    assert board |> Board.at(:E4) == {:white, :rook}
    assert board |> Board.moves_for(:E4) == [:E5, :D4, :E3, :F4, :C4, :G4, :B4, :H4, :A4]
  end

  test "queen movement" do
    board =
      Board.standard_board
      |> Board.move(:E1, :E4)

    assert board |> Board.at(:E4) == {:white, :queen}
    assert board |> Board.moves_for(:E4) == [:D5, :D3, :F5, :F3, :C6, :G6, :E5, :D4, :E3, :F4, :E6, :C4, :G4, :B4, :H4, :A4]
  end

  test "knight movement" do
    board =
      Board.standard_board
      |> Board.move(:B1, :E5)

    assert board |> Board.at(:E5) == {:white, :knight}
    assert board |> Board.moves_for(:E5) == [:D3, :F3, :D7, :F7, :G6, :G4, :C6, :C4]
  end

  test "king movement" do
    board =
      Board.standard_board
      |> Board.move(:D1, :E5)

    assert board |> Board.at(:E5) == {:white, :king}
    assert board |> Board.moves_for(:E5) == [:D4, :E4, :F4, :D5, :F5, :D6, :E6, :F6]
  end

  test "pawn movement" do
    board =
      Board.standard_board
      |> Board.move(:C2, :C3)
      |> Board.move(:D2, :C6)
      |> Board.move(:E2, :A6)

    assert board |> Board.at(:B2) == {:white, :pawn}
    assert board |> Board.moves_for(:B2) == [:B3, :B4]

    assert board |> Board.at(:C3) == {:white, :pawn}
    assert board |> Board.moves_for(:C3) == [:C4]

    assert board |> Board.at(:B7) == {:black, :pawn}
    assert board |> Board.moves_for(:B7) == [:B6, :B5, :C6, :A6]
  end
end
