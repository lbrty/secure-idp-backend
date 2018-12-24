defmodule Core.StatusActions do
  alias Core.Repo
  alias Core.IdpStatus

  def create(params) do
    params
    |> IdpStatus.changeset
    |> Repo.insert!
  end

  def update(%{id: id, status: params}) do
    IdpStatus
    |> Repo.get!(id)
    |> IdpStatus.changeset(params)
    |> Repo.update
  end

  def delete(%{id: id}) do
    IdpStatus
    |> Repo.get!(id)
    |> Repo.delete
  end
end