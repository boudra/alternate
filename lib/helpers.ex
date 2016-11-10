defmodule Alternate.Helpers do

  @locale_assign_key Application.get_env(:alternate, :locale_assign_key, :alternate_locale)

  def localize_plug_opts(%Plug.Conn{assigns: assigns} = _conn, opts) do
    locale = Map.fetch!(assigns, @locale_assign_key)
    [ action: opts, locale: locale ]
  end

  defmacro localize({helper, meta, [ conn, opts | rest ]}) do
    plug_opts = quote do
      Alternate.Helpers.localize_plug_opts(unquote(conn), unquote(opts))
    end
    {helper, meta, [conn, plug_opts, rest]}
  end


end
