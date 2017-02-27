defmodule Chess.MoveTest do
  use Chess.ModelCase

  alias Chess.Move

  @valid_attrs %{from: %{}, to: %{}}
  @invalid_attrs %{}

  # test "changeset with valid attributes" do
  #   changeset = Move.changeset(%Move{}, @valid_attrs)
  #   assert changeset.valid?
  # end

  # test "changeset with invalid attributes" do
  #   changeset = Move.changeset(%Move{}, @invalid_attrs)
  #   refute changeset.valid?
  # end

  test "to_indices" do
    assert Move.Position.to_indices(:A5) == [3, 0]
    assert Move.Position.to_indices(:H8) == [0, 7]
  end

  test "x |> cast |> load == x" do
    import Move.Position
    assert :A5 |> cast! == 3
    assert :A5 |> cast! |> load! == [3, 0] 
    assert :H1 |> cast! |> load! == [7, 7] 
  end
end
