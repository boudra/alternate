defmodule Alternate.Helpers do
  def alternate_route(conn, type, locale, controller, action, params) do
    router =
      conn
      |> Phoenix.Controller.router_module()

    helpers_module = String.to_atom("#{router}.Helpers")

    helper_function = String.to_atom("#{controller}_#{type}")

    apply(
      helpers_module,
      helper_function,
      [conn, [action: action, locale: locale]] ++ params
    )
  end

  def alternate_current_route(conn, type, locale) do
    route_params =
      conn.params
      |> Enum.reject(fn {k, _} ->
        conn.body_params |> Map.keys() |> Enum.member?(k)
      end)
      |> Enum.reject(fn {k, _} ->
        conn.query_params |> Map.keys() |> Enum.member?(k)
      end)
      |> Map.new()
      |> Map.values()

    controller =
      conn
      |> Phoenix.Controller.controller_module()
      |> Phoenix.Naming.resource_name("Controller")

    action =
      conn
      |> Phoenix.Controller.action_name()

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
