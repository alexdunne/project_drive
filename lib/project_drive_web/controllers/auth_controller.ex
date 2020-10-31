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
           {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
        json(conn, %{token: jwt, user: %{id: user.id}})
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
           {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
        json(conn, %{token: jwt, user: %{id: user.id}})
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
           {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
        json(conn, %{token: jwt, user: %{id: user.id}})
      end
    else
      changeset
    end
  end
end
