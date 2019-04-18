defmodule IdpWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Idp.Repo

  input_object :update_user_params do
    field(:full_name, :string)
    field(:email, :string)
    field(:is_active, :boolean)
    field(:is_superuser, :boolean)
  end

  input_object :update_password_params do
    field(:old_password, :string)
    field(:new_password, :string)
    field(:new_password_repeat, :string)
  end

  @desc "User"
  object :user do
    field(:id, :id)
    field(:full_name, :string)
    field(:email, :string)
    field(:is_active, :boolean)
    field(:is_superuser, :boolean)
  end
end
