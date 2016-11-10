defmodule Polygot do

  @http_methods [
    :get, :post, :put, :patch, :delete, :options, :connect, :trace, :head
  ]

  @locales Application.get_env(:polygot, :locales, %{})
  @locale_assign_key Application.get_env(:polygot, :locale_assign_key, :polygot_locale)

  defp do_localize({verb, meta, [ path, plug, plug_opts, options ]}) do
    Enum.map(@locales, fn({locale, config}) ->
        path = quote do
          translated_path = unquote(options)
                            |> Keyword.get(:translations, %{})
                            |> Map.get(unquote(locale), unquote(path))
          case unquote(config.path_prefix) do
            "" -> ""
            prefix -> "/#{prefix}"
          end <> translated_path
        end
        options = quote do
          assigns_with_locale = Map.new([{ unquote(@locale_assign_key), unquote(locale) }])
          assigns = Keyword.get(unquote(options), :assigns, %{})
                    |> Map.merge(assigns_with_locale)
          Keyword.put(unquote(options), :assigns, assigns)
        end
      { verb, meta, [ path, plug, [ action: plug_opts, locale: locale ], options ]}
    end)
  end

  defmacro localize({verb, meta, [ path, plug, plug_opts ]}) when verb in @http_methods do
    do_localize({verb, meta, [ path, plug, plug_opts, [] ]})
  end

  defmacro localize({verb, meta, [ path, plug, plug_opts, options ]}) when verb in @http_methods do
    do_localize({verb, meta, [ path, plug, plug_opts, options ]})
  end

end
