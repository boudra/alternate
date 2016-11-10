use Mix.Config

config :polygot,
  locales: %{},
  locale_assign_key: :polygot_locale,
  gettext_module: Polygot.Gettext,
  gettext_domain: "default"
