[![Hex.pm](https://img.shields.io/hexpm/v/plug.svg)](https://hex.pm/packages/alternate)

------------------------------------

# Alternate


A library to serve your Phoenix app in different locales.

## Installation

The package can be installed as:

Add `alternate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:alternate, "~> 0.1.0"}]
end
```

Ensure `alternate` is configured in `config/config.exs`:

```elixir
config :alternate,
    locales: %{
        "en-GB" => %{ path_prefix: "gb" },
        "en-US" => %{ path_prefix: "us" }
    },
    locale_assign_key: :locale,
    gettext_module: YourAppModule.Gettext
```

* `locales` this is a map of the locales you want to support, the key will also be used as the name for your Gettext locale.
    * `path_prefix` is the prefix that will be used in your urls, for example: `http://example.com/gb` will load the `en-GB` locale.
* `locale_assign_key` is the key that will be used to store the loaded locale in the `assigns`
* `gettext_module` is the Gettext module to use, it will most probably be `{YourAppModule}.Gettext`

## Router

You'll need to import `Alternate` to your router(s), it is recommended that you do so in the `def router do` section in `web/web.ex`:

```elixir
import Alternate
```

this will let you be able to use the `localize` macro in your routes like this:

```elixir
localize get "/", PageController, :index
```

if we run `mix phoenix.routes` we'll see that it created all the routes for our defined locales:

```bash
$ mix phoenix.routes
page_path  GET  /gb  AlternateExample.PageController [action: :index, locale: "en-GB"]
page_path  GET  /us  AlternateExample.PageController [action: :index, locale: "en-US"]
```

Now all that's left to do is to add Alternate's plug into your pipeline, so that it can set the appropiate locale based on the requested path:

```elixir
plug Alternate.Plug
```

Now when you load `http://exmple.com/gb` the `:locale` assign will be equal to `"en-GB"`, and your Gettext locale will be set to `"en-GB"` automatically.

If we want to specify different text routes for different locales we can do it like this:

```elixir
localize get "/start", PageController, :index, translations: %{
  "es-ES" => "/empezar"
}
```

The locales that you don't define in the `translations` map will use the `/start` route to match.

## Controller

We'll need to add an extra `init/1` function in or controllers so that they can support localised actions, you can add this to the `controller` section of your `web/web.ex`.

```elixir
use Alternate.Controller
```

## Route helpers

To generate localized routes we'll need to add this:

```elixir
import Alternate.Helpers
```

to our `controller` and `view` sections of our `web/web.ex`

now similarly to the routing, we can use `localize` to generate translated paths and urls:

```elixir
localize page_path(conn, :index)
```
