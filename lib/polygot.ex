defmodule Polygot do

  @http_methods [
    :get, :post, :put, :patch, :delete, :options, :connect, :trace, :head
  ]

  @locales Application.get_env(:polygot, :locales)

  defmacro localize({verb, meta, [ path, plug, plug_opts | rest ]}) when verb in @http_methods do
    Enum.map(@locales, fn({locale, info}) ->
      { verb, meta, ["/#{info.path_prefix}#{path}", plug, [ action: plug_opts, locale: locale ], rest ]}
    end)
  end

end
