# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Anvil is a personal macOS dev-environment repo. Its core is a **Laravel Zero CLI app** (the `artisan` binary) that *compiles* hand-written YAML into generated config files. Around that it ships zsh aliases (`aliases/`), dotfiles (`dotfiles/`), shell options (`options/`), helper scripts (`bin/`), and a macOS bootstrap (`CleanInstall/`).

The two things the CLI compiles:
1. `config/simlayers.yml` → `karabiner/karabiner.edn` — consumed by [Goku](https://github.com/yqrashawn/GokuRakuJoudo), which in turn compiles to Karabiner-Elements JSON.
2. `config/aliases/laravel.yml` → `aliases/laravel.sh` — a generated zsh aliases file.

Generated outputs (`karabiner/karabiner.edn`, `aliases/laravel.sh`) are committed. **Edit the YAML sources, not the generated files** — regenerate via the build commands below.

## Commands

```bash
php artisan build:karabiner   # compile config/simlayers.yml -> karabiner/karabiner.edn
php artisan build:aliases     # compile config/aliases/laravel.yml -> aliases/laravel.sh

vendor/bin/pest               # run tests (Pest 3; no tests exist yet despite phpunit.xml.dist)
vendor/bin/pest --filter=Name # run a single test by name
vendor/bin/pint               # format (Laravel preset + custom rules in pint.json)
```

Shell wrappers (defined in `aliases/misc.sh`, available once the shell is sourced):
- `kb` = `build:karabiner` then run `goku`
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
- **`App\Models\App`** — registry of bundle IDs (`$apps`), name `$aliases`, and `$groups` (e.g. `ide` → code+cursor). Emits the `:applications` block; group/alias names are what simlayer per-app rules reference.
- **`App\Models\Action`** — fixed action templates (`alfred`, `open`, `app`, `hs`, `hsk`, `menu`). Emits the `:templates` block.

### Alias generation
**`App\Models\Alias`** recursively turns `config/aliases/laravel.yml` into shell code: scalars → `alias k="v"`, list values → a shell function body, nested maps → recursion. A `group.<prefix>` key prepends `<prefix>` to every alias in that group (used to namespace e.g. artisan subcommands).

## Conventions & gotchas

- Models build output by string substitution (`str(...)->replace('$x', ...)`), not Blade. Match the existing `$placeholder` + `indent()` style.
- `aliases/index.sh` sources every `aliases/*.sh`; `aliases/laravel.sh` is generated, the rest are hand-written.
- `custom` and `aliases/custom` are symlinks into a private Dropbox folder and will be **absent on other machines** — code that reads them must degrade gracefully (as `aliases/index.sh` already does with an existence check).
- `config('app.karabiner_path')` exists (from `KARABINER_PATH` in `.env`) but `build:karabiner` currently hardcodes its output to `base_path('karabiner/karabiner.edn')`.
- `box.json` exists for building a PHAR with [Box](https://github.com/box-project/box), but Box is not a project dependency — install it separately if packaging is needed.
