<?php

namespace App\Models;

class Alias
{
    public function __construct(
        public $key,
        public $value,
        public $prefix = '',
    ) {
        $this->prefix = $prefix.$this->prefixFromKey($this->key);
    }

    public function toArray()
    {
        $aliases = collect();

        if (is_array($this->value)) {
            if (is_string(collect($this->value)->keys()->first())) {
                foreach ($this->value as $key => $value) {
                    $aliases->push((new Alias($key, $value, $this->prefix))->toArray());
                }
            } else {
                $aliases->push(
                    str('$key () {$newLine$indent$commands$newLine}')
                        ->replace('$key', $this->key)
                        ->replace('$newLine', "\n")
                        ->replace('$indent', indent())
                        ->replace(
                            '$commands',
                            collect($this->value)->implode("\n".indent()),
                        )
                        ->value(),
                );
            }
        } else {
            $aliases->push(
                str('alias $key="$value"')
                    ->replace('$key', $this->key)
                    ->replace('$value', trim("{$this->prefix}{$this->value}"))
                    ->value(),
            );
        }

        return $aliases->flatten()->all();
    }

    private function prefixFromKey($key): string
    {
        $prefix = '';
        $string = str($key);

        if ($string->startsWith('group.')) {
            $prefix = $string
                ->replace('group.', '')
                ->value();

            if (! $string->endsWith(':')) {
                $prefix .= ' ';
            }
        }

        return $prefix;
    }
}
