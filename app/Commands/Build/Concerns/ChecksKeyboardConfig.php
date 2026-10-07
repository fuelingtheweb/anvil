<?php

namespace App\Commands\Build\Concerns;

use App\Models\Simlayer;

/**
 * The builds refuse a config with problems (`Simlayer::check`): nothing is
 * written, so Keys, Karabiner and Hammerspoon keep the last good one.
 */
trait ChecksKeyboardConfig
{
    private function configIsSound(array $layers): bool
    {
        $problems = Simlayer::check($layers);

        foreach ($problems as $problem) {
            $this->error($problem);
        }

        if ($problems !== []) {
            $this->error('Not built: fix config/simlayers.yml or config/apps.yml first.');
        }

        return $problems === [];
    }
}
