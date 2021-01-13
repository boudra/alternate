defmodule Alternate.Config do
  def locale_assign_key() do
    Application.get_env(:alternate, :locale_assign_key, :alternate_locale)
  end

  def locale_session_key() do
    Application.get_env(:alternate, :locale_session_key, nil)
  end

  def gettext() do
    Application.get_env(:alternate, :gettext_module, nil)
  end

  def default_fallback_locale() do
    Application.get_env(:alternate, :default_fallback_locale, nil)
  end

  def locales() do
    Application.get_env(:alternate, :locales, %{})
  end

  def prefixes() do
    locales()
    |> Enum.into(%{}, fn {locale, %{path_prefix: prefix}} ->
      {prefix, locale}
    end)
  end
end
