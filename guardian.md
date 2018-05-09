# Elixir + Phoenix Framework 1.3 + Guardian + JWT(Refresh, Revoke, Recover) + Comeonin

### User model bootstrap
Let's generate User model and controller.

```bash
mix ecto.create # create DB table
mix phx.gen.json Accounts User users email:string password_hash:string # scaffold users structure
```

Now we need to create folders `lib/baxter_web/controllers/v1/` and `lib/baxter_web/views/v1/`. After that you need to move `user_controller.ex` and `user_view.ex` to these directories.

Don't forget to change modules name and alias.
- `BaxterWeb.UserController` => `BaxterWeb.V1.UserController`
- `BaxterWeb.UserView` => `BaxterWeb.V1.UserView`

Also we need to do some fixes in migration file.
- If you need `uuid` instead of `id` we need to add `:binary_id` field and disable native `primary_key`.
- If you have columns with unique values you also need to call `unique_index` method.
- If you need default values and not null guardians, you need to add `default` and `null` instructions.

```elixir
defmodule Baxter.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
```

Let's migrate DB.
```bash
mix ecto.migrate
```

Now we need to add users path to our API routes.
```elixir
defmodule BaxterWeb.Router do
  # ...
  scope "/api/v1", BaxterWeb.V1 do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
  # ...
end
```


### Preparing environment
We need to generate secret key for development environment.
```bash
mix phx.gen.secret #=> ednkXywWll1d2svDEpbA39R5kfkc9l96j0+u7A8MgKM+pbwbeDsuYB8MP2WUW1hf
```

Guardian requires serializer for JWT token generation, so we need to create it `lib/baxter/auth/token_serializer.ex`.

```elixir
defmodule Baxter.Auth.TokenSerializer do
  use Guardian, otp_app: :baxter
  alias Baxter.Accounts.User
  import Baxter.Accounts, only: [get_user!: 1]

  def subject_for_token(%User{id: user_id}, _claims) do
    {:ok, to_string(user_id)}
  end
  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => user_id}) do
    {:ok, get_user!(user_id)}
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
```

Also we need authentication errors handler module. Let's create it `lib/baxter/auth/error_handler.ex`.

```elixir
defmodule Baxter.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    message = %{
      status: :unauthorized,
      message: "authentication failed!"
    }
    send_resp(conn, 401, Poison.encode!(message))
  end
end
```

After that we need to add Guardian configuration. Add `guardian` base configuration to your `config/config.exs`

```elixir
config :baxter, Baxter.Accounts.TokenSerializer,
       issuer: "baxter",
       secret_key: "ednkXywWll1d2svDEpbA39R5kfkc9l96j0+u7A8MgKM+pbwbeDsuYB8MP2WUW1hf",
       ttl: {1, :days},
       token_ttl: %{
         "refresh" => {30, :days},
         "access" => {1, :days}
       }
```

Add `guardian` dependency to your `mix.exs`
```elixir
defp deps do
  [
    # ...
    {:guardian, "~> 1.0-beta"},
    # ...
  ]
end
```

Fetch and compile dependencies

```bash
mix do deps.get, compile
```

#### Guardian is ready!

### Model authentication part

#### User tweaks

Next step is to add validations to `lib/baxter/accounts/user.ex`. Virtual `:password` field will exist in Ecto structure, but not in the database, so we are able to provide password to the model’s changesets and, therefore, validate that field.

```elixir
defmodule Baxter.Accounts.User do
  # ...
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true # We need to add this row
    field :password_hash, :string

    timestamps()
  end
  # ...
end
```

#### Validations and password hashing

Add `comeonin` dependency to your `mix.exs`
```elixir
#...
def application do
  [applications: [:comeonin]] # Add comeonin to OTP application
end
# ...
defp deps do
  [
    # ...
    {:comeonin, "~> 4.0"}, # Add comeonin to deps
    {:argon2_elixir, "~> 1.2"} # Add comeonin encryption algorithm to deps
    # ...
  ]
end
```

Now we need to edit `lib/baxter/accounts/user.ex`, add validations for `[:email, password]` and integrate password hash generation.

