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

  test "to_pair" do
    assert Move.Position.to_pair(:A5) == {:A, 5}
    assert Move.Position.to_pair(:H8) == {:H, 8}
  end

  test "to_indices" do
    assert Move.Position.to_indices(:A5) == {3, 0}
    assert Move.Position.to_indices(:H8) == {0, 7}
  end
end
