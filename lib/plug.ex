defmodule Alternate.Plug do
  alias Alternate.{Config, Helpers}

  import Plug.Conn

  def init(%{} = opts) do
    opts
    |> Map.put_new(:assign_key, Config.locale_assign_key())
    |> Map.put_new(:session_key, Config.locale_session_key())
    |> Map.put_new(:gettext, Config.gettext())
  end

  def init(_) do
    init(%{})
  end

  defp put_gettext_locale(
         conn,
         assign_key,
         gettext_module
       )
       when is_atom(gettext_module) do
    with nil <- conn.assigns[assign_key],
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

  defp put_gettext_locale(conn, _, nil) do
    conn
  end

  defp put_session_locale(
         conn,
         assign_key,
         session_key
       )
       when is_binary(session_key) do
    case conn.assigns[assign_key] do
      nil ->
        conn

      locale ->
        conn
        |> put_session(session_key, locale)
    end
  end

  defp put_session_locale(conn, _, _) do
    conn
  end

  defp redirect_to_localized_route(
         conn,
         assign_key,
         session_key
       )
       when is_binary(session_key) do
    case {conn.assigns[assign_key], get_session(conn, session_key)} do
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

  defp redirect_to_localized_route(conn, _, _) do
    conn
  end

  def call(%Plug.Conn{assigns: assigns} = conn, %{
        gettext: gettext_module,
        assign_key: assign_key,
        session_key: session_key
      }) do
    conn
    |> assign(assign_key, assigns[assign_key])
    |> put_gettext_locale(assign_key, gettext_module)
    |> put_session_locale(assign_key, session_key)
    |> case do
      conn = %{method: "GET"} ->
        redirect_to_localized_route(conn, assign_key, session_key)

      conn ->
        conn
    end
  end
end
