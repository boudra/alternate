defmodule AlternatePlugTest do
  use ExUnit.Case
  use Phoenix.ConnTest

  defmodule TestGettext do
    use Gettext, otp_app: :alternate
  end

  test "plug sets the Gettext locale" do
    Application.put_env(:alternate, :gettext_module, TestGettext)
    opts = Alternate.Plug.init([])

    build_conn()
    |> assign(:alternate_locale, "en-US")
    |> Alternate.Plug.call(opts)

    assert Gettext.get_locale(TestGettext) == "en-US"
  end
end
