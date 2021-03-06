defmodule Margaret.CollectionStories.CollectionStory do
  @moduledoc """
  The Collection Story schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Stories.Story,
    Collections.Collection
  }

  @type t :: %CollectionStory{}

  schema "collection_stories" do
    belongs_to(:story, Story)
    belongs_to(:collection, Collection)

    # The order of the story in the collection.
    field(:part, :integer)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a collection story.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      story_id
      collection_id
      part
    )a

    required_attrs = ~w(
      story_id
      collection_id
      part
    )a

    %CollectionStory{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> validate_number(:part, greater_than_or_equal_to: 1)
    |> assoc_constraint(:story)
    |> assoc_constraint(:collection)
  end

  @doc """
  Builds a changeset for updating a collection story.
  """
  @spec update_changeset(CollectionStory.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%CollectionStory{} = collection_story, attrs) do
    permitted_attrs = ~w(
      part
    )a

    collection_story
    |> cast(attrs, permitted_attrs)
    |> validate_number(:part, greater_than_or_equal_to: 1)
  end
end
