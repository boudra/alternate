use Mix.Config

config :alternate,
  locales: %{},
  locale_assign_key: :alternate_locale,
  gettext_module: Alternate.Gettext,
  gettext_domain: "default"
