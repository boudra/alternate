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

  defp do_localize({verb, meta, [path, plug, plug_opts, options]}) do
    routes =
      Enum.map(locales(), fn {locale, config} ->
        prefix =
          case config.path_prefix do
            "" -> ""
            prefix -> "/#{prefix}"
          end

        prefixed_path =
          quote do
            unquote(prefix) <> unquote(path)
          end

        {verb, meta, [prefixed_path, plug, [action: plug_opts, locale: locale], options]}
      end)

    [{verb, meta, [path, plug, plug_opts, options]} | routes]
  end

  defmacro localize({verb, meta, [path, plug, plug_opts]}) when verb in @http_methods do
    do_localize({verb, meta, [path, plug, plug_opts, []]})
  end

  defmacro localize({verb, meta, [path, plug, plug_opts, options]}) when verb in @http_methods do
    do_localize({verb, meta, [path, plug, plug_opts, options]})
  end
end
