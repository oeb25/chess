defmodule Chess.Games.Action.Move do
  defstruct [:from, :to]

  alias Chess.Games.Square

  @type t :: %__MODULE__{from: Square.t, to: Square.t}
end

defmodule Chess.Games.Action do
  @behaviour Ecto.Type
  def type, do: :map

  alias Chess.Games.Square
  alias Chess.Games.Action.Move

  @type t :: Move.t

  # Provide our own casting rules.
  @spec cast(t | %{type: String.t}) :: {:ok, t} | :error
  def cast(%Move{from: from, to: to}) do
    with {:ok, from} <- from |> Square.cast,
         {:ok, to} <- to |> Square.cast,
         do: {:ok, %Move{from: from, to: to}}
  end
  def cast(%{type: "move", from: from, to: to}), do: cast(%{type: :move, from: from, to: to})
  def cast(%{type: :move, from: from, to: to}) do
    %Move{from: from, to: to} |> cast
  end

  # Everything else is a failure though
  def cast(_), do: :error

  def cast!(a) do
    sq = cast(a)
    case sq do
      {:ok, sq} -> sq
      _ ->
        raise "Could not cast action"
    end
  end

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  @spec load(String.t) :: {:ok, t} | :error
  def load(sq) do
    with {:ok, s} <- sq |> Poison.decode do
      case s do
        %{"type" => "move", "from" => from, "to" => to} ->
          {:ok, %Move{from: from |> Square.cast!, to: to |> Square.cast!}}
        _ -> :error
      end
    end
  end

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  @spec dump(t) :: {:ok, String.t} | :error
  def dump(%Move{} = ac) do
    with {:ok, %{from: from, to: to}} <- ac |> cast,
         {:ok, from} <- from |> Square.dump,
         {:ok, to} <- to |> Square.dump,
         do: %{type: "move", from: from , to: to} |> Poison.encode
  end
  def dump(_), do: :error
end
