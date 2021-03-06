defmodule Idp.Users do
  @moduledoc """
  The Users context.
  """
  use Idp.Query
  alias Idp.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Get a single user by email

  ## Examples

      iex> get_by_email("email@example.com")
      %User{}

      iex> get_by_email("email@unknown.com")
      nil
  """
  def get_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  @doc """
  Register a new user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates password for user.

  ## Examples

      iex> change_password(user, %{password: "***", ...})
      {:ok, %User{}}

      iex> change_password(user, %{password: "***", ...})
      {:error, %Ecto.Changeset{}}

  """
  def change_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates password for user without knowing its password
  only admins should be using this action.

  ## Examples

      iex> force_change_password(user, %{new_password: "***", ...})
      {:ok, %User{}}

      iex> force_change_password(user, %{new_password: "***", ...})
      {:error, %Ecto.Changeset{}}

  """
  def force_change_password(%User{} = user, attrs) do
    user
    |> User.force_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
