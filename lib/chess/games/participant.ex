defmodule Chess.Games.Participant.LoggedIn do
  defstruct [:user_id]
  @type t :: %__MODULE__{user_id: String.t}
end

defmodule Chess.Games.Participant.Anonymus do
  defstruct [:token]
  @type t :: %__MODULE__{token: String.t}
end

defmodule Chess.Games.Participant do
  @behaviour Ecto.Type
  def type, do: :json

  alias Chess.Games.Participant.{Anonymus, LoggedIn}

  @types [:anonymus, :logged_in]
  @type t :: LoggedIn.t | Anonymus.t

  # Provide our own casting rules.

  # We should still accept integers
  @spec cast(t | %{type: String.t}) :: {:ok, t} | :error
  def cast(%{type: :logged_in, user_id: user_id})
    when is_binary(user_id)
  do
    {:ok, %LoggedIn{user_id: user_id}}
  end

  def cast(%{type: :anonymus, token: token})
    when is_binary(token)
  do
    {:ok, %Anonymus{token: token}}
  end

  def cast(%{"type" => _} = ac) do
    cast for {key, val} <- ac,
      into: %{},
      do: {
        String.to_atom(key),
        if key == "type" do String.to_atom(val) else val end
      }
  end

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the schema struct.
  @spec load(String.t) :: {:ok, t} | :error
  def load(rs) do
    rs |> Poison.decode! |> cast
  end

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  @spec dump(t) :: {:ok, String.t} | :error
  def dump(%LoggedIn{user_id: user_id}) do
    Poison.encode(%{
      "type" => "logged_in",
      "user_id" => user_id
    })
  end
  def dump(%Anonymus{token: token}) do
    Poison.encode(%{
      "type" => "anonymus",
      "token" => token
    })
  end
  def dump(_), do: :error
end
