defmodule TestGettext do
  use Gettext, otp_app: :alternate
end

defmodule PageController do
  use Phoenix.Controller

  import Alternate.Helpers

  def index(conn, _params) do
    body =
      case conn.assigns.locale do
        "en" -> "hello world!"
        "es" -> "hola mundo!"
      end

    text(conn, body)
  end

  def about(conn, _params) do
    body = """
    lorem ipsum dolor sit amet

    #{localize(Router.Helpers.page_url(conn, :index))}
    """

    text(conn, body)
  end
end

defmodule Router do
  use Phoenix.Router
  use Alternate.Router

  pipeline(:browser) do
    plug(Alternate.Plug)
  end

  scope "/" do
    pipe_through(:browser)

    localized_scope(
      locales: ["en", "es"],
      default_locale: "en",
      gettext: TestGettext,
      persist: {:cookie, "locale"}
    ) do
      get("/", PageController, :index)
      get("/about", PageController, :about)
    end
  end
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

  test "link" do
    conn =
      build_conn()
      |> put_private(:phoenix_router_url, "https://example.com")
      |> get("/es/about")

    assert conn.resp_body =~ "https://example.com/es"
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
