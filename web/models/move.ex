defmodule Chess.Move.Position do
  @behaviour Ecto.Type
  def type, do: :integer

  @legal_positions 0..16

  def legal_position?(pos) do
    pos in @legal_positions
  end

  def to_indices(pos) when is_atom(pos), do: Atom.to_string(pos) |> to_indices
  def to_indices(pos) when is_binary(pos), do: String.split(pos, "") |> Enum.take(2) |> to_indices
  def to_indices([r, c] = pos) when is_list(pos) and is_binary(r) and is_binary(c) do
    [
      8 - String.to_integer(c, 16),
      String.to_integer(r, 32) - 10,
    ]
  end

  def to_nice_string([r, c]) do
    c = case c do
      0 -> :A
      1 -> :B
      2 -> :C
      3 -> :D
      4 -> :E
      5 -> :F
      6 -> :G
      7 -> :H
    end

    r = case r do
      7 -> 1
      6 -> 2
      5 -> 3
      4 -> 4
      3 -> 5
      2 -> 6
      1 -> 7
      0 -> 8
    end

    "#{c}#{r}"
  end
  def to_atom([r, c] = a) when is_integer(r) and is_integer(c), do: to_nice_string(a) |> String.to_atom
  def to_atom(a) when is_list(a), do: for x <- a, do: to_atom(x)

  @spec cast(any) :: {:ok, integer} | :error
  def cast(atom) when is_atom(atom) do
    Atom.to_string(atom) |> String.upcase |> cast
  end
  def cast(string) when is_binary(string), do: string |> to_indices |> cast
  def cast([c, r] = pos) when is_list(pos) and c in 0..7 and r in 0..7 do
      use Bitwise
      {:ok, c + (r <<< 3)}
  end
  def cast(_), do: :error

  def cast!(a) do
    case cast(a) do
      {:ok, h} -> h
      :error   -> raise "Could not cast position"
    end
  end

  def load(pos) when is_integer(pos) do
    use Bitwise
    {:ok, [pos &&& 7, pos >>> 3]}
  end
  def load!(pos) do
    case load(pos) do
      {:ok, h} -> h
      :error   -> raise "Invalid Position"
    end
  end

  def dump(pos) when is_integer(pos), do: {:ok, pos}
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
