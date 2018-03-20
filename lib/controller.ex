defmodule Alternate.Controller do
  defmacro __using__(_) do
    quote do
      def init(action: action, locale: _) do
        action
      end

      def init(opts) do
        opts
      end
    end
  end
end
