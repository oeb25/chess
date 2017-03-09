defmodule Chess.Games.Participant do
  # @enforce_keys [:kind, :time_limit]
  defstruct [:type, :user_id]

  @behaviour Ecto.Type
  def type, do: :json

  @types [:anonymus, :user]
  @type t :: %__MODULE__{type: :anonymus | :user, user_id: String.t}

  # Provide our own casting rules.

  # We should still accept integers
  @spec cast(t | %{type: String.t, user_id: String.t}) :: {:ok, t} | :error
  def cast(%__MODULE__{type: t} = rs)
    when is_binary(t)
  do
    %{rs | type: String.to_atom(t)} |> cast
  end

  def cast(%__MODULE__{type: t, user_id: user_id})
    when t in @types and is_binary(user_id)
  do
    {:ok, %__MODULE__{type: t, user_id: user_id}}
  end

  def cast(%{"type" => t, "user_id" => user_id}), do: %{type: t, user_id: user_id} |> cast
  def cast(%{type: t, user_id: user_id}) do
    %__MODULE__{type: t, user_id: user_id} |> cast
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
  def dump(%__MODULE__{type: t, user_id: user_id})
    when t in @types and is_binary(user_id)
  do
    Poison.encode(%{
      "type" => Atom.to_string(t),
      "user_id" => user_id
    })
  end
  def dump(_), do: :error
end
