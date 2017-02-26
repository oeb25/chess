defmodule Chess.GameUserControllerTest do
  use Chess.ConnCase

  alias Chess.GameUser
  @valid_attrs %{}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, game_user_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing games users"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, game_user_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New game user"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, game_user_path(conn, :create), game_user: @valid_attrs
  #   assert redirected_to(conn) == game_user_path(conn, :index)
  #   assert Repo.get_by(GameUser, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, game_user_path(conn, :create), game_user: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New game user"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   game_user = Repo.insert! %GameUser{}
  #   conn = get conn, game_user_path(conn, :show, game_user)
  #   assert html_response(conn, 200) =~ "Show game user"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, game_user_path(conn, :show, -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   game_user = Repo.insert! %GameUser{}
  #   conn = get conn, game_user_path(conn, :edit, game_user)
  #   assert html_response(conn, 200) =~ "Edit game user"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   game_user = Repo.insert! %GameUser{}
  #   conn = put conn, game_user_path(conn, :update, game_user), game_user: @valid_attrs
  #   assert redirected_to(conn) == game_user_path(conn, :show, game_user)
  #   assert Repo.get_by(GameUser, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   game_user = Repo.insert! %GameUser{}
  #   conn = put conn, game_user_path(conn, :update, game_user), game_user: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit game user"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   game_user = Repo.insert! %GameUser{}
  #   conn = delete conn, game_user_path(conn, :delete, game_user)
  #   assert redirected_to(conn) == game_user_path(conn, :index)
  #   refute Repo.get(GameUser, game_user.id)
  # end
end
