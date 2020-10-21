defmodule ProjectDrive.Guardian do
  @moduledoc """
  Provides methods to store and retried user information to and from a JWT
  """

  use Guardian, otp_app: :project_drive

  alias ProjectDrive.Identity

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)

    {:ok, sub}
  end

  def resource_from_claims(claims) do
    user = claims["sub"] |> Identity.get_user!()

    {:ok, user}
  end
end
