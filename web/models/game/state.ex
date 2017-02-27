defmodule Chess.Game.State do
  @behaviour Ecto.Type
  def type, do: :map

  alias Chess.{Game.Piece, Move.Position}
  import Position, only: [to_indices: 1]

  def cast(%{board: board}) when is_list(board) do
    board = for row <- board do
      for piece <- row, do: Piece.cast(piece)
    end

    if board |> Enum.all?(fn(row) -> row |> Enum.all?(&(&1 != :error)) end) do
      board = for row <- board do
        for piece <- row, do: elem(piece, 1) 
      end

      {:ok, %{board: board}}
    else
      :error
    end
  end
  def cast(_), do: :error

  def load(%{"board" => board}), do: load(%{board: board})
  def load(%{board: board}) when is_list(board) do
    board = for row <- board do
      for piece <- row, do: Piece.load(piece)
    end
    
    if Enum.all?(board, fn(row) -> row |> Enum.all?(&(&1 != :error)) end) do
      board =
        board
        |> Enum.map(fn(row) ->
          Enum.map(row, fn(piece) ->
            elem(piece, 1)
          end)
        end)

      {:ok, %{board: board}}
    else
      :error
    end
  end
  def load(_), do: :error

  def dump(map) when is_map(map) do
    {:ok, map}
  end
  def dump(_), do: :error

  def move(%{board: board}, from, to) do
    %{
      board: board |> move(from, to)
    }
  end
  def move(board, from, to) when is_atom(from), do: move(board, to_indices(from), to)
  def move(board, from, to) when is_atom(to), do: move(board, from, to_indices(to))
  def move(board, [a, b], [c,d]) do
    board
    |> Enum.flat_map(&(&1))
    |> List.replace_at(c * 8 + d, board |> Enum.at(a) |> Enum.at(b))
    |> List.replace_at(a * 8 + b, :empty)
    |> Enum.chunk(8)
  end

  def piece_at(%{board: board}, pos), do: piece_at(board, pos)
  def piece_at(board, [a, b]) do
    board |> Enum.at(a) |> Enum.at(b)
  end
  def piece_at(board, pos) when is_atom(pos), do: piece_at(board, to_indices(pos))

  def valid_moves(%{board: board} = state, pos) when is_atom(pos) do
    valid_moves(state, to_indices(pos))
  end 
  def valid_moves(%{board: board} = state, pos) do
    valid_moves(state, piece_at(board, pos), pos)
  end

  def all_possible([a, b], :right) do
    min(a + 1, 7)..min(a + 8, 7)
    |> do_all_possible(b, :b)
  end
  def all_possible([a, b], :left) do
    max(a - 1, 0)..max(a - 8, 0)
    |> do_all_possible(b, :b)
  end
  def all_possible([a, b], :up) do
    max(b - 1, 0)..max(b - 8, 0)
    |> do_all_possible(a, :a)
  end
  def all_possible([a, b], :down) do
    min(b + 1, 7)..min(b + 8, 7)
    |> do_all_possible(a, :a)
  end
  def all_possible(pos, dir), do: pos |> all_possible(dir)
  def do_all_possible(positions, a, :a) do
    for b <- positions, do: [a, b]
  end
  def do_all_possible(positions, b, :b) do
    for a <- positions, do: [a, b]
  end

  def straight(pos) do
    for dir <- [:right, :left, :down, :up], do: all_possible(pos, dir)
  end

  def diagonal([a, b]) do
    left_down = for i <- 1..min(a, b), do: [a - i, b - i]
    left_up = for i <- 1..min(a, 7 - b), do: [a - i, b + i]
    right_down = for i <- 1..max(7 - a, b), do: [a + i, b - i]
    right_up = for i <- 1..max(a, 7 - b), do: [a + i, b + i]

    for dir <- [left_down, left_up, right_down, right_up] do
      for [a, b] <- dir, a in 0..7 and b in 0..7 do
        [a, b]
      end
    end
  end

  defp check?(pos, board, :empty) do
    piece_at(board, pos) == :empty
  end
  defp check?(pos, board, :not_empty) do
    piece_at(board, pos) != :empty
  end
  defp check?(pos, board, {:not_suit, suit}) do
    case piece_at(board, pos) do
      [s, _] when s == suit ->
        false
      _ ->
        true
    end
  end
  defp check?(pos, board, {:direct_acces, start}) do
    possible_straight = start |> straight
    possible_diagonal = start |> diagonal

    possible =
      (possible_straight ++ possible_diagonal)
      |> Enum.flat_map(fn(dir) ->
        i = Enum.find_index(dir, fn(pos) ->
          piece_at(board, pos) != :empty
        end)

        case i do
          nil -> dir
          i -> Enum.take(dir, i + 1)
        end
      end)

    pos in possible
  end

  defp only_if(positions, board, rule) do
    for pos <- positions, check?(pos, board, rule), do: pos
  end

  def valid_moves(%{board: board}, [suit, :pawn], [r, c] = pos) do
    v = case suit do
      :black -> -1
      :white -> 1
    end

    x = case {suit, pos} do
      {:black, [1, c]} ->
        [[2, c], [3, c]]
      {:white, [6, c]} ->
        [[5, c], [4, c]]
      {_, [r, c]} ->
        [[r - v, c]]
    end
    |> only_if(board, :empty)
    |> only_if(board, {:direct_acces, pos})

    y =
      [[r - v, c + 1], [r - v, c - 1]]
      |> Enum.filter(fn([r, c]) -> r in 0..7 and c in 0..7 end)
      |> only_if(board, :not_empty)
      |> only_if(board, {:not_suit, suit})

    x ++ y
  end

  def valid_moves(%{board: board}, [suit, :rook], pos) do
    pos
    |> straight
    |> Enum.flat_map(&(&1))
    |> only_if(board, {:not_suit, suit})
    |> only_if(board, {:direct_acces, pos})
  end

  def valid_moves(%{board: board}, [suit, :bishop], pos) do
    pos
    |> diagonal
    |> Enum.flat_map(&(&1))
    |> only_if(board, {:not_suit, suit})
    |> only_if(board, {:direct_acces, pos})
  end

  def valid_moves(%{board: board}, [suit, :queen], pos) do
    (diagonal(pos) ++ straight(pos))
    |> Enum.flat_map(&(&1))
    |> only_if(board, {:not_suit, suit})
    |> only_if(board, {:direct_acces, pos})
  end

  def valid_moves(%{board: board}, [suit, :king], [sa, sb] = pos) do
    for a <- -1..1, b <- -1..1, (a != 0 or b != 0) and (sa + a) in 0..7 and (sb + b) in 0..7 do
      [sa + a, sb + b]
    end
    |> only_if(board, {:not_suit, suit})
    |> only_if(board, {:direct_acces, pos})
  end

  def valid_moves(%{board: board}, [suit, :knight], [a, b]) do
   spots = [
      [a + 1, b + 2], [a + 1, b - 2], [a - 1, b + 2], [a - 1, b - 2],
      [a + 2, b + 1], [a + 2, b - 1], [a - 2, b + 1], [a - 2, b - 1],
    ]
    for [a, b] <- spots, a in 0..7 and b in 0..7 do [a, b] end
    |> only_if(board, {:not_suit, suit})
  end

  def valid_moves(_, :empty, _), do: []

  def valid_move?(state, from, to) do
    to in valid_moves(state, piece_at(state, from), to)
  end
end
