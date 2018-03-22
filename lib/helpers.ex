defmodule Alternate.Helpers do
  @locale_assign_key Config.locale_assign_key()

  def alternate_route(conn, locale) do
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

    router =
      conn
      |> Phoenix.Controller.router_module()

    apply(
      String.to_atom("#{router}.Helpers"),
      String.to_atom("#{controller}_path"),
      [conn, [action: action, locale: locale]] ++ route_params
    )
  end

  def localize_plug_opts(%Plug.Conn{assigns: assigns} = _conn, opts) do
    locale = Map.fetch!(assigns, @locale_assign_key)
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
