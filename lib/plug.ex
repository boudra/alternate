defmodule Polygot.Plug do

  import Plug.Conn

  @locales Application.get_env(:polygot, :locales)
  @gettext Application.get_env(:polygot, :gettext_module)
  @available_prefixes @locales
                      |> Map.values
                      |> Enum.map(&(Map.fetch!(&1, :path_prefix)))

  def init(opts), do: opts

  def find_locale_by_prefix(prefix) do
    Enum.find(@locales, fn({_,info}) ->
      info.path_prefix == prefix
    end)
  end

  def call(conn = %Plug.Conn{path_info: [ prefix | _ ]}, _opts)
    when prefix in @available_prefixes do
      {locale, _} = find_locale_by_prefix prefix
      Gettext.put_locale(@gettext, locale)
      conn |> assign(:locale, locale)
  end

  def call(conn, _opts) do
    conn
  end

end
