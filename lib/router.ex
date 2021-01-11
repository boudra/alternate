defmodule Alternate.Router do
  defmacro __using__(opts) do
    quote do
      require Alternate.Router
      import Alternate.Router
    end
  end

  defmacro localized_scope(opts, do: context) do
    quote do
      locales =
        Enum.into(Keyword.get(unquote(opts), :locales), %{}, fn
          kv = {_, _} ->
            kv

          locale ->
            {locale, locale}
        end)

      prefixes =
        Enum.into(Keyword.get(unquote(opts), :locales), %{}, fn
          {k, v} ->
            {v, k}

          locale ->
            {locale, locale}
        end)

      opts =
        unquote(opts)
        |> Keyword.put(:locales, locales)
        |> Keyword.put(:prefixes, prefixes)
        |> Map.new()

      scope path: "/:locale", private: %{alternate_config: opts} do
        unquote(context)
      end

      scope path: "/", private: %{alternate_config: opts} do
        unquote(context)
      end
    end
  end
end
