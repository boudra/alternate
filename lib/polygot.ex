defmodule Polygot do
  @http_methods [:get, :post, :put, :patch, :delete, :options, :connect, :trace, :head]

  IO.inspect Application.get_all_env(:polygot)
  @locales Application.get_env(:polygot, :locales)
  IO.inspect Application.fetch_env!(:polygot, :locales)


  defmacro localize({verb, meta, [ path, plug, plug_opts | rest ]}) when verb in @http_methods do
    Enum.map(@locales, fn(locale) ->
      { verb, meta, ["/#{String.downcase(locale)}#{path}", plug, [ action: plug_opts, locale: locale ], rest ]}
    end)
  end

end
