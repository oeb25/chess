defmodule Chess.Games.Board do
  @behaviour Ecto.Type
  def type, do: :array

  alias Chess.Games.{Square, Board}

  @spec cast(t) :: {:ok, t}
  def cast(a), do: {:ok, a}

  @spec load(t) :: :error
  def load(_), do: :error

  @spec dump(t) :: :error
  def dump(_), do: :error

  @standard_board [
    {:black, :rook}, {:black, :knight}, {:black, :bishop}, {:black, :queen}, {:black, :king}, {:black, :bishop}, {:black, :knight}, {:black, :rook},
    {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn}, {:black, :pawn},
    :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
    :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
    :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
    :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty,
    {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn}, {:white, :pawn},
    {:white, :rook}, {:white, :knight}, {:white, :bishop}, {:white, :king}, {:white, :queen}, {:white, :bishop}, {:white, :knight}, {:white, :rook}
  ]

  def standard_board, do: @standard_board

  @type piece_type :: :rook | :knight | :bishop | :queen | :king | :pawn
  @type suit :: :black | :white
  @type piece :: {suit, piece_type} | :empty
  @type t :: [piece]

  @spec at(t, Square.t) :: piece
  def at(board, sq) do
    board |> Enum.at(sq |> Square.to_index)
  end

  @spec put(t, Square.t, piece) :: t
  def put(board, sq, piece) do
    board |> List.replace_at(sq |> Square.to_index, piece)
  end

  @spec moves_for(t, Square.t) :: [Square.t]
  def moves_for(board, sq) do
    {_, _, moves} = Board.Context.moves_for({board, sq, []}, board |> at(sq))

    moves
  end

  @spec move(t, Square.t, Square.t) :: t
  def move(board, from, to) do
    piece = board |> at(from)

    board
    |> put(to, piece)
    |> put(from, :empty)
  end
end

defmodule Chess.Games.Board.Context do
  defstruct [:board]

  alias Chess.Games
  alias Games.{Square, Board}

  @type ctx :: {Board.t, Square.t, [Square.t]}

  @spec diagonal(ctx) :: ctx
  defp diagonal({board, sq, moves}) do
    {r, c} = Square.to_indicies(sq)

    new_moves = for k <- 1..7,
      a <- [-1, 1],
      b <- [-1, 1],
      x <- [c + k * a],
      y <- [r + k * b],
      x in 0..7 and y in 0..7 do Square.cast! {y, x} end

    {board, sq, Enum.uniq moves ++ new_moves}
  end

  @spec straight(ctx) :: ctx
  defp straight({board, sq, moves}) do
    {r, c} = Square.to_indicies(sq)

    new_moves = for k <- 1..7,
      a <- [-1, 1],
      {b, d} <- [{0, 1}, {1, 0}],
      x <- [c + k * a * b],
      y <- [r + k * a * d],
      x in 0..7 and y in 0..7 do
        Square.cast! {y, x}
      end

    {board, sq, Enum.uniq moves ++ new_moves}
  end

  @spec relative(ctx, {integer, integer}) :: ctx
  defp relative({board, sq, moves} = ctx, {r, c}) do
    {rs, cs} = sq |> Square.to_indicies

    new = {r + rs, c + cs}

    case Square.cast(new) do
      {:ok, pos} -> {board, sq, moves ++ [pos]}
      _ -> ctx
    end

  end

  @spec can_see?(ctx) :: ctx
  defp can_see?({board, sq, moves} = ctx) do
    moves = for move <- moves, can_see?(ctx, move), do: move

    {board, sq, moves}
  end

  @spec not_empty?(ctx) :: ctx
  defp not_empty?({board, sq, moves} = ctx) do
    moves = for move <- moves, not empty?(ctx, move), do: move

    {board, sq, moves}
  end

  @spec empty?(ctx) :: ctx
  defp empty?({board, sq, moves} = ctx) do
    moves = for move <- moves, empty?(ctx, move), do: move

    {board, sq, moves}
  end

  @spec empty?(ctx, Square.t) :: boolean
  defp empty?({board, _, _}, p) do
    board |> Board.at(p) == :empty
  end

  @spec can_kill?(ctx) :: ctx
  defp can_kill?({board, sq, moves} = ctx) do
    moves = for move <- moves, can_kill?(ctx, move), do: move

    {board, sq, moves}
  end

  @spec can_kill?(ctx, Square.t) :: boolean
  defp can_kill?({board, sq, _}, p) do
    {own_suit, _} = board |> Board.at(sq)
    other = board |> Board.at(p)

    case other do
      {other_suit, _} when other_suit == own_suit -> false
      _ -> true
    end
  end

  @spec can_see?(ctx, Square.t) :: boolean
  defp can_see?({_, sq, _} = ctx, move) do
    {r1, c1} = sq |> Square.to_indicies
    {r2, c2} = move |> Square.to_indicies

    if abs(r1 - r2) == abs(c1 - c2) or r1 == r2 or c1 == c2 do obstacles =
      for x <- 0..(c2 - c1),
        y <- 0..(r2 - r1),
        pos <- [{r1 + y, c1 + x} |> Square.cast!],
        pos != sq,
        !empty?(ctx, pos),
        do: pos

      obstacles == []
    else
      false
    end
  end

  @spec join(ctx, ctx) :: ctx
  defp join({board, sq, moves1}, {board, sq, moves2}) do
    {board, sq, Enum.uniq(moves1 ++ moves2)}
  end

  @spec moves_for(ctx, Board.piece) :: ctx
  def moves_for(ctx, {_, :queen}) do
    ctx
    |> diagonal
    |> straight
    |> can_see?
    |> can_kill?
  end

  def moves_for(ctx, {_, :rook}) do
    ctx
    |> straight
    |> can_see?
    |> can_kill?
  end

  def moves_for(ctx, {_, :bishop}) do
    ctx
    |> diagonal
    |> can_see?
    |> can_kill?
  end

  def moves_for(ctx, {_, :knight}) do
    ctx
    |> relative({2, -1})
    |> relative({2, 1})
    |> relative({-2, -1})
    |> relative({-2, 1})

    |> relative({-1, 2})
    |> relative({1, 2})
    |> relative({-1, -2})
    |> relative({1, -2})

    |> can_kill?
  end

  def moves_for(ctx, {_, :king}) do
    ctx
    |> relative({1, -1})
    |> relative({1, 0})
    |> relative({1, 1})

    |> relative({0, -1})
    |> relative({0, 1})

    |> relative({-1, -1})
    |> relative({-1, 0})
    |> relative({-1, 1})

    |> can_kill?
  end

  def moves_for({_, sq, _} = ctx, {suit, :pawn}) do
    {i, n} = case suit do
      :white -> {-1, 6}
      :black -> {1, 1}
    end

    pos = Square.to_indicies(sq)

    aa =
      ctx
      |> relative({i, 0})
      |> empty?

    a = case pos do
      {^n, _} -> aa |> relative({2 * i, 0})
      _ -> aa
    end

    b =
      ctx
      |> relative({i, 1})
      |> relative({i, -1})
      |> not_empty?
      |> can_kill?

    join a, b
  end

  def moves_for(ctx, :empty) do
    ctx
  end
end
