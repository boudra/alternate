defmodule Alternate.Plug do
  alias Alternate.{Helpers}

  import Plug.Conn

  def init(opts) do
    opts
    |> Keyword.update(:locales, [], fn locales ->
      Enum.into(locales, %{}, fn
        kv = {_, _} ->
          kv

        locale ->
          {locale, locale}
      end)
    end)
  end

  defp put_gettext_locale(conn, gettext, locale) when is_atom(gettext) do
    Gettext.put_locale(gettext, locale)

    conn
  end

  defp put_gettext_locale(conn, _, _) do
    conn
  end

  defp redirect_to_localized_route(conn, locale) do
    case Helpers.alternate_current_path(conn, locale) do
      nil ->
        conn

      url ->
        conn
        |> put_status(302)
        |> Phoenix.Controller.redirect(external: url)
        |> halt()
    end
  end

  defp persist_locale(conn, {:session, key}, locale) do
    conn
    |> put_session(key, locale)
  end

  defp persist_locale(conn, {:cookie, key}, locale) do
    case Map.get(conn.req_cookies, key) do
      ^locale ->
        conn

      _ ->
        put_resp_cookie(conn, key, locale)
    end
  end

  def put_locale(conn, opts, locale) do
    conn
    |> assign(:locale, locale)
    |> persist_locale(Keyword.get(opts, :persist), locale)
    |> put_gettext_locale(Keyword.get(opts, :gettext), locale)
  end

  # Specifing the locale in the path overrides everything else
  def call(conn, opts) do
    default_locale = Keyword.get(opts, :default_locale)
    path_locale = from_prefix(conn, opts)

    current_locale =
      path_locale || from_persisted(conn, opts) || from_accept_language(conn, opts) ||
        default_locale

    cond do
      current_locale != path_locale && conn.method in ~w(GET HEAD) ->
        redirect_to_localized_route(conn, current_locale)

      true ->
        put_locale(conn, opts, current_locale)
    end
  end

  def from_prefix(%Plug.Conn{path_params: %{"locale" => prefix}}, opts) do
    opts
    |> Keyword.get(:locales)
    |> Map.get(prefix)
  end

  def from_prefix(_conn, _opts) do
    nil
  end

  defp persisted_locale(conn, {:session, key}) do
    get_session(conn, key)
  end

  defp persisted_locale(conn, {:cookie, key}) do
    Map.get(conn.req_cookies, key)
  end

  def from_persisted(conn = %Plug.Conn{}, opts) do
    persisted_locale(conn, Keyword.get(opts, :persist))
  end

  def from_accept_language(conn, opts) do
    with [header | _] <- get_req_header(conn, "accept-language"),
         languages <- :cow_http_hd.parse_accept_language(header) do
      available_locales = Keyword.get(opts, :locales)

      Enum.find_value(languages, fn {locale, _} ->
        case String.split(locale, "-") do
          [lang, _] ->
            Map.get(available_locales, locale) || Map.get(available_locales, lang)

          _ ->
            Map.get(available_locales, locale)
        end
      end)
    else
      _ ->
        nil
    end
  end
end
