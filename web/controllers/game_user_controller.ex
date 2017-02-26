defmodule Chess.GameUserController do
  use Chess.Web, :controller

  alias Chess.GameUser

  def index(conn, _params) do
    games_users = Repo.all(GameUser)
    render(conn, "index.html", games_users: games_users)
  end

  def new(conn, _params) do
    changeset = GameUser.changeset(%GameUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game_user" => game_user_params}) do
    changeset = GameUser.changeset(%GameUser{}, game_user_params)

    case Repo.insert(changeset) do
      {:ok, _game_user} ->
        conn
        |> put_flash(:info, "Game user created successfully.")
        |> redirect(to: game_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    game_user = Repo.get!(GameUser, id)
    render(conn, "show.html", game_user: game_user)
  end

  def edit(conn, %{"id" => id}) do
    game_user = Repo.get!(GameUser, id)
    changeset = GameUser.changeset(game_user)
    render(conn, "edit.html", game_user: game_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game_user" => game_user_params}) do
    game_user = Repo.get!(GameUser, id)
    changeset = GameUser.changeset(game_user, game_user_params)

    case Repo.update(changeset) do
      {:ok, game_user} ->
        conn
        |> put_flash(:info, "Game user updated successfully.")
        |> redirect(to: game_user_path(conn, :show, game_user))
      {:error, changeset} ->
        render(conn, "edit.html", game_user: game_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    game_user = Repo.get!(GameUser, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(game_user)

    conn
    |> put_flash(:info, "Game user deleted successfully.")
    |> redirect(to: game_user_path(conn, :index))
  end
end
