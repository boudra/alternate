defmodule Alternate.Router do
  defmacro __using__(opts) do
    opts =
      opts
      |> Keyword.update(:locales, [], fn locales ->
        Enum.into(locales, %{}, fn
          kv = {_, _} ->
            kv

          locale ->
            {locale, locale}
        end)
        |> Macro.escape()
      end)

    quote do
      import Alternate.Router
      @alternate_opts unquote(opts)
    end
  end

  defp do_localize(router, {verb, meta, [path, plug, plug_opts]}) do
    do_localize(router, {verb, meta, [path, plug, plug_opts, []]})
  end

  defp do_localize(router, {verb, meta, [path, plug, plug_opts, options]}) do

    router
    |> Module.get_attribute(:alternate_opts)
    |> Keyword.get(:locales)
    |> Enum.map(fn {prefix, locale} ->
      path =
        quote do
          translated_path =
            Gettext.with_locale(unquote(locale), fn ->
              Keyword.get(@alternate_opts, :gettext).gettext(unquote(path))
            end)

          case unquote(prefix) do
            "" -> ""
            prefix -> "/#{prefix}"
          end <> translated_path
        end

      {verb, meta, [path, plug, [action: plug_opts, locale: locale], options]}
    end)
    |> Enum.concat([
      {verb, meta, [path, plug, plug_opts, options]}
    ])
  end

  defmacro localize(args) do
    do_localize(
      __CALLER__.module,
      args
    )
  end
end