```elixir
defmodule Baxter.Accounts.User do
  #...
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_changeset
  end

  defp validate_changeset(user) do
    user
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*/, [message: "Must include at least one lowercase letter, one uppercase letter, and one digit"])
    |> generate_password_hash
  end

  defp generate_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Argon2.hashpwsalt(password))
      _ ->
        changeset
    end
  end
  #...
end
```

### API authentication with Guardian

Let's add headers check in our `lib/baxter_web/router.ex` for further authentication flow.

```elixir
defmodule BaxterWeb.Router do
  # ...
  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Guardian.Plug.Pipeline,
      module: Baxter.Auth.TokenSerializer,
      error_handler: Baxter.Auth.ErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: :none, claims: %{typ: "access"}
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated
  end

  # ...

  scope "/api/v1", BaxterWeb do
    pipe_through :api

    pipe_through :authenticated # restrict unauthenticated access for routes below
    resources "/users", UserController, except: [:new, :edit]
  end
  # ...
end
```

### Registration
Now we can't get access to /users route without Bearer JWT Token in header. That's why we need to add `AuthController` and `SessionController`. It's a good time to make commit before further changes.

Hey we need to add some more logic registration.
Let's create `AuthController`. We need to create new file `lib/baxter_web/controllers/auth_controller.ex`.

```elixir
defmodule BaxterWeb.V1.AuthController do
  use BaxterWeb, :controller

  alias Baxter.Accounts
  alias Baxter.Accounts.User

  action_fallback BaxterWeb.FallbackController

  plug Baxter.Auth.ScrubParams, "user" # Pay attention. We need to create out own plug!

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render("sign_up.json", %{})
    end
  end
end
```

Now we need `ScrubParams` module. It should be located in `lib/baxter/auth/scrub_params.ex`.
This module is required to be sure that we have correct object structure in our sign_up request.

```
defmodule Baxter.Auth.ScrubParams do
  use BaxterWeb, :controller

  def init(key), do: key
  def call(conn, key) do
    scrub_params(conn, key)
  rescue
    Phoenix.MissingParamError ->
      message = %{
        status: "error",
        message: "expected key \"#{key}\" to be present in params"
      }
      conn
      |> put_status(:bad_request)
      |> json(message)
      |> halt()
  end
end
```

Also we need `AuthView`. So, we need to create one more file named `lib/baxter_web/views/auth_view.ex`.

```elixir
defmodule BaxterWeb.V1.AuthView do
  use BaxterWeb, :view

  def render("sign_up.json", %{}) do
    %{
      status: :ok,
      message: "Now you can sign in using your email and password at `/api/v1/sign_in`. You will receive JWT token.\nPlease put this token into Authorization header for all authorized requests.\n"
    }
  end
end
```

After that we need to add /api/v1/sign_up route. Just add it inside of API scope.

```elixir
defmodule BaxterWeb.Router do
  # ...
  scope "/api/v1", BaxterWeb do
    pipe_through :api

    post "/sign_up", AuthController, :sign_up
    # ...
  end
  # ...
end
```

It's time to check our registration controller. If you don't know how to write request tests. You can use Postman app. Let's POST /api/v1/sign_up with this JSON body.

```json
{
  "user": {}
}
```

We should receive this response

```json
{
  "errors": {
    "password": [
      "can't be blank"
    ],
    "email": [
      "can't be blank"
    ]
  }
}
```

It's good point, but we need to create new user. That's why we need to POST correct payload.

```json
{
  "user": {
    "email": "hello@world.com",
    "password": "MySuperPa55"
  }
}
```

We must get this response.

```json
{
    "status": "ok",
    "message": "Now you can sign in using your email and password at `/api/v1/sign_in`. You will receive JWT token.\nPlease put this token into Authorization header for all authorized requests.\n"
}
```

### Session management

Wow! We've created new user! Now we have user with password hash in our DB. We need to add password checker function in `lib/baxter/accounts/user.ex`.

```elixir
defmodule Baxter.Accounts.User do
  # ...
  alias Baxter.Repo # Don't forget to add Repo alias!
  # ...

  # ...
  def find_and_confirm_password(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :login_not_found}
      user ->
        if Comeonin.Argon2.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :login_failed}
        end
    end
  end
  # ...
end
```

