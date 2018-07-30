use Mix.Config

config :alternate,
  locales: %{},
  locale_assign_key: :alternate_locale,
  default_fallback_locale: "default",
  session_assign_key: nil,
  gettext_module: Alternate.Gettext,
  gettext_domain: "default"
