defmodule Chess.Games.RuleSet do
  # @enforce_keys [:kind, :time_limit]
  defstruct [:type, :time_limit]

  @behaviour Ecto.Type
  def type, do: :json

  @types [:standard]
  @type t :: %__MODULE__{type: :standard, time_limit: integer | :infinite}

  # Provide our own casting rules.
  # def cast(%{"type" => type, "time_limit" => time_limit}), do: %{type: t, time_limit: time_limit}

  # We should still accept integers
  @spec cast(t | %{type: String.t, time_limit: String.t | integer}) :: {:ok, t} | :error
  def cast(%__MODULE__{type: t} = rs)
    when is_binary(t)
  do
    %{rs | type: String.to_atom(t)} |> cast
  end

  def cast(%__MODULE__{time_limit: "infinite"} = rs) do
    %{rs | time_limit: :infinite} |> cast
  end

  def cast(%__MODULE__{type: t, time_limit: time_limit} = rs)
    when t in @types and (is_integer(time_limit) or time_limit == :infinite)
  do
    {:ok, rs}
  end

  def cast(%{"type" => t, "time_limit" => time_limit}) do
    %__MODULE__{type: t, time_limit: time_limit} |> cast
  end
  def cast(%{type: t, time_limit: time_limit}) do
    %__MODULE__{type: t, time_limit: time_limit} |> cast
  end

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  def load(rs) do
    rs |> Poison.decode! |> cast
  end

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  def dump(%__MODULE__{type: t, time_limit: time_limit}) do
    Poison.encode(%{
      "type" => Atom.to_string(t),
      "time_limit" => case time_limit do
        :infinite -> Atom.to_string(time_limit)
        _ when is_integer(time_limit) -> time_limit
      end
    })
  end
  def dump(_), do: :error
end
