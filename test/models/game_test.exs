defmodule Chess.GameTest do
  use Chess.ModelCase

  alias Chess.{Game, Move}

  @valid_attrs %{
    initial_state: %{
      board: Game.standard_chess_board,
    },
    moves: [
      %Move{
        from: "A2",
        to: "A3",
      },
    ],
    game_type: "chess"
  }
  @invalid_attrs %{}
  @game %Game{
    initial_state: @valid_attrs.initial_state,
    moves: @valid_attrs.moves,
    game_type: @valid_attrs.game_type,
  }

  test "changeset with valid attributes" do
    changeset = Game.changeset(%Game{}, @valid_attrs)
    assert changeset.valid?
  end

  # test "changeset with invalid attributes" do
  #   changeset = Game.changeset(%Game{}, @invalid_attrs)
  #   refute changeset.valid?
  # end
end

defmodule Chess.GameStateTest do
  use Chess.ModelCase

  alias Chess.Game
  alias Chess.Game.State

  @valid_attrs %{
    board: Game.standard_chess_board,
  }

  test "casting valid board" do
    state = State.cast(@valid_attrs)

    assert state != :error
    state = state |> elem(1)

    assert %{board: [[[:black, :rook], [:black, :knight], [:black, :bishop], [:black, :queen], [:black, :king], [:black, :bishop], [:black, :knight], [:black, :rook]], [[:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn]], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [[:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn]], [[:white, :rook], [:white, :knight], [:white, :bishop], [:white, :king], [:white, :queen], [:white, :bishop], [:white, :knight], [:white, :rook]]]}
      == state
  end

  test "loading from generated cast" do
    load =
      State.cast(@valid_attrs)

    assert load != :error

    load = load
      |> elem(1)

    assert Game.standard_chess_board == load.board
  end

  test "git good" do
    loaded = State.load %{"board" => [["black:rook", "black:knight", "black:bishop", "black:queen", "black:king", "black:bishop", "black:knight", "black:rook"], ["black:pawn", "black:pawn", "black:pawn", "black:pawn", "black:pawn", "black:pawn", "black:pawn", "black:pawn"], ["empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty"], ["empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty"], ["empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty"], ["empty", "empty", "empty", "empty", "empty", "empty", "empty", "empty"], ["white:pawn", "white:pawn", "white:pawn", "white:pawn", "white:pawn", "white:pawn", "white:pawn", "white:pawn"], ["white:rook", "white:knight", "white:bishop", "white:king", "white:queen", "white:bishop", "white:knight", "white:rook"]]}

    assert {:ok, %{board: [[[:black, :rook], [:black, :knight], [:black, :bishop], [:black, :queen], [:black, :king], [:black, :bishop], [:black, :knight], [:black, :rook]], [[:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn], [:black, :pawn]], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty], [[:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn], [:white, :pawn]], [[:white, :rook], [:white, :knight], [:white, :bishop], [:white, :king], [:white, :queen], [:white, :bishop], [:white, :knight], [:white, :rook]]]}}
      == loaded
  end

  test "move one piece" do
    state = @valid_attrs

    assert State.piece_at(state, :B2) == [:white, :pawn]
    assert State.piece_at(state, :B3) == :empty
    state = state |> State.move(:B2, :B3)
    assert State.piece_at(state, :B2) == :empty
    assert State.piece_at(state, :B3) == [:white, :pawn]
  end

  test "valid moves for pawn at start" do
    assert @valid_attrs |> State.valid_moves(:B2) == [:B3, :B4]
    assert @valid_attrs |> State.valid_moves(:E7) == [:E6, :E5]
  end

  test "valid moves for pawn after move" do
    assert @valid_attrs |> State.move(:B2, :B3) |> State.valid_moves(:B3) == [:B4]
    assert @valid_attrs |> State.move(:F7, :F5) |> State.valid_moves(:F5) == [:F4]
  end

  test "invalidate move if target position taken" do
    state = @valid_attrs |> State.move(:A1, :A3)
    assert state |> State.piece_at(:A4) == :empty
    assert state |> State.valid_moves(:A2) == []
  end

  test "pond attack" do
    state = @valid_attrs |> State.move(:A7, :C3)
    assert State.piece_at(state, :C3) == [:black, :pawn]
    assert State.valid_moves(state, :B2) == [:B3, :B4, :C3]
  end

  test "rook movement" do
    state = @valid_attrs |> State.move(:A1, :B4)
    assert State.piece_at(state, :B4) == [:white, :rook]
    assert State.valid_moves(state, :B4) == [:B3, :B5, :B6, :B7, :C4, :D4, :E4, :F4, :G4, :H4, :A4]

    state = state |> State.move(:B7, :G4)
    assert State.piece_at(state, :G4) == [:black, :pawn]
    assert State.valid_moves(state, :B4) == [:B3, :B5, :B6, :B7, :B8, :C4, :D4, :E4, :F4, :G4, :A4]
  end

  test "knight movement" do
    state = @valid_attrs |> State.move(:B1, :C4)
    assert State.piece_at(state, :C4) == [:white, :knight]
    assert state |> State.valid_moves(:C4) == [:E3, :A3, :E5, :A5, :D6, :B6]
  end

  test "bishop movement" do
    state = @valid_attrs |> State.move(:C1, :C4)
    assert State.piece_at(state, :C4) == [:white, :bishop]
    assert state |> State.valid_moves(:C4) == [:B5, :A6, :D5, :E6, :F7, :B3, :D3]
  end

  test "king movement" do
    state = @valid_attrs |> State.move(:D1, :C3) |> State.move(:H2, :D4)
    assert State.piece_at(state, :C3) == [:white, :king]
    assert state |> State.valid_moves(:C3)
      == [:B4, :C4, :B3, :D3]
  end

  test "queen movement" do
    state = @valid_attrs |> State.move(:E1, :C4)
    assert State.piece_at(state, :C4) == [:white, :queen]
    assert state |> State.valid_moves(:C4)
      == [:B5, :A6, :D5, :E6, :F7, :B3, :D3, :C3, :C5, :C6, :C7, :D4, :E4, :F4, :G4, :H4, :B4, :A4]
  end

  test "no moves for empty position" do
    assert @valid_attrs |> State.valid_moves(:D4) == []
  end
end

defmodule Chess.GamePieceTest do
  use Chess.ModelCase

  alias Chess.Game.Piece

  @valid_attrs {:white, :queen}
  @invalid_attrs {:orange, :blop}

  test "encode decode" do
    assert {:ok, _} = Piece.cast(@valid_attrs)
    assert :error = Piece.cast(@invalid_attrs)
  end

  test "load from string" do

  end
end
