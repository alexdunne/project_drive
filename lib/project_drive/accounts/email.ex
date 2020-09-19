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

    new_email(
      to: student_invite.email,
      from: @sender_email,
      subject: "New invite from #{student_invite.instructor.email}",
      text_body: "You've been invited by Instructor #{student_invite.instructor.name}"
    )
  end
end
