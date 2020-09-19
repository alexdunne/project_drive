defmodule ProjectDrive.Accounts.Email do
  import Bamboo.Email

  require Logger

  alias ProjectDrive.Accounts.StudentInvite

  @sender_email Application.fetch_env!(:project_drive, :sender_email)

  def student_invite_email(%StudentInvite{} = student_invite) do
    Logger.info(fn ->
      Logger.info("Creating a new student invite email for:")
      inspect(student_invite)
    end)

    %{email: email, instructor: instructor, token: token, expires_at: expires_at} = student_invite

    {:ok, formatted_expires_at} = Timex.format(expires_at, "{WDfull}, {D} {Mshort} {h24}:{m}")

    body =
      "You've been invited by Instructor #{instructor.name}. Token: #{token}, Expires at: #{
        formatted_expires_at
      }"

    new_email(
      to: email,
      from: @sender_email,
      subject: "New invite from #{instructor.email}",
      html_body: body,
      text_body: body
    )
  end
end
