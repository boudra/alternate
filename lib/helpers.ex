defmodule Alternate.Helpers do
  alias Alternate.Config

  def locale_to_prefix(conn = %{private: %{alternate_config: %{prefixes: prefixes}}}, locale) do
    Map.get(prefixes, locale)
  end

  def alternate_route(conn, type, locale, controller, action, params) do
    router =
      conn
      |> Phoenix.Controller.router_module()

    helpers_module = String.to_atom("#{router}.Helpers")

    helper_function = String.to_atom("#{controller}_#{type}")

    params =
      if is_nil(locale) do
        params
      else
        [locale_to_prefix(conn, locale) | params]
      end

    apply(
      helpers_module,
      helper_function,
      [conn, action] ++ params
    )
  end

  def alternate_current_route(conn, type, locale) do
    router = Phoenix.Controller.router_module(conn)

    path_params = conn.path_params

    routes = router.__routes__

    case (Phoenix.Router.route_info(router, conn.method, conn.request_path, conn.host)) do
      route ->
        path_params =
          route.route
          |> String.split("/")
          |> Enum.flat_map(fn
            ":locale" ->
              []

            ":" <> key ->
              [Map.get(route.path_params, key)]

            "*" <> key ->
              [Map.get(route.path_params, key)]

            _ ->
              []
          end)

        query_params =
          unless match?(%Plug.Conn.Unfetched{}, conn.query_params) do
            [Enum.to_list(conn.query_params)]
          else
            []
          end

        route_params = path_params ++ query_params

        alternate_route(
          conn,
          type,
          locale,
          Phoenix.Naming.resource_name(route.plug, "Controller"),
          route.plug_opts,
          route_params
        )
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

  defmacro localize(args = {helper, meta, [conn, opts | rest]}) do
    quote do
      case unquote(conn).assigns[:locale] do
        nil ->
          unquote(args)

        locale ->
          prefix =
            Alternate.Helpers.locale_to_prefix(unquote(conn), locale)

          unquote({helper, meta, [conn, opts, (quote do: prefix) | rest]})
      end
    end
  end
end