Before we add `SessionController`, we need to handle `:not_found` and `:unauthorized` errors. So, let's add this to `FallbackController` module in `lib/baxter_web/controllers/fallback_controller.ex`

```elixir
defmodule BaxterWeb.FallbackController do
  # ...
  def call(conn, {:error, :login_failed}), do: login_failed(conn)
  def call(conn, {:error, :login_not_found}), do: login_failed(conn)

  defp login_failed(conn) do
    conn
    |> put_status(:unauthorized)
    |> render(BaxterWeb.ErrorView, "error.json", status: :unauthorized,  message: "Authentication failed!")
  end
  # ...
end
```

Also we need to add "error.json" to `BaxterWeb.ErrorView` module in `lib/baxter_web/views/error_view.ex`. This part is required for correct JSON errors handling.

```elixir
defmodule BaxterWeb.ErrorView do
  use BaxterWeb, :view

  # ...
  def render("error.json", %{status: status, message: message}) do
    %{status: status, message: message}
  end
  # ...
end
```

It's time to use our credentials for sign in action. We need to add `SessionController` with `sign_in` actions, so just create `lib/baxter_web/controllers/v1/session_controller.ex`.

```elixir
defmodule BaxterWeb.V1.SessionController do
  use BaxterWeb, :controller

  alias Baxter.Accounts.User

  action_fallback BaxterWeb.FallbackController

  plug Baxter.Auth.ScrubParams, "user"

  def sign_in(conn, %{"user" => %{"email" => email, "password" => pass}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
         {:ok, jwt, _full_claims} <- Baxter.Auth.TokenSerializer.encode_and_sign(user, %{}, token_type: "access"),
    do: render(conn, "sign_in.json", user: user, jwt: jwt)
  end
end
```

Good! Next step is to add `SessionView` in `lib/baxter_web/views/v1/session_view.ex`.

```elixir
defmodule BaxterWeb.V1.SessionView do
  use BaxterWeb, :view

  def render("sign_in.json", %{user: user, jwt: jwt}) do
    %{
      status: :ok,
      data: %{
        token: jwt,
        email: user.email
      },
      message: "You are successfully logged in! Add this token to authorization header to make authorized requests."
    }
  end
end
```

Add some routes to handle sign_in action in `lib/baxter_web/router.ex`.

```elixir
defmodule BaxterWeb.Router do
  use BaxterWeb, :router
  #...
  scope "/api/v1", BaxterWeb do
    pipe_through :api

    post "/sign_up", AuthController, :sign_up
    post "/sign_in", SessionController, :sign_in # Add this line

    pipe_through :authenticated
    resources "/users", UserController, except: [:new, :edit]
  end
  # ...
end
```

Ok. Let's check this stuff. POST `/api/v1/sign_in` with this params.

```json
{
  "user": {
    "email": "hello@world.com",
    "password": "MySuperPa55"
  }
}
```

We should receive this response

```json
{
  "status": "ok",
  "message": "You are successfully logged in! Add this token to authorization header to make authorized requests.",
  "data": {
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjEiLCJleHAiOjE0OTgwMzc0OTEsImlhdCI6MTQ5NTQ0NTQ5MSwiaXNzIjoiQ2lhbkV4cG9ydGVyIiwianRpIjoiZDNiOGYyYzEtZDU3ZS00NTBlLTg4NzctYmY2MjBiNWIxMmI1IiwicGVtIjp7fSwic3ViIjoiVXNlcjoxIiwidHlwIjoiYXBpIn0.HcJ99Tl_K1UBsiVptPa5YX65jK5qF_L-4rB8HtxisJ2ODVrFbt_TH16kJOWRvJyJIoG2EtQz4dXj7tZgAzJeJw",
    "email": "hello@world.com"
  }
}
```

Now. You can take this token and add it to `Authorization: #{token}` header.

### JWT Revoke & Refresh & Verify

Add `guardian_db` dependency to your `mix.exs`
```elixir
defp deps do
  [
    # ...
    {:guardian, "~> 1.0-beta"},
    # ...
  ]
end
```

