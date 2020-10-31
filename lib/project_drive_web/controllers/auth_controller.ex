defmodule ProjectDriveWeb.AuthController do
  use ProjectDriveWeb, :controller
  use Params

  alias ProjectDrive.{Accounts, Guardian, Identity}

  action_fallback ProjectDriveWeb.FallbackController

  defparams(
    register_params(%{
      email!: :string,
      password!: :string,
      name!: :string
    })
  )

  def register(conn, params) do
    changeset = register_params(params)

    if changeset.valid? do
      user_details = Params.to_map(changeset)

      with {:ok, user} <- Accounts.create_instructor(user_details),
           {:ok, refresh_token, _} <- generate_refresh_token(user),
           {:ok, _, {jwt, _}} <- Guardian.refresh(refresh_token) do
        json(conn, %{token: jwt, refresh_token: refresh_token, user: %{id: user.id}})
      end
    else
      changeset
    end
  end

  defparams(
    login_params(%{
      email!: :string,
      password!: :string
    })
  )

  def login(conn, params) do
    changeset = login_params(params)

    if changeset.valid? do
      credentials = Params.to_map(changeset)

      with {:ok, user} <- Identity.login_with_email_and_password!(credentials.email, credentials.password),
           {:ok, refresh_token, _} <- generate_refresh_token(user),
           {:ok, _, {jwt, _}} <- Guardian.refresh(refresh_token) do
        json(conn, %{token: jwt, refresh_token: refresh_token, user: %{id: user.id}})
      else
        _ -> {:invalid_argument, "Invalid credentials"}
      end
    else
      changeset
    end
  end

  defparams(
    register_student_invite_params(%{
      token!: :string,
      name!: :string,
      password!: :string
    })
  )

  def register_student_invite(conn, params) do
    changeset = register_student_invite_params(params)

    if changeset.valid? do
      invite_details = Params.to_map(changeset)

      with {:ok, user} <- Accounts.create_student(invite_details),
           {:ok, refresh_token, _} <- generate_refresh_token(user),
           {:ok, _, {jwt, _}} <- Guardian.refresh(refresh_token) do
        json(conn, %{token: jwt, refresh_token: refresh_token, user: %{id: user.id}})
      end
    else
      changeset
    end
  end

  defparams(
    refresh_params(%{
      refresh_token!: :string
    })
  )

  def refresh(conn, params) do
    changeset = refresh_params(params)

    if changeset.valid? do
      %{refresh_token: refresh_token} = Params.to_map(changeset)

      with {:ok, _, {jwt, claims}} <- Guardian.refresh(refresh_token),
           {:ok, user} <- Guardian.resource_from_claims(claims) do
        json(conn, %{token: jwt, refresh_token: refresh_token, user: %{id: user.id}})
      end
    else
      changeset
    end
  end

  defp generate_refresh_token(user) do
    Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {30, :days})
  end
end
