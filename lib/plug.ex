defmodule Polygot.Plug do

  import Plug.Conn

  @locales Application.get_env(:polygot, :locales)
  @available_prefixes @locales
                      |> Map.values
                      |> Enum.map(&(Map.fetch!(&1, :path_prefix)))

  def init(opts), do: opts

  def call(conn = %Plug.Conn{path_info: [ prefix | _ ]}, _default)
    when prefix in @available_prefixes do
      { locale, _ } = Enum.find(@locales, fn({_,info}) ->
        info.path_prefix == prefix
      end)
      conn |> assign(:locale, locale)
  end

  def call(conn, _opts) do
    conn
  end

end