Add configuration to `config/config.exs`
```elixir
config :guardian_db, GuardianDb,
       repo: Baxter.Repo,
       schema_name: "guardian_tokens",
       sweep_interval: 60
```

Let's prepare migration file
```bash
mix ecto.gen.migration add_guardian_tokens
```

Add this content to migration file
```elixir
defmodule Baxter.Repo.Migrations.AddGuardianTokens do
  use Ecto.Migration

  def change do
    create table(:guardian_tokens, primary_key: false) do
      add :jti, :string, primary_key: true
      add :aud, :string, primary_key: true
      add :typ, :string
      add :iss, :string
      add :sub, :string
      add :exp, :bigint
      add :jwt, :text
      add :claims, :map
      timestamps()
    end
  end
end
```

To monitor expired tokens we should add GuardianDB worker to our supervision tree in `lib/baxter/application.ex`
```elixir
defmodule Baxter.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Baxter.Repo, []),
      supervisor(BaxterWeb.Endpoint, []),
      worker(GuardianDb.ExpiredSweeper, []) # add this line
    ]

    Supervisor.start_link(children, opts)
  end
end
```

After this we can run migrations
```bash
mix ecto.migrate
```

Alright. Now we need to add Guardian DB callbacks `lib/baxter/auth/token_serializer.ex`

```elixir
defmodule Baxter.Auth.TokenSerializer do
  #...
  # Just add these lines
  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- GuardianDb.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- GuardianDb.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
  #...
end
```

Good! We have callbacks, so all our authorization actions are ready for implementation. Let's edit `lib/baxter_web/controllers/v1/session_controller.ex`.
We need to add sign_out function.

```elixir
defmodule BaxterWeb.V1.SessionController do
  #...
  plug Baxter.Auth.ScrubParams, "user" when action in [:sign_in] # Action guardian should be added
  #...
  def sign_out(conn, _params) do
    with token <- Guardian.Plug.current_token(),
         {:ok, _claims} <- Baxter.Auth.TokenSerializer.revoke(token),
    do: render(conn, "sign_out.json", [])
  end
  #...
end
```

Oh, we have action without render function. Go to `lib/baxter_web/views/v1/session_view.ex`

```elixir
defmodule BaxterWeb.V1.SessionView do
  #...
  def render("sign_out.json", %{}) do
    %{
      status: :ok,
      message: "You are successfully signed out! Please receive new token to make requests."
    }
  end
  #...
end
```

We've added controller action, but we don't have route for this. Fix it in `lib/baxter_web/router.ex`

```elixir
defmodule BaxterWeb.Router do
  #...
  scope "/api/v1", BaxterWeb.V1 do
    #...
    pipe_through :authenticated
    delete "/sign_out", SessionController, :sign_out # Add this line please
    #...
  end
  #...
end
```

Ok we've finished token revoke functionality. Now it's time to make commit and check our work through postman. Done? Next section.
What should we do next? Verification and 'Remember me' functionality.
First of all let's add expiration time to our `config/config.exs`

```elixir
 config :baxter, Baxter.Auth.TokenSerializer,
        issuer: "baxter",
        secret_key: "As1T7M5hXW592R/c99bV1EaVN/Klv8jf6zI/GI47ZEIyVxAjK6vgzYdRpVcYsj9kk",
        token_ttl: %{
          "refresh" => {30, :days},
          "access" => {1, :days}
        }
```

Now we need to add verify callback to `Baxter.Auth.TokenSerializer` in `lib/baxter/auth/token_serializer.ex`.

```elixir
defmodule Baxter.Auth.TokenSerializer do
  #...
  def on_verify(claims, token, _options) do
    with {:ok, _} <- GuardianDb.on_verify(claims, token) do
      {:ok, claims}
    end
  end
  #...
end
```

Good. Next step is to edit session controller. Open `lib/baxter_web/controllers/v1/session_controller.ex` in your favorite text editor =)

