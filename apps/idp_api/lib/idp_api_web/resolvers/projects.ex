defmodule IdpApiWeb.Resolvers.Projects do
  alias Core.Project
  alias Core.ProjectActions

  def list(_parent, _args, _resolution) do
    {:ok, Project |> Core.Repo.all}
  end

  def create_project(_parent, args, _resolution) do
    {:ok, ProjectActions.create(args)}
  end

  def update_project(_parent, args, _resolution) do
    ProjectActions.update(args)
  end

  def delete_project(_parent, args, _resolution) do
    ProjectActions.delete(args)
  end
end