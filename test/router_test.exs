defmodule TestGettext do
  use Gettext, otp_app: :alternate
end

defmodule PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    text(conn, "hello world!")
  end
end

defmodule Router do
  is = 2

  use Alternate.Router,
    locales: ["en", "es"],
    gettext: TestGettext,
    x: "what#{is}",
    persist: {:cookie, "locale"}

  use Phoenix.Router

  pipeline :browser do
    plug Alternate.Plug
  end

  scope "/" do
    pipe_through :browser

    localize(get("/", PageController, :index))
  end
end

defmodule AlternateRouterTest do
  use ExUnit.Case
  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint Router

  test "plug sets the Gettext locale" do
    conn = get(build_conn(), "/")
    assert conn.resp_body =~ "hello world"
  end
end
