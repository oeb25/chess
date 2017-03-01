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
  import State, only: [valid_moves: 2, piece_at: 2, move: 3, check?: 3]
  import Chess.Move.Position, only: [to_atom: 1]
  @valid_attrs %{
    board: Game.standard_chess_board,
  }
  @board @valid_attrs.board

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

  test "check empty" do
    assert check?(:B3, @board, :empty)
  end

  test "check not empty" do
    assert check?(:B3, @board, :not_empty)
  end

  test "move one piece" do
    state = @valid_attrs

    assert piece_at(state, :B2) == [:white, :pawn]
    assert piece_at(state, :B3) == :empty
    state = state |> move(:B2, :B3)
    assert piece_at(state, :B2) == :empty
    assert piece_at(state, :B3) == [:white, :pawn]
  end

  test "valid moves for pawn at start" do
    assert @valid_attrs |> valid_moves(:B2) |> to_atom == [:B3, :B4, :A3]
    assert @valid_attrs |> valid_moves(:E7) |> to_atom == [:E6, :E5]
  end

  test "valid moves for pawn after move" do
    assert @valid_attrs |> move(:B2, :B3) |> valid_moves(:B3) |> to_atom == [:B4]
    assert @valid_attrs |> move(:F7, :F5) |> valid_moves(:F5) |> to_atom == [:F4]
  end

  test "invalidate move if target position taken" do
    state = @valid_attrs |> move(:A1, :A3)
    assert state |> piece_at(:A4) == :empty
    assert state |> valid_moves(:A2) == []
  end

  test "pond attack" do
    state = @valid_attrs |> move(:A7, :C3)
    assert piece_at(state, :C3) == [:black, :pawn]
    assert valid_moves(state, :D2) |> to_atom == [:D3, :D4, :C3]

    assert piece_at(state, :C3) == [:black, :pawn]
    state = state |> move(:C3, :E3)
    assert piece_at(state, :E3) == [:black, :pawn]
    assert valid_moves(state, :D2) |> to_atom == [:D3, :D4, :E3]
  end

  test "rook movement" do
    state = @valid_attrs |> move(:A1, :B4)
    assert piece_at(state, :B4) == [:white, :rook]
    assert valid_moves(state, :B4) |> to_atom == [:B3, :B5, :B6, :B7, :C4, :D4, :E4, :F4, :G4, :H4, :A4]

    state = state |> move(:B7, :G4)
    assert piece_at(state, :G4) == [:black, :pawn]
    assert valid_moves(state, :B4) |> to_atom == [:B3, :B5, :B6, :B7, :B8, :C4, :D4, :E4, :F4, :G4, :A4]
  end

  test "knight movement" do
    state = @valid_attrs |> move(:B1, :C4)
    assert piece_at(state, :C4) == [:white, :knight]
    assert state |> valid_moves(:C4) |> to_atom == [:E3, :A3, :E5, :A5, :D6, :B6]
  end

  test "bishop movement" do
    state = @valid_attrs |> move(:C1, :C4)
    assert piece_at(state, :C4) == [:white, :bishop]
    assert state |> valid_moves(:C4) |> to_atom == [:B5, :A6, :D5, :E6, :F7, :B3, :D3]
  end

  test "king movement" do
    state = @valid_attrs |> move(:D1, :C3) |> move(:H2, :D4)
    assert piece_at(state, :C3) == [:white, :king]
    assert state |> valid_moves(:C3) |> to_atom
      == [:B4, :C4, :B3, :D3]
  end

  test "queen movement" do
    state = @valid_attrs |> move(:E1, :C4)
    assert piece_at(state, :C4) == [:white, :queen]
    assert state |> valid_moves(:C4) |> to_atom
      == [:B5, :A6, :D5, :E6, :F7, :B3, :D3, :C3, :C5, :C6, :C7, :D4, :E4, :F4, :G4, :H4, :B4, :A4]
  end

  test "no moves for empty position" do
    assert @valid_attrs |> valid_moves(:D4) == []
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
