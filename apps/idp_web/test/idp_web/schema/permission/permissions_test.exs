defmodule IdpWeb.PermissionsSchemaTest do
  use IdpWeb.WebCase

  alias Idp.{Permissions, Users}
  alias IdpWeb.TestUtils

  @moduletag :permissions

  describe "🚨 permissions ::" do
    test "admins can see permissions across all projects", %{conn: conn} do
      query = %{
        query: """
        {
          permissions {
            project {
              name
            }

            user {
              email
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api", query)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "permissions" => [
            %{
              "project" => %{"name" => "Project X"},
              "user" => %{"email" => "user1@email.com"}
            },
            %{
              "project" => %{"name" => "Project X"},
              "user" => %{"email" => "user2@email.com"}
            },
            %{
              "project" => %{"name" => "Project X"},
              "user" => %{"email" => "user3@email.com"}
            },
            %{
              "project" => %{"name" => "Project X"},
              "user" => %{"email" => "user5@email.com"}
            }
          ]
        }
      }
    end

    test "admins can see permissions for any user", %{conn: conn} do
      user = Users.get_by_email("user1@email.com")
      mutation = %{
        query: """
        {
          permissions(user_id: #{user.id}) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "permissions" => [
            %{
              "user" => %{"email" => "user1@email.com"}
            }
          ]
        }
      }
    end

    test "admins can share project with user", %{conn: conn} do
      user = Users.get_by_email("user4@email.com")

      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      pid =
        admin_conn
        |> get_project()
        |> Map.get("id")

      mutation = %{
        query: """
        mutation {
          shareProject(
            project_id: #{pid},
            user_id: #{user.id},
            permission: {
              can_create: true,
              can_read: true,
              can_update: false,
              can_delete: false,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "shareProject" => %{
            "user" => %{"email" => "user4@email.com"}
          }
        }
      }
    end

    test "admins can delete permissions for user in project", %{conn: conn} do
      permission =
        "user1@email.com"
        |> Users.get_by_email()
        |> Permissions.list_for_user()
        |> hd()

      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      mutation = %{
        query: """
        mutation {
          deletePermission(permission_id: #{permission.id}) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "deletePermission" => %{
            "user" => %{"email" => "user1@email.com"}
          }
        }
      }
    end

    test "admins can not delete non existent permission", %{conn: conn} do
      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      mutation = %{
        query: """
        mutation {
          deletePermission(permission_id: 123) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"deletePermission" => nil},
        "errors" => [
          %{
            "code" => "not_found",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Not found",
            "path" => ["deletePermission"]
          }
        ]
      }
    end

    test "admins can update permissions for user in project", %{conn: conn} do
      permission =
        "user1@email.com"
        |> Users.get_by_email()
        |> Permissions.list_for_user()
        |> hd()

      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      mutation = %{
        query: """
        mutation {
          updatePermission(
            permission_id: #{permission.id},

            permission: {
              can_create: true,
              can_read: true,
              can_update: true,
              can_delete: true,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            can_create
            can_read
            can_update
            can_delete
            view_contacts
            view_documents
            view_personal

            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "updatePermission" => %{
            "can_create" => true,
            "can_read" => true,
            "can_update" => true,
            "can_delete" => true,
            "view_contacts" => false,
            "view_documents" => false,
            "view_personal" => false,
            "user" => %{"email" => "user1@email.com"}
          }
        }
      }
    end

    test "sharing project is impossible with user if does not exist", %{conn: conn} do
      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      pid =
        admin_conn
        |> get_project()
        |> Map.get("id")

      mutation = %{
        query: """
        mutation {
          shareProject(
            project_id: #{pid},
            user_id: 123,
            permission: {
              can_create: true,
              can_read: true,
              can_update: false,
              can_delete: false,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"shareProject" => nil},
        "errors" => [
          %{
            "code" => "user_not_found",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "User not found",
            "path" => ["shareProject"]
          }
        ]
      }
    end

    test "sharing project is impossible with project if does not exist", %{conn: conn} do
      user = Users.get_by_email("user4@email.com")

      mutation = %{
        query: """
        mutation {
          shareProject(
            project_id: 123,
            user_id: #{user.id},
            permission: {
              can_create: true,
              can_read: true,
              can_update: false,
              can_delete: false,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"shareProject" => nil},
        "errors" => [
          %{
            "code" => "not_found",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Project not found",
            "path" => ["shareProject"]
          }
        ]
      }
    end

    test "admins can not share project with other admins", %{conn: conn} do
      user = Users.get_by_email("admin2@email.com")

      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      pid =
        admin_conn
        |> get_project()
        |> Map.get("id")

      mutation = %{
        query: """
        mutation {
          shareProject(
            project_id: #{pid},
            user_id: #{user.id},
            permission: {
              can_create: true,
              can_read: true,
              can_update: false,
              can_delete: false,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        admin_conn
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"shareProject" => nil},
        "errors" => [
          %{
            "code" => "permission_exists",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Permission already exists",
            "path" => ["shareProject"]
          }
        ]
      }
    end

    test "users can leave shared projects", %{conn: conn} do
      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      project =
        admin_conn
        |> get_project()

      pid =
        project
        |> Map.get("id")

      name =
        project
        |> Map.get("name")

      mutation = %{
        query: """
        mutation {
          leaveProject(project_id: #{pid}) {
            name
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn()
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "leaveProject" => %{"name" => name}
        }
      }
    end

    test "users can not leave project if not exists", %{conn: conn} do
      mutation = %{
        query: """
        mutation {
          leaveProject(project_id: 123) {
            name
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn()
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"leaveProject" => nil},
        "errors" => [
          %{
            "code" => "not_found",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Project not found",
            "path" => ["leaveProject"]
          }
        ]
      }
    end

    test "users can not share project with other users", %{conn: conn} do
      user = Users.get_by_email("user4@email.com")

      admin_conn =
        conn
        |> TestUtils.get_authenticated_conn(Users.get_by_email("admin@email.com"))

      pid =
        admin_conn
        |> get_project()
        |> Map.get("id")

      mutation = %{
        query: """
        mutation {
          shareProject(
            project_id: #{pid},
            user_id: #{user.id},
            permission: {
              can_create: true,
              can_read: true,
              can_update: false,
              can_delete: false,
              view_contacts: false,
              view_documents: false,
              view_personal: false
            }
          ) {
            user {
              email
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn()
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"shareProject" => nil},
        "errors" => [
          %{
            "code" => "permission_denied",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Permission denied",
            "path" => ["shareProject"]
          }
        ]
      }
    end

    test "users can see only their own permissions", %{conn: conn} do
      mutation = %{
        query: """
        {
          permissions {
            project {
              name
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn()
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{
          "permissions" => [
            %{"project" => %{"name" => "Project X"}}
          ]
        }
      }
    end

    test "users can not see permissions for any other user", %{conn: conn} do
      user = Users.get_by_email("user2@email.com")
      mutation = %{
        query: """
        {
          permissions(user_id: #{user.id}) {
            project {
              name
            }
          }
        }
        """
      }

      result =
        conn
        |> TestUtils.get_authenticated_conn()
        |> post("/api", mutation)
        |> json_response(200)

      assert result == %{
        "data" => %{"permissions" => nil},
        "errors" => [
          %{
            "code" => "permission_denied",
            "locations" => [%{"column" => 0, "line" => 2}],
            "message" => "Permission denied",
            "path" => ["permissions"]
          }
        ]
      }
    end
  end

  defp get_project(conn) do
    query = %{
      query: """
      {
        projects {
          id
          name
        }
      }
      """
    }

    conn
    |> post("/api/graphql", query)
    |> json_response(200)
    |> Map.get("data")
    |> Map.get("projects")
    |> hd()
  end
end
