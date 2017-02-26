defmodule Chess.Game.State do
  @behaviour Ecto.Type
  def type, do: :map

  alias Chess.{Game.Piece, Move.Position}

  def cast(%{board: board}) when is_list(board) do
    board = board
    |> Enum.map(fn(row) -> Enum.map(row, &(Piece.cast(&1))) end)

    if board |> Enum.all?(fn(row) -> row |> Enum.all?(&(&1 != :error)) end) do
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
  def cast(_), do: :error

  def load(%{"board" => board}), do: load(%{board: board})
  def load(%{board: board}) when is_list(board) do
    board =
      board |> Enum.map(fn(row) -> row |> Enum.map(&(Piece.load(&1))) end)

    if Enum.all?(board, fn(row) -> row |> Enum.all?(&(&1 != :error)) end) or true do
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
  def move(board, from, to) do
    {a, b} = from |> Position.to_indices
    {c, d} = to |> Position.to_indices

    board
    |> List.update_at(c, fn(l) ->
      l |> List.update_at(d, fn(_) ->
        board |> Enum.at(a) |> Enum.at(b)
      end)
    end)
    |> List.update_at(a, fn(l) -> l |> List.update_at(b, fn(_) -> :empty end) end)
  end

  def piece_at(%{board: board}, pos), do: piece_at(board, pos)
  def piece_at(board, pos) do
    {a, b} = pos |> Position.to_indices

    board |> Enum.at(a) |> Enum.at(b)
  end

  def valid_moves(%{board: board} = state, pos) do
    valid_moves(state, piece_at(board, pos), pos)
  end

  def all_possible({a, b}, :right) do
    min(a + 1, 7)..min(a + 8, 7)
    |> do_all_possible(b, :b)
  end
  def all_possible({a, b}, :left) do
    max(a - 1, 0)..max(a - 8, 0)
    |> do_all_possible(b, :b)
  end
  def all_possible({a, b}, :up) do
    max(b - 1, 0)..max(b - 8, 0)
    |> do_all_possible(a, :a)
  end
  def all_possible({a, b}, :down) do
    min(b + 1, 7)..min(b + 8, 7)
    |> do_all_possible(a, :a)
  end
  def all_possible(pos, dir), do: all_possible(Position.to_indices(pos), dir)
  def do_all_possible(positions, a, :a) do
    positions |> Enum.map(fn(b) -> {a, b} |> Position.from_indices end)
  end
  def do_all_possible(positions, b, :b) do
    positions |> Enum.map(fn(a) -> {a, b} |> Position.from_indices end)
  end

  def straight(pos) do
    [:right, :left, :down, :up]
    |> Enum.map(&all_possible(pos, &1))
  end

  def diagonal(pos) do
    {a, b} = pos |> Position.to_indices

    left_down =
      1..min(a, b)
      |> Enum.map(&({a - &1, b - &1}))

    left_up =
      1..min(a, 7 - b)
      |> Enum.map(&({a - &1, b + &1}))

    right_down =
      1..min(7 - a, b)
      |> Enum.map(&({a + &1, b - &1}))

    right_up =
      1..min(a, 7 - b)
      |> Enum.map(&({a + &1, b + &1}))

    [left_down, left_up, right_down, right_up]
    |> Enum.map(fn(dir) ->
      dir = dir
      |> Enum.filter(fn({a, b}) -> a in 0..7 and b in 0..7 end)

      dir
      |> Enum.map(&Position.from_indices(&1))
    end)
  end

  defp check?(pos, board, :inbounds) do
    {a, b} = Position.to_indices(pos)

    a in 0..7 and b in 0..7
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
    positions
    |> Enum.filter(fn(pos) ->
      check?(pos, board, rule)
    end)
  end

  def valid_moves(%{board: board}, [suit, :pawn], pos) do
    v = case suit do
      :black -> 1
      :white -> -1
    end

    x = case {suit, Position.to_pair(pos)} do
      {:white, {a, 2}} ->
        [{a, 3}, {a, 4}]
      {:black, {a, 7}} ->
        [{a, 6}, {a, 5}]
      {_, {a, b}} ->
        [{a, b - v}]
    end
    |> Enum.map(&Position.from_pair(&1))
    |> only_if(board, :empty)
    |> only_if(board, {:direct_acces, pos})

    {a, b} = Position.to_indices(pos)

    y =
      [{a + v, b + 1}, {a + v, b - 1}]
      |> Enum.filter(fn({a, b}) -> a in 0..7 and b in 0..7 end)
      |> Enum.map(&Position.from_indices(&1))
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

  def valid_moves(%{board: board}, [suit, :king], pos) do
    {sa, sb} = pos |> Position.to_indices

    -1..1
    |> Enum.flat_map(fn(a) ->
      -1..1
      |> Enum.map(fn(b) ->
        if a == 0 and b == 0 do
          :skip
        else
          {sa + a, sb + b}
        end
      end)
      |> Enum.filter(&(&1 != :skip))
      |> Enum.map(&(Position.from_indices(&1)))
    end)
    |> only_if(board, {:not_suit, suit})
    |> only_if(board, {:direct_acces, pos})
  end

  def valid_moves(%{board: board}, [suit, :knight], pos) do
    {a, b} = Position.to_indices(pos)

    [
      {a + 1, b + 2}, {a + 1, b - 2}, {a - 1, b + 2}, {a - 1, b - 2},
      {a + 2, b + 1}, {a + 2, b - 1}, {a - 2, b + 1}, {a - 2, b - 1},
    ]
    |> Enum.filter(fn(pos) ->
      {a, b} = pos

      a in 0..7 and b in 0..7
    end)
    |> Enum.map(&Position.from_indices(&1))
    |> only_if(board, {:not_suit, suit})
  end

  def valid_moves(_, :empty, _), do: []

  def valid_move?(state, from, to) do
    to in valid_moves(state, piece_at(state, from), to)
  end
end
