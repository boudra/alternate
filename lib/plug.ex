defmodule Alternate.Plug do
  def locale_assign_key do
    Application.get_env(:alternate, :locale_assign_key, :alternate_locale)
  end

  def gettext do
    Application.get_env(:alternate, :gettext_module, nil)
  end

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: assigns} = conn, _opts) do
    case gettext do
      nil ->
        conn

      gettext ->
        case Map.get(assigns, locale_assign_key, nil) do
          nil ->
            conn

          locale ->
            Gettext.put_locale(gettext, locale)
            conn
        end
    end
  end
end
