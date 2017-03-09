defmodule Chess.AuthTest do
  use Chess.DataCase

  alias Chess.Auth
  alias Chess.Auth.User

  import Comeonin.Bcrypt

  @create_attrs %{email: "some email", password: "some password", name: "some name"}
  @update_attrs %{email: "some updated email", password: "some updated password", name: "some updated name"}
  @invalid_attrs %{email: nil, password: nil, name: nil}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Auth.create_user(attrs)
    user
  end

  defp remove_pw(user), do: Map.put(user, :password, nil)

  test "list_users/1 returns all users" do
    user = fixture(:user)
    assert Auth.list_users() == [user |> remove_pw]
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert Auth.get_user!(user.id) == user |> remove_pw
  end

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Auth.create_user(@create_attrs)

    assert user.email == "some email"
    assert checkpw("some password", user.hashed_password)
    assert user.name == "some name"
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Auth.update_user(user, @update_attrs)
    assert %User{} = user

    assert user.email == "some updated email"
    assert checkpw("some updated password", user.hashed_password)
    assert user.name == "some updated name"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
    assert user |> remove_pw == Auth.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Auth.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = Auth.change_user(user)
  end
end
