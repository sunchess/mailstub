defmodule Mailstub.Auth.Guardian do
  use Guardian, otp_app: :mailstub

  alias Mailstub.Repo
  alias Mailstub.Accounts.User
  import Mailstub.Accounts, only: [get_user!: 1]

  def subject_for_token(%User{id: user_id}, _claims) do
    {:ok, to_string(user_id)}
  end
  def subject_for_token(_, _) do
    {:error, :"Unknown resource type"}
  end

  def resource_from_claims(%{"sub" => user_id}) do
    IO.inspect(user_id)
    {:ok, get_user!(user_id)}
  end

  def resource_from_claims(_claims) do
    {:error, :"can't find resource"}
  end
end
