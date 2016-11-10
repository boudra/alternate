defmodule Alternate.Plug do

  @locales Application.get_env(:alternate, :locales, %{})
  @gettext Application.get_env(:alternate, :gettext_module, nil)
  @locale_assign_key Application.get_env(:alternate, :locale_assign_key, :alternate_locale)

  def init(opts), do: opts

  unless is_nil(@gettext) do
    def call(%Plug.Conn{assigns: assigns} = conn, _opts) do
      case Map.get(assigns, @locale_assign_key, nil) do
        nil ->
          conn
        locale ->
          Gettext.put_locale(@gettext, locale)
          conn
      end
    end
  end

  def call(conn, _opts) do
    conn
  end

end
