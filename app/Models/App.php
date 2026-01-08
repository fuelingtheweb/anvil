<?php

namespace App\Models;

class App
{
    public static $apps = [
        'alfred' => 'com.runningwithcrayons.Alfred',
        'anybox' => 'cc.anybox.Anybox',
        'busycal' => 'com.busymac.busycal-setapp',
        'chrome' => 'com.google.Chrome',
        'discord' => 'com.hnc.Discord',
        'fastmail' => 'com.fastmail.mac.Fastmail',
        'finder' => 'com.apple.finder',
        'obsidian' => 'md.obsidian',
        'preview' => 'com.apple.Preview',
        'ray' => 'be.spatie.ray',
        'raycast' => 'com.raycast.macos',
        'sidenotes' => 'com.apptorium.SideNotes-setapp',
        'slack' => 'com.tinyspeck.slackmacgap',
        'spotify' => 'com.spotify.client',
        'tableplus' => 'com.tinyapp.TablePlus-setapp',
        'tinkerwell' => 'de.beyondco.tinkerwell',
        'vivaldi' => 'com.vivaldi.Vivaldi',
        'vscode' => 'com.microsoft.VSCode',
        'cursor' => 'com.todesktop.230313mzl4w4u92',
        'warp' => 'dev.warp.Warp-Stable',
        'zoom' => 'us.zoom.xos',
        'teams' => 'com.microsoft.teams2',
        'outlook' => 'com.microsoft.Outlook',
    ];

    public static $aliases = [
        'calendar' => 'busycal',
        'code' => 'vscode',
    ];

    public static $groups = [
        'browser' => ['chrome', 'vivaldi'],
        'chat' => ['discord', 'slack'],
        'ide' => ['code', 'cursor'],
        'quickfind' => ['alfred', 'raycast'],
        'terminal' => ['warp'],
        'mail' => ['fastmail', 'outlook'],
    ];

    public static function getDefinitions()
    {
        return collect([...static::$apps, ...static::$aliases, ...static::$groups])
            ->map(fn ($bundles, $name) => static::definition($name, $bundles))
            ->implode("\n");
    }

    public static function definition($name, $bundles)
    {
        return str('$indent:$name [$bundles]')
            ->replace('$indent', indent(2))
            ->replace('$name', $name)
            ->replace(
                '$bundles',
                collect($bundles)
                    ->map(fn ($value) => '"' . (static::$apps[static::$aliases[$value] ?? null] ?? static::$apps[$value] ?? $value) . '"')
                    ->implode(' '),
            )
            ->value();
    }
}
