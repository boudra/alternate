defmodule Polygot.Plug do

  import Plug.Conn

  @locales Application.get_env(:polygot, :locales, %{})
  @gettext Application.get_env(:polygot, :gettext_module, nil)
  @locale_assign_key Application.get_env(:polygot, :locale_assign_key, :polygot_locale)

  def init(opts), do: opts

  unless is_nil(@gettext) do
    def call(%Plug.Conn{assigns: assigns} = conn, _opts) do
      case Map.get(assigns, @locale_assign_key, nil) do
        nil ->
          conn
        locale ->
          IO.inspect locale
          Gettext.put_locale(@gettext, locale)
          conn
      end
    end
  end

  def call(conn, _opts) do
    conn
  end

end
