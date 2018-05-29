defmodule Mailstub.EmailControllerTest do
  use Mailstub.ConnCase

  alias Mailstub.Email
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, email_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    email = Repo.insert! %Email{}
    conn = get conn, email_path(conn, :show, email)
    assert json_response(conn, 200)["data"] == %{"id" => email.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, email_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, email_path(conn, :create), email: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Email, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, email_path(conn, :create), email: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    email = Repo.insert! %Email{}
    conn = put conn, email_path(conn, :update, email), email: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Email, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    email = Repo.insert! %Email{}
    conn = put conn, email_path(conn, :update, email), email: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    email = Repo.insert! %Email{}
    conn = delete conn, email_path(conn, :delete, email)
    assert response(conn, 204)
    refute Repo.get(Email, email.id)
  end
end
