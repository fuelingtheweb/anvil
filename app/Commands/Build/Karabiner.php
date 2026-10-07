<?php

namespace App\Commands\Build;

use App\Commands\Build\Concerns\ChecksKeyboardConfig;
use App\Models\Action;
use App\Models\App;
use App\Models\Simlayer;
use LaravelZero\Framework\Commands\Command;
use Symfony\Component\Yaml\Yaml;

class Karabiner extends Command
{
    use ChecksKeyboardConfig;

    protected $signature = 'build:karabiner';

    protected $description = 'Build Karabiner Config';

    public function handle()
    {
        $this->info('Building Karabiner Config...');

        $layers = Yaml::parse(file_get_contents(anvil_config('simlayers')));

        if (! $this->configIsSound($layers)) {
            return self::FAILURE;
        }

        $simlayers = collect($layers)
            ->map(fn ($rules, $index) => (new Simlayer($index, $rules))->toArray());

        file_put_contents(
            base_path('karabiner/karabiner.edn'),
            str(file_get_contents(template_path('karabiner.edn')))
                ->replace(
                    '$simlayers',
                    $simlayers
                        ->filter(fn ($simlayer) => $simlayer['name'] !== 'HyperMode')
                        ->pluck('definition')
                        ->implode("\n"),
                )
                ->replace('$templates', Action::getTemplateDefinitions())
                ->replace('$applications', App::getDefinitions())
                ->replace('$rulesets', $simlayers->pluck('rules')->implode("\n"))
                ->value(),
        );

        $this->info('Finished!');
    }
}
