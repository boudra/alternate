defmodule Alternate.Helpers do
  alias Alternate.Config

  def alternate_route(conn, type, locale, controller, action, params) do
    router =
      conn
      |> Phoenix.Controller.router_module()

    helpers_module = String.to_atom("#{router}.Helpers")

    helper_function = String.to_atom("#{controller}_#{type}")

    case locale do
      nil ->
        apply(
          helpers_module,
          helper_function,
          [conn, action] ++ params
        )

      _ ->
        apply(
          helpers_module,
          helper_function,
          [conn, [action: action, locale: locale]] ++ params
        )
    end
  end

  def alternate_current_route(conn, type, locale) do
    prefixes = Config.prefixes()
    path_locale = Map.get(prefixes, List.first(conn.path_info))

    unlocalized =
      if is_nil(path_locale) do
        conn.path_info
      else
        Enum.drop(conn.path_info, 1)
      end

    prefix = get_in(Config.locales(), [locale, :path_prefix])

    query =
      if String.length(conn.query_string) > 0 do
        "?" <> conn.query_string
      else
        ""
      end

    path = "/" <> Enum.join([prefix | unlocalized], "/")

    url =
      if type == "url" do
        conn.private.phoenix_endpoint.url()
      else
        ""
      end

    url <> path <> query
  end

  def alternate_current_path(conn, locale) do
    alternate_current_route(conn, "path", locale)
  end

  def alternate_current_url(conn, locale) do
    alternate_current_route(conn, "url", locale)
  end

  def alternate_path(conn, locale, controller, action, params) do
    alternate_route(conn, "path", locale, controller, action, params)
  end

  def alternate_url(conn, locale, controller, action, params) do
    alternate_route(conn, "url", locale, controller, action, params)
  end

  def localize_plug_opts(%Plug.Conn{assigns: assigns} = _conn, opts) do
    case Map.fetch(assigns, Config.locale_assign_key()) do
      {:ok, nil} ->
        opts

      {:ok, locale} ->
        [action: opts, locale: locale]

      :error ->
        opts
    end
  end

  defmacro localize({helper, meta, [conn, opts | rest]}) do
    plug_opts =
      quote do
        Alternate.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
      end

    {helper, meta, [conn, plug_opts, rest]}
  end
end
