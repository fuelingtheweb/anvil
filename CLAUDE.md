# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Anvil is a personal macOS dev-environment repo. Its core is a **Laravel Zero CLI app** (the `artisan` binary) that *compiles* hand-written YAML into generated config files. Around that it ships zsh aliases (`aliases/`), dotfiles (`dotfiles/`), shell options (`options/`), helper scripts (`bin/`), and a macOS bootstrap (`CleanInstall/`).

The things the CLI compiles:
1. `config/simlayers.yml` → `karabiner/karabiner.edn` — consumed by [Goku](https://github.com/yqrashawn/GokuRakuJoudo), which in turn compiles to Karabiner-Elements JSON.
2. `config/simlayers.yml` → `keys/keys.json` — the same layers as data, for Keys (`~/Dev/tidypoint-apps/keys`, com.tidypoint.Keys), the native app replacing Karabiner + Goku. `~/.config/keys/keys.json` links here; Keys reloads it when it changes.
3. `config/apps.yml` → `dotfiles/.hammerspoon/config/apps.lua` — the one app registry (names → bundle ids, aliases, groups): simlayers.yml's per-app rules use its names, and Hammerspoon's `App.bundles` (each name a Lua global) is built from it. Also karabiner.edn's `:applications` and keys.json's `apps`.
4. `config/aliases/laravel.yml` → `aliases/laravel.sh` — a generated zsh aliases file.

Generated outputs (`karabiner/karabiner.edn`, `keys/keys.json`, `dotfiles/.hammerspoon/config/apps.lua`, `aliases/laravel.sh`) are committed. **Edit the YAML sources, not the generated files** — regenerate via the build commands below.

## Commands

```bash
php artisan build:karabiner   # compile config/simlayers.yml -> karabiner/karabiner.edn
php artisan build:keys        # compile config/simlayers.yml -> keys/keys.json (Keys)
php artisan build:hammerspoon # compile config/apps.yml -> dotfiles/.hammerspoon/config/apps.lua
php artisan build:aliases     # compile config/aliases/laravel.yml -> aliases/laravel.sh

vendor/bin/pest               # run tests (Pest 3; tests/Unit/KeyboardConfigTest.php)
vendor/bin/pest --filter=Name # run a single test by name
vendor/bin/pint               # format (Laravel preset + custom rules in pint.json)
```

Shell wrappers (defined in `aliases/misc.sh`, available once the shell is sourced):
- `kb` = `build:karabiner`, `build:keys`, `build:hammerspoon`, then run `goku`
- `keys-on` / `keys-off` = select Karabiner's empty "Off" profile (Keys takes the keyboard) / its "Default" profile (Karabiner takes it back); Keys' menu bar icon does the same
- `ab` = `build:aliases` then re-source the alias index
- `anb` = `kb && ab` (the full rebuild; also the `Build` process in `solo.yml`)

PHP is provided via Laravel Herd. Requires PHP ^8.2.

## Architecture

`app/Commands/Build/{Karabiner,Aliases}.php` are thin: each parses a YAML file via `anvil_config()`, maps rows through a model in `app/Models/`, and writes the output. All real logic lives in the models.

`app/Support/helpers.php` (autoloaded globally): `anvil_config('aliases.laravel')` resolves dotted keys to `config/aliases/laravel.yml`; `template_path()` → `src/templates/`; `indent($n)` → 4-space indentation used throughout EDN/shell generation.

### Karabiner generation (the complex part)
`src/templates/karabiner.edn` is a template with `$simlayers`, `$templates`, `$applications`, `$rulesets` placeholders. `Karabiner` command fills them from:

- **`App\Models\Simlayer`** — one per top-level key in `simlayers.yml`. The key is `"<trigger> : <Label>"` (e.g. `'caps : Hyper'`); `caps` is special-cased to `HyperMode`. `$keyMap` translates shorthand keys (`esc`, `qt`, `prd`, `rtn`, symbols) to Karabiner names. `parseAction()` is a mini-DSL — understand it before touching simlayer rules:
  - `c.k` / `sc.p` — dotted prefixes are modifiers (single letters uppercased and `!`-prefixed: `c`→command, `s`→shift, etc.), so `sc.p` = shift+command+p.
  - `foo ++ bar` — sequential chords run in order.
  - `"text"` — quoted strings are typed out key-by-key.
  - `script: arg, arg` — invokes a template from `Action` (e.g. `alfred:`, `app:`); `app:` values are resolved through the `App` bundle registry.
  - bare `url://...` — becomes `:open`.
  - A rule value can be a map keyed by app/group name (e.g. `ide:`, `default:`) to make the same key behave differently per active app.
- **`App\Models\App`** — the registry, read from `config/apps.yml`: `apps` (name → bundle id), `aliases` (another name for an app or a group) and `groups` (e.g. `ide` → code+cursor). `resolve()` follows aliases and groups to bundle ids; emits the `:applications` block, keys.json's `apps` and Hammerspoon's `config/apps.lua` (`toLua()`: an app is its bundle id, a group its names). Names must be Lua identifiers and mustn't shadow Hammerspoon's own globals (Ray is `rayapp`: `ray()` is its debug function); `problems()` checks.
- **`App\Models\Action`** — fixed action templates (`alfred`, `open`, `app`, `hs`, `hsk`, `menu`). Emits the `:templates` block.

### Keys generation
`Build\Keys` writes `keys/keys.json` from the same `Simlayer` models: `Simlayer::toKeys()` / `parseKeysAction()` mirror `rules()` / `parseAction()` (keep them in step), producing per layer `{label, trigger, hyper?, keys: {karabiner_key_name: [{app?, actions}]}}`. A key's rules are tried in order, first app match wins (Karabiner's order); actions are `{key, modifiers}`, `{open}`, `{app}` (bundle id), `{alfred: [...]}`, `{hammerspoon: {mode, key}}` / `{hammerspoon: {event}}`, `{menu: {process, item, menu}}`, `{pointer}`, `{dictate: true}` (`dictate`: Keys 0.3.0+ listens while the key is held and types what was said; Karabiner's EDN leaves the key out, so there it types as before; no layer key uses it since 2026-10-08). `apps` is `App::bundles()` (groups expanded). Timings and the fn rule mirror `src/templates/karabiner.edn`. `config/dictation.yml` (`App\Models\Dictation`, checked before anything is written) becomes keys.json's `dictation`: `key`, the modifier that dictates when held on its own (right ⌥; Keys 0.8.0+), `words`, names spelled your way (Keys fixes them when heard as two or three words, and hands the list to the tidy-up), and `model`, the Ollama model that tidies up what was said. Each layer also gets `labels` (Karabiner key name → the comment on that key's line in the YAML, read by `Build\Keys::comments` since the parser drops comments; a quoted name like `# 'moveToTopOfPage'` becomes words) for Keys' layer popup; Karabiner's EDN has no use for them. A layer key with a blank (or null) value is **free**: not in the layer, so it types as itself (until 2026-10-07 a blank went to Hammerspoon, which dropped 43 such keys: five layers have no mode). `hammerspoon` sends a key to the layer's mode (`handle-karabiner`, in the EDN and in keys.json alike; also per app). A layer may be `- all` (or all-left / all-right) followed by a map of overrides (`getOverrides()`; a blank override is free), and `focus: <app, alias or group>` makes Keys bring the app forward itself (`{focus: {apps, hammerspoon}}`, Keys 0.3.0+; the Open layer's app keys, Phase 2), with the layer's Hammerspoon mode as its fallback for window hints; Karabiner's EDN still sends those keys to Hammerspoon.

**The build refuses a config that goes nowhere** (`Simlayer::check`, via `Build\Concerns\ChecksKeyboardConfig`, before anything is written): a key Keys doesn't know (`Simlayer::KEY_NAMES`, Keys' KeyCodes names), an app or `focus:`/`app:` target not in apps.yml, an unknown modifier, `hammerspoon` or `- all` for a mode Hammerspoon doesn't load (`App\Models\Hammerspoon` reads KarabinerHandler's lookup and Modes/*.lua), or an `hs:` event not in init.lua's `urlEvents` (Keys reaches only those over its port: `CodeSnippets.null`, bound in its own file, was silently dead under Keys until added there). `tests/Unit/KeyboardConfigTest.php` covers the rules and runs the check on the real files.

Keys reaches Hammerspoon over a CFMessagePort, `com.tidypoint.Keys.hammerspoon`, opened by `KarabinerHandler.spoon` (`hs.ipc.localPort`; message 1 = `mode<TAB>key`, 2 = a URL event name from init.lua's `urlEvents`), instead of `open -g hammerspoon://…` per key. Karabiner still uses the URLs.

### Alias generation
**`App\Models\Alias`** recursively turns `config/aliases/laravel.yml` into shell code: scalars → `alias k="v"`, list values → a shell function body, nested maps → recursion. A `group.<prefix>` key prepends `<prefix>` to every alias in that group (used to namespace e.g. artisan subcommands).

## Conventions & gotchas

- Models build output by string substitution (`str(...)->replace('$x', ...)`), not Blade. Match the existing `$placeholder` + `indent()` style.
- `aliases/index.sh` sources every `aliases/*.sh`; `aliases/laravel.sh` is generated, the rest are hand-written.
- `custom` and `aliases/custom` are symlinks into a private Dropbox folder and will be **absent on other machines** — code that reads them must degrade gracefully (as `aliases/index.sh` already does with an existence check).
- `config('app.karabiner_path')` exists (from `KARABINER_PATH` in `.env`) but `build:karabiner` currently hardcodes its output to `base_path('karabiner/karabiner.edn')`.
- `box.json` exists for building a PHAR with [Box](https://github.com/box-project/box), but Box is not a project dependency — install it separately if packaging is needed.
