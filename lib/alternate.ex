defmodule Alternate do
  @http_methods [
    :get,
    :post,
    :put,
    :patch,
    :delete,
    :options,
    :connect,
    :trace,
    :head
  ]

  def locales do
    Application.get_env(:alternate, :locales, %{})
  end

  def locale_assign_key do
    Application.get_env(:alternate, :locale_assign_key, :alternate_locale)
  end

  defp build_options(options, locale) do
    quote do
      assigns_with_locale = Map.new([{unquote(locale_assign_key), unquote(locale)}])

      assigns =
        Keyword.get(unquote(options), :assigns, %{})
        |> Map.merge(assigns_with_locale)

      Keyword.put(unquote(options), :assigns, assigns)
    end
  end

  defp do_localize({verb, meta, [path, plug, plug_opts, options]}) do
    locales
    |> Enum.to_list()
    |> Enum.map(fn {locale, config} ->
      path =
        quote do
          translated_path =
            unquote(options)
            |> Keyword.get(:translations, %{})
            |> Map.get(unquote(locale), unquote(path))

          case unquote(config.path_prefix) do
            "" -> ""
            prefix -> "/#{prefix}"
          end <> translated_path
        end

      options = build_options(options, locale)

      {verb, meta, [path, plug, [action: plug_opts, locale: locale], build_options(options, nil)]}
    end)
    |> Enum.concat([
      {verb, meta, [path, plug, plug_opts, build_options(options, nil)]}
    ])
  end

  defmacro localize({verb, meta, [path, plug, plug_opts]}) when verb in @http_methods do
    do_localize({verb, meta, [path, plug, plug_opts, []]})
  end

  defmacro localize({verb, meta, [path, plug, plug_opts, options]}) when verb in @http_methods do
    do_localize({verb, meta, [path, plug, plug_opts, options]})
  end
end
