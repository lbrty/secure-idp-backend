defmodule Idp.Users.User do
  use Idp.Model
  alias __MODULE__
  alias Idp.Validators

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    field :is_active, :boolean, default: false
    field :is_superuser, :boolean, default: false

    # Used to change password
    field :new_password, :string, virtual: true
    field :new_password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def build(params) do
    %User{}
    |> changeset(params)
  end

  @doc false
  def changeset(user, attrs) do
    fields = ~w(email full_name is_active is_superuser)a

    user
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_format(:email, ~r/.*@.*/)
    |> unique_constraint(:email)
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, ~w(password password_hash)a)
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> put_password_hash()
  end

  @doc false
  def update_changeset(user, attrs), do: changeset(user, attrs)

  @doc false
  def password_changeset(user, attrs) do
    fields = ~w(password password_hash new_password new_password_confirmation)a

    changes =
      user
      |> changeset(attrs)
      |> cast(attrs, fields)
      |> validate_required(fields)
      |> Validators.check_password()
      |> Validators.validate_password_confirmation()
      |> validate_length(:password, min: 8)

    case changes.valid? do
      true ->
        changes
        |> put_change(:password, changes.changes[:new_password])
        |> put_password_hash()

      _ -> changes
    end
  end

  defp put_password_hash(%{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:password_hash, Auth.hash_password(password))
  end

  defp put_password_hash(%{changes: %{}} = changeset), do: changeset
end
