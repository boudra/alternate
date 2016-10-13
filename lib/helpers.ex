defmodule Polygot.Helpers do

  def localize_plug_opts(%Plug.Conn{assigns: %{ locale: locale }} = conn, opts) do
    [ action: opts, locale: locale ]
  end

  def localize_plug_opts(%Plug.Conn{} = conn, opts) do
    raise RuntimeError, message: "Assign :locale not found in the conn. Did you forget to call Polygot.Plug?"
  end

  defmacro localize({helper, meta, [ conn, opts | rest ]} = x) do
    plug_opts = quote do
      Polygot.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
    end
    {helper, meta, [conn, plug_opts, rest]}
  end


end
