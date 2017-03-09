defmodule Chess.Web.GameControllerTest do
  use Chess.Web.ConnCase

  alias Chess.Games
  # alias Chess.Games.Game

  @create_attrs %{actions: [], black: %{}, rule_set: %{}, white: %{}}
  # @update_attrs %{actions: [], black: %{}, rule_set: %{}, white: %{}}
  # @invalid_attrs %{actions: nil, black: nil, rule_set: nil, white: nil}

  def fixture(:game) do
    {:ok, game} = Games.create_game(@create_attrs)
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, game_path(conn, :index)
  #   assert json_response(conn, 200)["data"] == []
  # end

  # test "creates game and renders game when data is valid", %{conn: conn} do
  #   conn = post conn, game_path(conn, :create), game: @create_attrs
  #   assert %{"id" => id} = json_response(conn, 201)["data"]

  #   conn = get conn, game_path(conn, :show, id)
  #   assert json_response(conn, 200)["data"] == %{
  #     "id" => id,
  #     "actions" => [],
  #     "black" => %{},
  #     "rule_set" => %{},
  #     "white" => %{}}
  # end

  # test "does not create game and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, game_path(conn, :create), game: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "updates chosen game and renders game when data is valid", %{conn: conn} do
  #   %Game{id: id} = game = fixture(:game)
  #   conn = put conn, game_path(conn, :update, game), game: @update_attrs
  #   assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #   conn = get conn, game_path(conn, :show, id)
  #   assert json_response(conn, 200)["data"] == %{
  #     "id" => id,
  #     "actions" => [],
  #     "black" => %{},
  #     "rule_set" => %{},
  #     "white" => %{}}
  # end

  # test "does not update chosen game and renders errors when data is invalid", %{conn: conn} do
  #   game = fixture(:game)
  #   conn = put conn, game_path(conn, :update, game), game: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end

  # test "deletes chosen game", %{conn: conn} do
  #   game = fixture(:game)
  #   conn = delete conn, game_path(conn, :delete, game)
  #   assert response(conn, 204)
  #   assert_error_sent 404, fn ->
  #     get conn, game_path(conn, :show, game)
  #   end
  # end
end
