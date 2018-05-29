defmodule Mailstub.AccountsTest do
  use Mailstub.DataCase

  describe "send" do
    alias Mailstub.Accounts
    alias Mailstub.Projects

    @user_attrs %{password_confirmation: "123123" , password: "123123", email: "user@test.com"}
    @project_attrs %{name: "some name"}

    def project_fixture(user, attrs \\ %{}) do
      attrs = attrs |> Enum.into(@project_attrs)
      {:ok, project} = Projects.create_project(user, attrs)
      project
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Accounts.create_user()

      user
    end

    test "email" do
      user = user_fixture()
      project = project_fixture(user)


      host = :net_adm.localhost
      port = MailToJson.config(:smtp_port)

      subject = "Test subject"
      body = "Test Body"
      sender = "sender@test.com"
      recipients = ["recipients@test.com"]

      mail_body = 'Subject: #{subject}\r\nFrom: #{sender}\r\nTo: #{recipients}\r\n\r\n#{body}'
      mail = {sender, recipients, mail_body}
      client_options = [relay: host, username: project.key, password: project.secret, port: port]
      IO.inspect(:gen_smtp_client.send(mail, client_options))
    end
  end
end
