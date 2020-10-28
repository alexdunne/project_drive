defmodule ProjectDriveWeb.Schema.ScheduleTypes do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ProjectDriveWeb.Middleware.{EnsureAuthenticated}
  alias ProjectDriveWeb.{Resolvers}

  enum :event_type do
    value(:lesson, description: "Lesson event type")
  end

  node object(:event) do
    field :starts_at, non_null(:datetime)
    field :ends_at, non_null(:datetime)
    field :type, non_null(:event_type)
    field :notes, :string

    field :student, non_null(:student) do
      resolve(&Resolvers.Account.get_student/3)
    end
  end

  connection(node_type: :event)

  object :schedule_queries do
    connection field :events, node_type: :event do
      arg(:search_term, :string)

      middleware(EnsureAuthenticated)

      resolve(&Resolvers.Schedule.list_events/3)
    end
  end

  object :schedule_mutations do
    payload field :create_lesson do
      middleware(EnsureAuthenticated)

      input do
        field :starts_at, non_null(:datetime)
        field :ends_at, non_null(:datetime)
        field :notes, :string
        field :student_id, non_null(:id)
      end

      output do
        field :lesson, :event
      end

      resolve(&Resolvers.Schedule.create_lesson/3)
    end

    payload field :update_lesson do
      middleware(EnsureAuthenticated)

      input do
        field :id, non_null(:id)
        field :starts_at, :datetime
        field :ends_at, :datetime
        field :notes, :string
      end

      output do
        field :lesson, :event
      end

      resolve(&Resolvers.Schedule.update_lesson/3)
    end

    payload field :reschedule_lesson do
      middleware(EnsureAuthenticated)

      input do
        field :id, non_null(:id)
        field :starts_at, non_null(:datetime)
        field :ends_at, non_null(:datetime)
      end

      output do
        field :lesson, :event
      end

      resolve(&Resolvers.Schedule.reschedule_lesson/3)
    end

    payload field :delete_lesson do
      middleware(EnsureAuthenticated)

      input do
        field :id, non_null(:id)
      end

      output do
        field :id, non_null(:id)
      end

      resolve(&Resolvers.Schedule.delete_lesson/3)
    end
  end
end