```elixir
defmodule BaxterWeb.V1.SessionController do
  # Be careful, we changed some code in sign_in function
  def sign_in(conn, %{"user" => %{"email" => email, "password" => pass}}) do
    with {:ok, user} <- User.find_and_confirm_password(email, pass),
          {:ok, access, _full_claims} <- Baxter.Auth.TokenSerializer.encode_and_sign(user, %{}, token_type: "access"),
          {:ok, refresh, _full_claims} <- Baxter.Auth.TokenSerializer.encode_and_sign(user, %{}, token_type: "refresh"),
     do: render(conn, "sign_in.json", user: user, access: access, refresh: refresh)
  end

  #...

  # This code is new
  def verify(conn, _params) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, claims} = Baxter.Auth.TokenSerializer.decode_and_verify(token),
    do: render(conn, "verify.json")
  end

  def refresh(conn, _params) do
    with claims <- Guardian.Plug.current_claims(conn),
         refresh <- Guardian.Plug.current_token(conn),
         {:ok, user} <- Baxter.Auth.TokenSerializer.resource_from_claims(claims),
         {:ok, access, _full_claims} <- Baxter.Auth.TokenSerializer.encode_and_sign(user, %{}, token_type: "access"),
    do: render(conn, "sign_in.json", user: user, access: access, refresh: refresh)
  end
end
```

Now we need to edit `lib/baxter_web/views/v1/session_view.ex`.

```elixir
defmodule BaxterWeb.V1.SessionView do
  # Be careful, we changed some code in render function
  def render("sign_in.json", %{user: user, access: access, refresh: refresh}) do
    %{
      status: :ok,
      data: %{
        token: jwt,
        tokens: %{
          access: access,
          refresh: refresh,
        },
        email: user.email
      },
      message: "You are successfully logged in! Add this token to authorization header to make authorized requests."
    }
  end

  #...

  # This code is new
  def render("verify.json", %{}) do
    %{
      status: :ok,
      message: "Your token is not expired!",
    }
  end
end
```

Ok. Well, let's edit `lib/baxter_web/router.ex b/lib/baxter_web/router.ex`

```elixir
defmodule BaxterWeb.Router do
  #...
  # We need new pipeline for 'refresh' token
  pipeline :remember_me do
    plug Guardian.Plug.Pipeline,
      module: Baxter.Auth.TokenSerializer,
      error_handler: Baxter.Auth.ErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: :bearer, claims: %{typ: "refresh"}
  end

  #...

  scope "/api/v1", BaxterWeb.V1 do
    pipe_through :api

    post "/sign_up", AuthController, :sign_up
    post "/sign_in", SessionController, :sign_in

    # New scope block!
    scope "/" do
      pipe_through :remember_me
      get "/refresh", SessionController, :refresh
    end

    pipe_through :authenticated

    get "/verify", SessionController, :verify # New code!
    delete "/sign_out", SessionController, :sign_out
    resources "/users", UserController, except: [:new, :edit]
  end
end
```

YAY! All work related to tokens is done!

### Forgot password

Let's setup mailer
Add `bamboo` dependency and application to your `mix.exs`

```elixir
defp deps do
  # ...
  def application do
    [
      mod: {Baxter.Application, []},
      extra_applications: [:logger, :runtime_tools, :bamboo]
    ]
  end

  # ...

  [
    # ...
    {:bamboo, github: "thoughtbot/bamboo"},
    # ...
  ]
end
```

Compile it.

```bash
  mix do deps.get, compile
```

Add config for `bamboo` in config/config.exs

```elixir
config :baxter, Baxter.Mailer,
  adapter: Bamboo.LocalAdapter
```

Now we need mailer module. `lib/baxter/mailer.ex`

```elixir
defmodule Baxter.Mailer do
  use Bamboo.Mailer, otp_app: :baxter
end
```

And email module `lib/baxter/auth/email.ex`

```elixir
defmodule Baxter.Auth.Email do
  import Bamboo.Email
  alias Baxter.Accounts.User

  def forgot_password(%User{email: email}, magic_link) do
    new_email(
      to: email,
      from: "support@baxter.com",
      subject: "Baxter Password Reset.",
      html_body: "<p>Please use the following link to <a href=\"#{magic_link}\">reset your password</a>.</p>"
    )
  end
end
```

We need to add one more line to `lib/baxter_web/router.ex`

