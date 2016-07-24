defmodule Polygot.Controller do

  defmacro __using__(_) do
    quote do
      def init([ action: action ]) do
        action
      end
    end
  end

end
