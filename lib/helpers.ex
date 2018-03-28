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
    router =
      conn
      |> Phoenix.Controller.router_module()

    path_params = conn.path_params

    routes = router.__routes__

    original_path_info =
      path_params
      |> Enum.reduce(conn.path_info, fn {k, v}, path ->
        Enum.map(path, fn
          ^v -> ":#{k}"
          v -> v
        end)
      end)

    query_params =
      conn.query_params
      |> Enum.to_list()

    route_params =
      original_path_info
      |> Enum.reduce([], fn
        ":" <> key, params -> params ++ [Map.get(path_params, key, nil)]
        _segment, params -> params
      end)
      |> Enum.concat([query_params])

    original_path = "/" <> Enum.join(original_path_info, "/")

    {controller_module, action} =
      routes
      |> Enum.find(fn
        %{path: ^original_path} ->
          true

        _route ->
          false
      end)
      |> case do
        %{plug: controller_module, opts: [action: action, locale: _]} ->
          {controller_module, action}

        %{plug: controller_module, opts: action} ->
          {controller_module, action}
      end

    controller =
      controller_module
      |> Phoenix.Naming.resource_name("Controller")

    alternate_route(conn, type, locale, controller, action, route_params)
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
    locale = Map.fetch!(assigns, Config.locale_assign_key())
    [action: opts, locale: locale]
  end

  defmacro localize({helper, meta, [conn, opts | rest]}) do
    plug_opts =
      quote do
        Alternate.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
      end

    {helper, meta, [conn, plug_opts, rest]}
  end
end
