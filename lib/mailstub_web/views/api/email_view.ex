defmodule MailstubWeb.Api.EmailView do
  use MailstubWeb, :view
  alias MailstubWeb.Api.EmailView

  def render("index.json", %{emails: emails}) do
    %{data: render_many(emails, EmailView, "email.json")}
  end

  def render("show.json", %{email: email}) do
    %{data: render_one(email, EmailView, "email.json")}
  end

  def render("email.json", %{email: email}) do
    %{
       id: email.id,
       from: email.body["From"],
       to: email.body["To"],
       subject: email.body["Subject"],
       body: email.body["html_body"]
    }
  end

end
