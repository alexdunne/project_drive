defmodule ProjectDrive.Accounts.Student do
  @moduledoc """
  Represents a Student
  """

  use ProjectDrive.Schema
  import Ecto.{Changeset, Query}

  alias ProjectDrive.{Accounts, Identity}

  schema "students" do
    field :email, :string
    field :name, :string

    # Holds the current state of invite process
    field :email_confirmation_state, :string, default: "awaiting_confirmation"

    belongs_to :user, Identity.User
    belongs_to :instructor, Accounts.Instructor

    timestamps()
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:email, :name, :email_confirmation_state])
    |> validate_required([:email, :name])
  end

  def filter_by_instructor(query \\ __MODULE__, %Accounts.Instructor{} = instructor) do
    from s in query, where: s.instructor_id == ^instructor.id
  end

  def order_students_asc(query) do
    from s in query, order_by: [asc: :name]
  end

  def filter(query, filters) do
    defaults = %{search_term: ""}
    filters = Map.merge(defaults, filters)

    search_term = String.downcase(filters[:search_term])

    query
    |> where(^filter_by_search_term(search_term))
  end

  defp filter_by_search_term(student_name) do
    value = String.trim(student_name)

    if String.length(value) > 0 do
      dynamic([s], ilike(s.name, ^"#{value}%"))
    else
      true
    end
  end
end
