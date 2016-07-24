defmodule Polygot.Helpers do

  def localize_plug_opts(%Plug.Conn{} = conn, opts) do
    [ action: opts, locale: conn.assigns[:locale] ]
  end

  defmacro localize({helper, meta, [ conn, opts | rest ]} = x) do
    plug_opts = quote do
      Polygot.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
    end
    {helper, meta, [conn, plug_opts, rest]}
  end


end
