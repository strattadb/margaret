defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Comments,
    Collections,
    Bookmarks,
    Helpers
  }

  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment
  alias Collections.Collection
  alias Bookmarks.Bookmark

  @type bookmarkable :: Collection.t() | Story.t() | Comment.t()

  @doc """
  Gets a bookmark.

  ## Examples

      iex> get_bookmark(user_id: 123, story_id: 123)
      %Bookmark{}

      iex> get_bookmark(user_id: 123, comment_id: 456)
      nil

  """
  @spec get_bookmark(Keyword.t()) :: Bookmark.t() | nil
  def get_bookmark(clauses) when length(clauses) == 2, do: Repo.get_by(Bookmark, clauses)

  @doc """
  Gets the user of a bookmark.

  ## Examples

      iex> user(%Bookmark{})
      %User{}

  """
  @spec user(Bookmark.t()) :: User.t()
  def user(%Bookmark{} = bookmark) do
    bookmark
    |> Bookmark.preload_user()
    |> Map.fetch!(:user)
  end

  @doc """
  Returns `true` if the user has bookmarked the bookmarkable.
  `false` otherwise.

  ## Examples

      iex> has_bookmarked?(user: %User{}, comment: %Comment{})
      true

      iex> has_bookmarked?(user: %User{}, collection: %Collection{})
      false

  """
  @spec has_bookmarked?(Keyword.t()) :: boolean()
  def has_bookmarked?(clauses) do
    %User{id: user_id} = Keyword.get(clauses, :user)

    clauses =
      clauses
      |> get_bookmarkable_from_clauses()
      |> case do
        %Collection{id: collection_id} -> [collection_id: collection_id]
        %Story{id: story_id} -> [story_id: story_id]
        %Comment{id: comment_id} -> [comment_id: comment_id]
      end
      |> Keyword.put(:user_id, user_id)

    !!get_bookmark(clauses)
  end

  @spec get_bookmarkable_from_clauses(Keyword.t()) :: bookmarkable()
  defp get_bookmarkable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :collection) -> Keyword.get(clauses, :collection)
      Keyword.has_key?(clauses, :story) -> Keyword.get(clauses, :story)
      Keyword.has_key?(clauses, :comment) -> Keyword.get(clauses, :comment)
    end
  end

  @doc """
  """
  @spec bookmarked(map()) :: any()
  def bookmarked(args) do
    args
    |> Bookmarks.Queries.bookmarked()
    |> Helpers.Connection.from_query(args)
  end

  @doc """
  """
  @spec bookmarked_count(map()) :: non_neg_integer()
  def bookmarked_count(args \\ %{}) do
    args
    |> Bookmarks.Queries.bookmarked()
    |> Repo.count()
  end

  @doc """
  Inserts a bookmark.
  """
  @spec insert_bookmark(map()) :: {:ok, Bookmark.t()} | {:error, any()}
  def insert_bookmark(attrs) do
    attrs
    |> Bookmark.changeset()
    |> Repo.insert()
  end

  @doc """
  Deletes a bookmark.
  """
  @spec delete_bookmark(Bookmark.t()) :: Bookmark.t()
  def delete_bookmark(%Bookmark{} = bookmark), do: Repo.delete(bookmark)
end
