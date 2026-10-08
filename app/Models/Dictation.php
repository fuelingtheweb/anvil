<?php

namespace App\Models;

use Symfony\Component\Yaml\Yaml;

/**
 * Keys' dictation, from config/dictation.yml: the modifier that dictates
 * when held on its own, the names spelled your way, and the local model
 * that tidies up what was said. Keys only: Karabiner has no dictation, and
 * Keys before 0.8.0 ignores it.
 */
class Dictation
{
    public const MODIFIERS = [
        'left_control', 'left_shift', 'left_option', 'left_command',
        'right_control', 'right_shift', 'right_option', 'right_command',
    ];

    public function __construct(private array $config) {}

    public static function load(): ?self
    {
        $path = anvil_config('dictation');

        return is_file($path) ? new self(Yaml::parseFile($path) ?? []) : null;
    }

    /** What's wrong with it: the build refuses to write keys.json then. */
    public function check(): array
    {
        $problems = [];
        $key = $this->config['key'] ?? null;
        if ($key !== null && ! in_array($key, self::MODIFIERS, true)) {
            $problems[] = "dictation: “{$key}” isn't a modifier key (right_option, say)";
        }
        foreach ($this->config['words'] ?? [] as $word) {
            if (! is_string($word) || trim($word) === '') {
                $problems[] = 'dictation: words are names, one a line (' . json_encode($word) . ')';
            }
        }
        $model = $this->config['model'] ?? null;
        if ($model !== null && (! is_string($model) || trim($model) === '')) {
            $problems[] = 'dictation: the model is an Ollama name (gemma4:12b-mlx, say)';
        }

        return $problems;
    }

    /** keys.json's `dictation`. */
    public function toKeys(): object
    {
        return (object) array_filter([
            'key' => $this->config['key'] ?? null,
            'words' => array_values($this->config['words'] ?? []),
            'model' => $this->config['model'] ?? null,
        ], fn ($value) => $value !== null && $value !== []);
    }
}
