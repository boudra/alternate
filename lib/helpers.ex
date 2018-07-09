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
    router = Phoenix.Controller.router_module(conn)

    path_params = conn.path_params

    routes = router.__routes__

    original_path_info =
      path_params
      |> Enum.reduce(conn.path_info, fn {k, v}, path ->
        Enum.map(path, fn
          ^v ->
            ":#{k}"

          route_element ->
            if is_list(v) and route_element in v do
              "*#{k}"
            else
              route_element
            end
        end)
        |> Enum.uniq()
      end)

    query_params = Enum.to_list(conn.query_params)

    route_params =
      Enum.reduce(original_path_info, [], fn
        ":" <> key, params -> params ++ [Map.get(path_params, key, nil)]
        _segment, params -> params
      end) ++ [query_params]

    original_path = "/" <> Enum.join(original_path_info, "/")

    {helper, action} =
      routes
      |> Enum.find(fn
        %{path: ^original_path} ->
          true

        _route ->
          false
      end)
      |> case do
        %{helper: helper, opts: [action: action, locale: _]} ->
          {helper, action}

        %{helper: helper, opts: action} ->
          {helper, action}
      end

    has_localized_route? =
      Enum.any?(routes, fn route ->
        route_action =
          case route.opts do
            [action: action, locale: _] -> action
            action -> action
          end

        route.helper == helper && route_action == action &&
          route.assigns[Config.locale_assign_key()] == locale
      end)

    if has_localized_route? do
      alternate_route(conn, type, locale, helper, action, route_params)
    else
      nil
    end
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
