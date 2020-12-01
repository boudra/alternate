defmodule Alternate.Router do
  defmacro __using__(_opts) do
    quote do
      @before_compile Alternate.Router
    end
  end

  defmacro __before_compile__(env) do
    routes =
      env.module
      |> Module.get_attribute(:phoenix_routes)
      |> Enum.each(fn route = %{path: path} ->
        unlocalised_path =
          case Regex.replace(~r/\/:locale/, path, "") do
            "" -> "/"
            path -> path
          end

        if unlocalised_path != path do
          Module.put_attribute(env.module, :phoenix_routes, %{
            route
            | path: unlocalised_path
          })
        end
      end)

    nil
  end
end
