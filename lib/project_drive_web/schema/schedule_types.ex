defmodule ProjectDriveWeb.Schema.ScheduleTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias ProjectDriveWeb.{Resolvers}

  enum :event_type do
    value(:lesson, description: "Lesson event type")
  end

  input_object :create_lesson_input do
    field :starts_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :notes, :string
    field :student_id, non_null(:id)
  end

  input_object :update_lesson_input do
    field :id, non_null(:id)
    field :starts_at, :datetime
    field :ends_at, :datetime
    field :notes, :string
  end

  input_object :reschedule_lesson_input do
    field :id, non_null(:id)
    field :starts_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
  end

  input_object :delete_lesson_input do
    field :id, non_null(:id)
  end

  object :event do
    field :id, non_null(:id)
    field :starts_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :type, non_null(:event_type)
    field :notes, :string

    field :student, non_null(:student) do
      resolve(&Resolvers.Schedule.get_student/3)
    end
  end

  object :create_lesson_payload do
    field :lesson, :event
  end

  object :update_lesson_payload do
    field :lesson, :event
  end

  object :reschedule_lesson_payload do
    field :lesson, :event
  end

  object :delete_lesson_payload do
    field :id, non_null(:id)
  end

  object :schedule_mutations do
    field :create_lesson, :create_lesson_payload do
      arg(:input, non_null(:create_lesson_input))

      resolve(&Resolvers.Schedule.create_lesson/3)
    end

    field :update_lesson, :update_lesson_payload do
      arg(:input, non_null(:update_lesson_input))

      resolve(&Resolvers.Schedule.update_lesson/3)
    end

    field :reschedule_lesson, :reschedule_lesson_payload do
      arg(:input, non_null(:reschedule_lesson_input))

      resolve(&Resolvers.Schedule.reschedule_lesson/3)
    end

    field :delete_lesson, :delete_lesson_payload do
      arg(:input, non_null(:delete_lesson_input))

      resolve(&Resolvers.Schedule.delete_lesson/3)
    end
  end
end
