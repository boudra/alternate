defmodule Alternate.Plug do
  alias Alternate.{Config, Helpers}

  import Plug.Conn

  def init(%{} = opts) do
    opts
    |> Map.put_new(:gettext, Config.gettext())
  end

  def init(_) do
    init(%{})
  end

  defp put_gettext_locale(
         conn,
         gettext_module
       )
       when is_atom(gettext_module) do
    with nil <- conn.assigns[:locale],
         fallback_locale when is_nil(fallback_locale) != nil <- Config.default_fallback_locale() do
      Gettext.put_locale(gettext_module, fallback_locale)
    else
      nil ->
        raise "Define a fallback_locale"

      locale ->
        Gettext.put_locale(gettext_module, locale)
    end

    conn
  end

  defp put_gettext_locale(conn, nil) do
    conn
  end

  defp put_session_locale(conn) do
    case conn.assigns[:locale] do
      nil ->
        conn

      locale ->
        put_session(conn, :locale, locale)
    end
  end

  defp redirect_to_localized_route(conn) do
    case {conn.assigns[:locale], get_session(conn, :locale)} do
      {nil, locale} when is_binary(locale) ->
        case Helpers.alternate_current_url(conn, locale) do
          nil ->
            conn

          url ->
            conn
            |> put_status(302)
            |> Phoenix.Controller.redirect(external: url)
            |> halt()
        end

      _ ->
        conn
    end
  end

  def call(%Plug.Conn{path_info: path_info} = conn, %{gettext: gettext_module}) do
    path_locale = Map.get(Config.prefixes(), List.first(path_info))

    conn
    |> assign(:locale, path_locale)
    |> put_gettext_locale(gettext_module)
    |> put_session_locale()
    |> case do
      conn = %{method: method} when method in ~w(GET HEAD) ->
        redirect_to_localized_route(conn)

      conn ->
        conn
    end
  end
end
