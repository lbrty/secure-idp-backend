defmodule Idp.Geo.State do
  use Idp.Model

  schema "states" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:title])
    |> validate_length(:title, min: 3, max: 40)
    |> validate_required([:title])
  end
end