```elixir
defmodule BaxterWeb.Router do
  # pipelines
  #...
  forward "/sent_emails", Bamboo.SentEmailViewerPlug
  #...
  # scopes
end
```

We need url safe base64 generator
Add `secure_random` dependency to your `mix.exs`

```elixir
defp deps do
  [
    # ...
    {:secure_random, "~> 0.5"},
    # ...
  ]
end
```

Compile it.

```bash
  mix do deps.get, compile
```

Create migration for `reset_token` fields.

```bash
mix ecto.gen.migration add_password_reset_to_users
```

Migration content

```elixir
defmodule Baxter.Repo.Migrations.AddPasswordResetToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reset_token, :string
      add :reset_token_sent_at, :utc_datetime
    end
  end
end
```

```bash
mix ecto.migrate
```

Ok. User model `lib/baxter/accounts/user.ex`

```elixir
defmodule Baxter.Accounts.User do
  #...

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :reset_token, :string # Attention!
    field :reset_token_sent_at, :utc_datetime #  Attention!

    timestamps()
  end

  #...

  def reset_password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:reset_token, :reset_token_sent_at])
  end

  #...

  def send_password_recovery(user) do
    reset_params = %{
      reset_token: generate_reset_token(),
      reset_token_sent_at: DateTime.utc_now()
    }

    {:ok, user} =
      user
      |> reset_password_changeset(reset_params)
      |> Repo.update

    magic_link = "http://localhost:4000/api/v1/reset_password/#{reset_params.reset_token}"

    user
    |> Baxter.Auth.Email.forgot_password(magic_link)
    |> Baxter.Mailer.deliver_now
    :okkj
  end

  defp generate_reset_token(), do: generate_reset_token(SecureRandom.urlsafe_base64)
  defp generate_reset_token(token) do
    case Repo.get_by(User, reset_token: token) do
      nil -> token
      _user -> generate_reset_token()
    end
  end
end
```

Password controller - `lib/baxter_web/controllers/v1/password_controller.ex`

```elixir
defmodule BaxterWeb.V1.PasswordController do
  use BaxterWeb, :controller

  alias Baxter.Accounts
  alias Baxter.Accounts.User
  alias Baxter.Repo

  action_fallback BaxterWeb.FallbackController

  plug Baxter.Auth.ScrubParams, "user"

  def forgot_password(conn, %{"user" => user_params}) do
    case Repo.get_by(User, email: user_params["email"]) do
      nil -> :user_not_found
      user -> User.send_password_recovery(user)
    end
    render(conn, "forgot_password.json", %{})
  end
end
```

Password view - `lib/baxter_web/views/v1/password_view.ex`

```elixir
defmodule BaxterWeb.V1.PasswordView do
  use BaxterWeb, :view

  def render("forgot_password.json", %{}) do
    %{
      status: :ok,
      message: "Password recovery sent to user."
    }
  end
end
```

Router line - ``

```elixir
defmodule BaxterWeb.Router do
  #...
  scope "/api/v1", BaxterWeb.V1 do
    pipe_through :api
    #...
    post "/forgot_password", PasswordController, :forgot_password
    #...
  end
end
```

Password controller `reset password` - `lib/baxter_web/controllers/v1/password_controller.ex`

```elixir
defmodule BaxterWeb.V1.PasswordController do
  #...
  def reset_password(conn, %{"reset_token" => reset_token, "user" => user_params}) do
    with %User{} = user <- Repo.get_by(User, reset_token: reset_token),
         {:ok, %User{} = _user} <- Accounts.update_user(user, %{email: user.email, password: user_params["password"]})
    do
      conn
      |> render("reset_password.json", %{})
    end
  end
  #...
end
```

Password view - `lib/baxter_web/views/v1/password_view.ex`


```elixir
defmodule BaxterWeb.V1.PasswordView do
  #...
  def render("reset_password.json", %{}) do
    %{
      status: :ok,
      message: "Password successfully reset."
    }
  end
  #...
end
```

```elixir
defmodule BaxterWeb.Router do
  #...
  scope "/api/v1", BaxterWeb.V1 do
    pipe_through :api
    #...
    post "/reset_password/:reset_token", PasswordController, :reset_password
    #...
  end
end
```

YAY
