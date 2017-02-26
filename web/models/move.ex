defmodule Chess.Move.Position do
  @behaviour Ecto.Type
  def type, do: :string

  @legal_positions [
    :a8, :b8, :c8, :d8, :e8, :f8, :g8, :h8,
    :a7, :b7, :c7, :d7, :e7, :f7, :g7, :h7,
    :a6, :b6, :c6, :d6, :e6, :f6, :g6, :h6,
    :a5, :b5, :c5, :d5, :e5, :f5, :g5, :h5,
    :a4, :b4, :c4, :d4, :e4, :f4, :g4, :h4,
    :a3, :b3, :c3, :d3, :e3, :f3, :g3, :h3,
    :a2, :b2, :c2, :d2, :e2, :f2, :g2, :h2,
    :a1, :b1, :c1, :d1, :e1, :f1, :g1, :h1,

    :A8, :B8, :C8, :D8, :E8, :F8, :G8, :H8,
    :A7, :B7, :C7, :D7, :E7, :F7, :G7, :H7,
    :A6, :B6, :C6, :D6, :E6, :F6, :G6, :H6,
    :A5, :B5, :C5, :D5, :E5, :F5, :G5, :H5,
    :A4, :B4, :C4, :D4, :E4, :F4, :G4, :H4,
    :A3, :B3, :C3, :D3, :E3, :F3, :G3, :H3,
    :A2, :B2, :C2, :D2, :E2, :F2, :G2, :H2,
    :A1, :B1, :C1, :D1, :E1, :F1, :G1, :H1,
  ]

  def legal_position?(pos) do
    pos in @legal_positions
  end

  def to_indices(pos) when is_binary(pos), do: pos |> load! |> to_indices
  def to_indices(pos) when pos in @legal_positions do
    pos = pos |> cast!

    col = case pos |> String.first do
      "A" -> 0
      "B" -> 1
      "C" -> 2
      "D" -> 3
      "E" -> 4
      "F" -> 5
      "G" -> 6
      "H" -> 7
    end

    row = case pos |> String.last do
      "1" -> 7
      "2" -> 6
      "3" -> 5
      "4" -> 4
      "5" -> 3
      "6" -> 2
      "7" -> 1
      "8" -> 0
    end

    {row, col}
  end

  def from_indices({row, col}) do
    col = case col do
      0 -> :A
      1 -> :B
      2 -> :C
      3 -> :D
      4 -> :E
      5 -> :F
      6 -> :G
      7 -> :H
    end

    row = case row do
      7 -> 1
      6 -> 2
      5 -> 3
      4 -> 4
      3 -> 5
      2 -> 6
      1 -> 7
      0 -> 8
    end

    from_pair({col, row})
  end

  def to_pair(pos) when is_binary(pos), do: pos |> load! |> to_pair
  def to_pair(pos) when pos in @legal_positions do
    pos = pos |> cast!

    col = case pos |> String.first do
      "A" -> :A
      "B" -> :B
      "C" -> :C
      "D" -> :D
      "E" -> :E
      "F" -> :F
      "G" -> :G
      "H" -> :H
    end

    row = case pos |> String.last do
      "1" -> 1
      "2" -> 2
      "3" -> 3
      "4" -> 4
      "5" -> 5
      "6" -> 6
      "7" -> 7
      "8" -> 8
    end

    {col, row}
  end

  def from_pair({col, row}) do
    col = case col do
      :A -> "A"
      :B -> "B"
      :C -> "C"
      :D -> "D"
      :E -> "E"
      :F -> "F"
      :G -> "G"
      :H -> "H"
    end

    row = case row do
      1 -> "1"
      2 -> "2"
      3 -> "3"
      4 -> "4"
      5 -> "5"
      6 -> "6"
      7 -> "7"
      8 -> "8"
    end

    String.to_atom("#{col}#{row}")
  end

  @spec cast(any) :: {:ok, String.t} | :error
  def cast(atom) when is_atom(atom) and atom in @legal_positions do
    {:ok, Atom.to_string(atom) |> String.upcase}
  end
  def cast(string) when is_binary(string) do
    string
    |> String.upcase
    |> cast
  end
  def cast(_), do: :error

  def cast!(a), do: elem(cast(a), 1)

  def load(string) when is_binary(string) do
    atom =
      string
      |> String.upcase
      |> String.to_atom

    if legal_position?(atom) do
      {:ok, atom}
    else
      :error
    end
  end
  def load!(string) do
    case load(string) do
      {:ok, h} -> h
      :error   -> raise "Invalid Position"
    end
  end

  def dump(string) when is_binary(string), do: {:ok, string}
  def dump(_), do: :error
end

defmodule Chess.Move do
  use Chess.Web, :model

  schema "moves" do
    field :from, Chess.Move.Position
    field :to, Chess.Move.Position
    belongs_to :user, Chess.User, type: :binary_id
    belongs_to :game, Chess.Game

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:from, :to, :user_id])
    |> validate_required([:from, :to])
  end
end
