<?php

namespace App\Models;

use Illuminate\Support\Collection;
use InvalidArgumentException;
use Symfony\Component\Yaml\Yaml;

/**
 * The app registry, config/apps.yml: apps (name → bundle id), aliases (other
 * names for an app or a group) and groups (names for several apps). The one
 * list Karabiner's EDN, Keys' JSON and Hammerspoon's Lua are built from.
 */
class App
{
    private static ?array $config = null;

    /** Lua words a name can't be (it becomes a Lua global). */
    private const LUA_KEYWORDS = [
        'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if',
        'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while',
    ];

    public static function config(): array
    {
        return static::$config ??= static::normalized(Yaml::parseFile(anvil_config('apps')));
    }

    /** Another registry instead of config/apps.yml (tests); null goes back to the file. */
    public static function use(?array $config): void
    {
        static::$config = $config === null ? null : static::normalized($config);
    }

    private static function normalized(?array $config): array
    {
        return ($config ?? []) + ['apps' => [], 'aliases' => [], 'groups' => []];
    }

    public static function apps(): array
    {
        return static::config()['apps'] ?? [];
    }

    public static function aliases(): array
    {
        return static::config()['aliases'] ?? [];
    }

    public static function groups(): array
    {
        return static::config()['groups'] ?? [];
    }

    /** Every name: apps, then aliases, then groups. */
    public static function names(): array
    {
        return [...array_keys(static::apps()), ...array_keys(static::aliases()), ...array_keys(static::groups())];
    }

    public static function has(string $name): bool
    {
        return in_array($name, static::names(), true);
    }

    /** The bundle ids a name stands for: an app's, its alias's, a group's members'. */
    public static function resolve(string $name, array $seen = []): array
    {
        if (in_array($name, $seen, true)) {
            throw new InvalidArgumentException('Apps go round in a circle: ' . implode(' → ', [...$seen, $name]));
        }
        $seen[] = $name;

        if (isset(static::apps()[$name])) {
            return [static::apps()[$name]];
        }

        if (isset(static::aliases()[$name])) {
            return static::resolve(static::aliases()[$name], $seen);
        }

        if (isset(static::groups()[$name])) {
            return collect(static::groups()[$name])
                ->flatMap(fn ($member) => static::resolve($member, $seen))
                ->unique()
                ->values()
                ->all();
        }

        throw new InvalidArgumentException("Unknown app: {$name}");
    }

    /** One app's bundle id, by its name or an alias (`app:`); null for a group or an unknown name. */
    public static function bundle(string $name): ?string
    {
        while (isset(static::aliases()[$name])) {
            $name = static::aliases()[$name];
        }

        return static::apps()[$name] ?? null;
    }

    /** Every name with its bundle ids, for Keys (the names :applications gets). */
    public static function bundles(): Collection
    {
        return collect(static::names())->mapWithKeys(fn ($name) => [$name => static::resolve($name)]);
    }

    public static function getDefinitions()
    {
        return static::bundles()
            ->map(fn ($bundles, $name) => static::definition($name, $bundles))
            ->implode("\n");
    }

    public static function definition($name, $bundles)
    {
        return str('$indent:$name [$bundles]')
            ->replace('$indent', indent(2))
            ->replace('$name', $name)
            ->replace('$bundles', collect($bundles)->map(fn ($bundle) => '"' . $bundle . '"')->implode(' '))
            ->value();
    }

    /**
     * What's wrong with the registry: names used twice, ones Lua can't take
     * as globals, aliases and group members that point nowhere.
     */
    public static function problems(): array
    {
        $problems = [];

        foreach (collect(static::names())->countBy()->filter(fn ($count) => $count > 1)->keys() as $name) {
            $problems[] = "apps.yml: “{$name}” is named twice";
        }

        foreach (static::names() as $name) {
            if (! preg_match('/^[A-Za-z_][A-Za-z0-9_]*$/', $name) || in_array($name, static::LUA_KEYWORDS, true)) {
                $problems[] = "apps.yml: “{$name}” can't be a Lua global (Hammerspoon's)";
            }
        }

        foreach (static::names() as $name) {
            try {
                static::resolve($name);
            } catch (InvalidArgumentException $e) {
                $problems[] = "apps.yml: {$name}: {$e->getMessage()}";
            }
        }

        return array_values(array_unique($problems));
    }

    /**
     * Hammerspoon's App.bundles (dotfiles/.hammerspoon/config/apps.lua): an
     * app, or an alias of one, is its bundle id; a group, or an alias of one,
     * its names (App.fromAlias turns them into bundle ids).
     */
    public static function toLua(): string
    {
        $lines = collect(static::names())->map(function ($name) {
            $target = $name;
            while (isset(static::aliases()[$target])) {
                $target = static::aliases()[$target];
            }

            $value = isset(static::groups()[$target])
                ? '{ ' . collect(static::groups()[$target])->map(fn ($member) => "'{$member}'")->implode(', ') . ' }'
                : "'" . static::apps()[$target] . "'";

            return "    {$name} = {$value},";
        });

        return implode("\n", [
            '-- Generated by `php artisan build:hammerspoon` from config/apps.yml: edit that, not this.',
            '-- App.bundles: an app\'s bundle id, or a group\'s names. Each name becomes a global.',
            'return {',
            ...$lines,
            '}',
        ]) . "\n";
    }
}
