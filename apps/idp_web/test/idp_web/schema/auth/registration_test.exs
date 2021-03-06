defmodule IdpWeb.RegistrationSchemaTest do
  use IdpWeb.WebCase

  alias Idp.Users
  alias IdpWeb.TestUtils

  @moduletag :registration

  describe "🎭 registration ::" do
    test "admins can register new users", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          register(email: "newuser@email.com", password: "12345678", full_name: "Bla bla") {
            result
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api/graphql", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "register" => %{"result" => "ok"}
        }
      }
    end

    test "regular users can not register a new user", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          register(email: "newuser@email.com", password: "12345678", full_name: "Bla bla") {
            result
          }
        }
        """
      }

      result =
        conn
        |> post("/api/graphql", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"register" => nil},
        "errors" => [
          %{
            "code" => "permission_denied",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Permission denied",
            "path" => ["register"]
          }
        ]
      }
    end

    test "can not register user if input is invalid", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          register(email: "", password: "123", full_name: "Bla bla") {
            result
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api/graphql", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"register" => nil},
        "errors" => [
          %{
            "code" => "schema_errors",
            "errors" => %{
              "email" => "can't be blank",
              "password" => "should be at least 8 character(s)"
            },
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Changeset errors occurred",
            "path" => ["register"]
          }
        ]
      }
    end

    test "can not register user if password is too short", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          register(email: "too@short.pass", password: "123", full_name: "Bla bla") {
            result
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api/graphql", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"register" => nil},
        "errors" => [
          %{
            "code" => "schema_errors",
            "errors" => %{
              "password" => "should be at least 8 character(s)"
            },
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Changeset errors occurred",
            "path" => ["register"]
          }
        ]
      }
    end

    test "can not register user if the one with same email already exists", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          register(email: "inactive@email.com", password: "12345678", full_name: "Bla bla") {
            result
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api/graphql", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"register" => nil},
        "errors" => [
          %{
            "code" => "user_already_exists",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "User already exists",
            "path" => ["register"]
          }
        ]
      }
    end
  end
end
