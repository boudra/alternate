defmodule TestGettext do
  use Gettext, otp_app: :alternate
end

defmodule PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    body =
      case conn.assigns.locale do
        "en" -> "hello world!"
        "es" -> "hola mundo!"
      end

    text(conn, body)
  end
end

defmodule Router do
  use Alternate.Router
  use Phoenix.Router

  pipeline :browser do
    plug(Alternate.Plug,
      locales: ["en", "es"],
      default_locale: "en",
      gettext: TestGettext,
      persist: {:cookie, "locale"}
    )
  end

  scope "/:locale" do
    pipe_through(:browser)

    get("/", PageController, :index)
  end
end

defmodule Endpoint do
  use Phoenix.Endpoint, otp_app: :alternate

  plug(Router)
end

defmodule AlternateRouterTest do
  use ExUnit.Case
  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint Router

  test "set locale via path param" do
    conn = get(build_conn(), "/en")
    assert conn.resp_body =~ "hello world!"

    conn = get(build_conn(), "/es")
    assert conn.resp_body =~ "hola mundo!"
  end

  test "default locale" do
    conn = get(build_conn(), "/")
    assert conn.resp_body =~ "hello world!"
  end

  test "set locale via accept language" do
    conn =
      build_conn()
      |> put_req_header("accept-language", "es-ES")
      |> get("/")

    assert redirected_to(conn, 302) =~ "/es"
  end

  test "plug redirects to persisted locale" do
    conn =
      build_conn()
      |> put_req_cookie("locale", "es")
      |> fetch_cookies()
      |> get("/")

    assert redirected_to(conn, 302) =~ "/es"
  end

  test "override persisted locale" do
    conn =
      build_conn()
      |> put_req_cookie("locale", "es")
      |> fetch_cookies()
      |> get("/en")

    assert conn.resp_body =~ "hello world!"
  end
end
