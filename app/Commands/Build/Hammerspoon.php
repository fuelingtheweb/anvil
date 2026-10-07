<?php

namespace App\Commands\Build;

use App\Models\App;
use App\Models\Hammerspoon as HammerspoonConfig;
use LaravelZero\Framework\Commands\Command;

class Hammerspoon extends Command
{
    protected $signature = 'build:hammerspoon';

    protected $description = "Build Hammerspoon's app registry (dotfiles/.hammerspoon/config/apps.lua) from config/apps.yml";

    public function handle()
    {
        $this->info('Building Hammerspoon Config...');

        if ($problems = App::problems()) {
            foreach ($problems as $problem) {
                $this->error($problem);
            }

            return self::FAILURE;
        }

        // Hammerspoon reloads at any .lua written: only when it changed.
        $path = HammerspoonConfig::path('config/apps.lua');
        $lua = App::toLua();

        if (! is_file($path) || file_get_contents($path) !== $lua) {
            file_put_contents($path, $lua);
        }

        $this->info('Finished!');
    }
}
