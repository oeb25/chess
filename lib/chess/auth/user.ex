defmodule Chess.Auth.User do
  use Ecto.Schema

  schema "auth_users" do
    field :name, :string
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true

    timestamps()
  end
end

defimpl Poison.Encoder, for: Chess.Auth.User do
  def encode(model, opts) do
    model
      |> Map.take([:name, :email])
      |> Poison.Encoder.encode(opts)
  end
end
