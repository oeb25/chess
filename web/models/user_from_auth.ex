defmodule UserFromAuth do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Ueberauth.Auth
  alias Chess.User
  alias Chess.Repo

  def find_or_create(%Auth{provider: :identity} = auth) do
    case validate_pass(auth) do
      {:ok, user} ->
        {:ok, user}
      {:err, reason} -> {:err, reason}
    end
  end

  defp basic_info(auth) do
    %{id: auth.uid, name: name_from_auth(auth), avatar: auth.info.image}
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  defp validate_pass(%{credentials: %{other: %{password: ""}}}) do
    {:err, "Password required"}
  end
  defp validate_pass(%{credentials: %{other: %{password: pw}}, info: %{email: email}}) do
    case Repo.get_by(User, email: email) do
      user when user != nil ->
        if user.password == pw do
          {:ok, user}
        else
          {:err, "password dont match"}
        end
      {:err, err} ->
        {:err, err}
      _ ->
        {:err, "user not found"}
    end
  end
  # defp validate_pass(%{other: %{password: _}}) do
  #   {:err, "Passwords do not match"}
  # end
  # defp validate_pass(_), do: {:err, "Invalid request"}
end
