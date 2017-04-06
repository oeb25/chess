defmodule Chess.Games.Square do
  @behaviour Ecto.Type
  def type, do: :integer

  @squares [
    :A8, :B8, :C8, :D8, :E8, :F8, :G8, :H8,
    :A7, :B7, :C7, :D7, :E7, :F7, :G7, :H7,
    :A6, :B6, :C6, :D6, :E6, :F6, :G6, :H6,
    :A5, :B5, :C5, :D5, :E5, :F5, :G5, :H5,
    :A4, :B4, :C4, :D4, :E4, :F4, :G4, :H4,
    :A3, :B3, :C3, :D3, :E3, :F3, :G3, :H3,
    :A2, :B2, :C2, :D2, :E2, :F2, :G2, :H2,
    :A1, :B1, :C1, :D1, :E1, :F1, :G1, :H1,
  ]

  @type t :: :A8 | :B8 | :C8 | :D8 | :E8 | :F8 | :G8 | :H8 | :A7 | :B7 | :C7
           | :D7 | :E7 | :F7 | :G7 | :H7 | :A6 | :B6 | :C6 | :D6 | :E6 | :F6
           | :G6 | :H6 | :A5 | :B5 | :C5 | :D5 | :E5 | :F5 | :G5 | :H5 | :A4
           | :B4 | :C4 | :D4 | :E4 | :F4 | :G4 | :H4 | :A3 | :B3 | :C3 | :D3
           | :E3 | :F3 | :G3 | :H3 | :A2 | :B2 | :C2 | :D2 | :E2 | :F2 | :G2
           | :H2 | :A1 | :B1 | :C1 | :D1 | :E1 | :F1 | :G1 | :H1

  # Provide our own casting rules.
  @spec cast(t | String.t | integer | {integer, integer}) :: {:ok, t} | :error
  def cast(sq) when is_atom(sq) and sq in @squares do
    {:ok, sq}
  end
  def cast(sq) when is_binary(sq), do: sq |> String.to_atom |> cast
  def cast(sq) when is_integer(sq) and sq in 0..63, do: @squares |> Enum.at(sq) |> cast
  def cast([r, c]), do: {r, c} |> cast
  def cast({r, c}) when is_float(r) or is_float(c),
    do: {r |> round, c |> round} |> cast
  def cast({r, c})
    when is_integer(r) and is_integer(c) and r in 0..7 and c in 0..7,
    do: cast(c + r * 8)

  # Everything else is a failure though
  def cast(_), do: :error

  @spec cast!(t | String.t | integer | {integer, integer}) :: t
  def cast!(a) do
    sq = cast(a)
    case sq do
      {:ok, sq} -> sq
      _ ->
        raise "Could not cast square"
    end
  end

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  @spec load(String.t) :: {:ok, t} | :error
  def load(sq) do
    sq |> cast
  end

  @spec to_index(t) :: integer
  def to_index(sq) when sq in @squares do
    Enum.find_index(@squares, &(&1 == sq))
  end
  @spec to_indicies(t) :: {integer, integer}
  def to_indicies(sq) when sq in @squares do
    i = to_index(sq)

    {Integer.floor_div(i, 8), Integer.mod(i, 8)}
  end

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  @spec dump(t) :: {:ok, integer} | :error
  def dump(sq) when sq in @squares do
    {:ok, to_index(sq)}
  end
  def dump(_), do: :error
end
