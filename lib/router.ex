defmodule Alternate.Router do
  defmacro __using__(opts) do
    quote do
      require Alternate.Router
      import Alternate.Router
    end
  end

  defmacro localized_scope(opts, do: context) do
    quote do
      opts = unquote(opts)
        |> Keyword.update(:locales, [], fn locales ->
          Enum.into(locales, %{}, fn
            kv = {_, _} ->
              kv

            locale ->
              {locale, locale}
          end)
        end)

      scope [path: "/", private: %{alternate_config: opts}] do
        unquote(context)
      end

      for {prefix, locale} <- Keyword.get(opts, :locales) do
        scope [path: "/#{prefix}", assigns: %{locale: locale}, private: %{alternate_config: opts}] do
          unquote(context)
        end
      end
    end
  end
end
