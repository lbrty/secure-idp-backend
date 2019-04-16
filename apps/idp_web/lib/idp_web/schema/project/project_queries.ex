defmodule IdpWeb.Schema.ProjectQueries do
  use Absinthe.Schema.Notation
  alias IdpWeb.Schema.ProjectResolvers

  object :project_queries do
    @desc "Get all projects"
    field :projects, list_of(:project) do
      resolve(&ProjectResolvers.list/3)
    end
  end
end
