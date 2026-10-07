<?php

namespace App\Models;

/**
 * What Hammerspoon (dotfiles/.hammerspoon) can do for a key, read from its
 * Lua, so the build can refuse a key it would drop: the modes KarabinerHandler
 * loads (`md[mode]`, from its `lookup` and Modes/<mode>.lua) and the events
 * init.lua's `urlEvents` registers (`hs:` actions; Keys reaches only those).
 */
class Hammerspoon
{
    private static ?array $modes = null;

    private static ?array $events = null;

    public static function path(string $path = ''): string
    {
        return base_path('dotfiles/.hammerspoon' . ($path === '' ? '' : "/{$path}"));
    }

    /** Other modes and events instead of the Lua's (tests); null goes back to the Lua. */
    public static function use(?array $modes, ?array $events = null): void
    {
        static::$modes = $modes;
        static::$events = $events;
    }

    /** The modes a key can go to: named in KarabinerHandler's lookup, with a Modes/<mode>.lua. */
    public static function modes(): array
    {
        if (static::$modes !== null) {
            return static::$modes;
        }

        $lua = @file_get_contents(static::path('Spoons/KarabinerHandler.spoon/init.lua')) ?: '';
        $lookup = preg_match('/KarabinerHandler\.lookup\s*=\s*\{(.*?)\n\}/s', $lua, $match) ? $match[1] : '';
        preg_match_all("/=\s*'([A-Za-z]+)'/", $lookup, $names);

        return static::$modes = collect($names[1])
            ->unique()
            ->filter(fn ($mode) => is_file(static::path("Modes/{$mode}.lua")))
            ->values()
            ->all();
    }

    /** The events `hs:` can name: init.lua's urlEvents. */
    public static function events(): array
    {
        if (static::$events !== null) {
            return static::$events;
        }

        $lua = @file_get_contents(static::path('init.lua')) ?: '';
        $table = preg_match('/local urlEvents\s*=\s*\{(.*?)\n\}/s', $lua, $match) ? $match[1] : '';
        preg_match_all("/\[\s*'([^']+)'\s*\]\s*=/", $table, $names);

        return static::$events = $names[1];
    }

    public static function hasMode(string $mode): bool
    {
        return in_array($mode, static::modes(), true);
    }

    public static function hasEvent(string $event): bool
    {
        return in_array($event, static::events(), true);
    }
}
