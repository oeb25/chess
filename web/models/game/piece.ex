defmodule Chess.Game.Piece do
  @behaviour Ecto.Type
  def type, do: :array

  @suits [:black, :white]
  @pieces [:rook, :knight, :bishop, :queen, :king, :pawn]

  def cast(%{suit: suit, piece: piece}), do: cast([suit, piece])
  def cast({suit, piece}), do: cast([suit, piece])
  def cast([suit, piece]) when suit in @suits and piece in @pieces do
    {:ok, [suit, piece]}
  end
  def cast(:empty) do
    {:ok, :empty}
  end
  def cast(_), do: :error

  def valid?(a) do
    case cast(a) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def load("empty"), do: {:ok, :empty}
  def load("black:" <> piece), do: load(["black", piece])
  def load("white:" <> piece), do: load(["white", piece])
  def load(%{suit: suit, piece: piece}), do: load([suit, piece])
  def load([suit, piece]) do
    suit = suit |> String.to_atom
    piece = piece |> String.to_atom

    if piece in @pieces and suit in @suits do
      {:ok, [suit, piece]}
    else
      :error
    end
  end
  def load(_)

  def dump(list) when is_list(list) do
    {:ok, list}
  end
  def dump(_), do: :error
end
