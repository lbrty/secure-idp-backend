defmodule IdpWeb.Schema.UserMutations do
  use Absinthe.Schema.Notation
  alias IdpWeb.Schema.UserResolvers

  object :user_mutations do
    @desc "Update user"
    field :update_user, :user do
      arg(:user_id, non_null(:integer))
      arg(:fields, :update_user_params)

      middleware(IdpWeb.AuthRequired)
      middleware(IdpWeb.OnlyActiveUser)

      resolve(&UserResolvers.update/3)
    end

    @desc "Change password for user"
    field :change_password, :user do
      arg(:user_id, non_null(:integer))
      arg(:passwords, :update_password_params)

      middleware(IdpWeb.AuthRequired)
      middleware(IdpWeb.OnlyActiveUser)

      resolve(&UserResolvers.change_password/3)
    end

    @desc "Force change password for user (only for admin users)"
    field :force_change_password, :user do
      arg(:user_id, non_null(:integer))
      arg(:passwords, :force_update_password_params)

      middleware(IdpWeb.AuthRequired)
      middleware(IdpWeb.OnlyActiveUser)
      middleware(IdpWeb.OnlyAdmin)

      resolve(&UserResolvers.change_password/3)
    end

    @desc "Delete user"
    field :delete_user, :user do
      arg(:user_id, non_null(:integer))

      middleware(IdpWeb.AuthRequired)
      middleware(IdpWeb.OnlyActiveUser)
      middleware(IdpWeb.OnlyAdmin)

      resolve(&UserResolvers.delete/3)
    end
  end
end
