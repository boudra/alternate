defmodule Alternate.Mixfile do
  use Mix.Project

  def project do
    [app: :alternate,
     version: "0.1.5",
     elixir: "~> 1.3",
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     name: "Alternate",
     docs: [extras: ["README.md"], main: "Alternate"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps,
     description: """
     A library to serve your Phoenix app in differnt locales
     """]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.1"},
      {:gettext, "~> 0.9"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [ maintainers: ["Mohamed Boudra"],
      licenses: ["Apache License 2.0"],
      links: %{ "Github" => "https://github.com/boudra/alternate" },
      files: ~w(lib priv web README.md mix.exs LICENSE.md)]
  end
end
