defmodule Polygot.Helpers do

  @locale_assign_key Application.get_env(:polygot, :locale_assign_key, :polygot_locale)

  def localize_plug_opts(%Plug.Conn{assigns: assigns} = conn, opts) do
    locale = Map.fetch!(assigns, @locale_assign_key)
    [ action: opts, locale: locale ]
  end

  defmacro localize({helper, meta, [ conn, opts | rest ]} = x) do
    plug_opts = quote do
      Polygot.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
    end
    {helper, meta, [conn, plug_opts, rest]}
  end


end
