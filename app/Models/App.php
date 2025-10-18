<?php

namespace App\Models;

class App
{
    public static $apps = [
        'alfred' => 'com.runningwithcrayons.Alfred',
        'anybox' => 'cc.anybox.Anybox',
        'arc' => 'company.thebrowser.Browser',
        'busycal' => 'com.busymac.busycal-setapp',
        'chrome' => 'com.google.Chrome',
        'discord' => 'com.hnc.Discord',
        'finder' => 'com.apple.finder',
        'mimestream' => 'com.mimestream.Mimestream',
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
        'warp' => 'dev.warp.Warp-Stable',
        'zen' => 'app.zen-browser.zen',
        'zoom' => 'us.zoom.xos',
        'teams' => 'com.microsoft.teams2',
        'outlook' => 'com.microsoft.Outlook',
    ];

    public static $aliases = [
        'calendar' => 'busycal',
        'code' => 'vscode',
        'mail' => 'mimestream',
    ];

    public static $groups = [
        'browser' => ['arc', 'chrome', 'vivaldi', 'zen'],
        'chat' => ['discord', 'slack'],
        'ide' => ['code'],
        'quickfind' => ['alfred', 'raycast'],
        'terminal' => ['warp'],
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
