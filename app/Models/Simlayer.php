<?php

namespace App\Models;

use InvalidArgumentException;

class Simlayer
{
    public $label;
    public $name;
    public $key;
    public $rules;

    private $keyMap = [
        'esc' => 'escape',
        '[' => 'open_bracket',
        ']' => 'close_bracket',
        '\\' => 'backslash',
        'caps' => 'caps_lock',
        ';' => 'semicolon',
        'qt' => 'quote',
        "'" => 'quote',
        'rtn' => 'return_or_enter',
        'ltS' => 'left_shift',
        ',' => 'comma',
        'prd' => 'period',
        '.' => 'period',
        '/' => 'slash',
        'rtS' => 'right_shift',
        'sb' => 'spacebar',
        'lt' => 'left_arrow',
        'rt' => 'right_arrow',
        'up' => 'up_arrow',
        'dn' => 'down_arrow',
        'dlt' => 'delete_or_backspace',
        'cln' => '!Ssemicolon',
        ':' => '!Ssemicolon',
        '+' => '!Sequal_sign',
        '=' => 'equal_sign',
        '-' => 'hyphen',
        ' ' => 'spacebar',
        '>' => '!Speriod',
        '!' => '!S1',
        '@' => '!S2',
        '#' => '!S3',
        '$' => '!S4',
        '%' => '!S5',
        '^' => '!S6',
        '&' => '!S7',
        '*' => '!S8',
        '(' => '!S9',
        ')' => '!S0',
        '|' => '!Sbackslash',
        '_' => '!Shyphen',
        '{' => '!Sopen_bracket',
        '}' => '!Sclose_bracket',
        '`' => 'grave_accent_and_tilde',
        '~' => '!Sgrave_accent_and_tilde',
        '?' => '!Sslash',
    ];

    public function __construct($index, $rules)
    {
        [$key, $label] = array_pad(explode(' : ', $index, 2), 2, '');

        $this->label = $label;
        $this->key = $this->keyMap[$key] ?? $key;
        $this->name = $key === 'caps'
            ? 'HyperMode'
            : "sim_{$this->key}";
        $this->rules = $rules;
    }

    public function toArray()
    {
        return [
            'label' => $this->label,
            'name' => $this->name,
            'key' => $this->key,
            'definition' => $this->definition(),
            'rules' => $this->rules(),
        ];
    }

    public function definition()
    {
        if (empty($this->rules)) {
            return str('$indent; $key')
                ->replace('$indent', indent(2))
                ->replace('$key', $this->key)
                ->value();
        }

        return str('$indent:$name {:key :$key}')
            ->replace('$indent', indent(2))
            ->replace('$name', $this->name)
            ->replace('$key', $this->key)
            ->value();
    }

    public function rules()
    {
        if (empty($this->rules)) {
            return '';
        }

        $template = <<<'EDN'
                {
                    :des "$label"
                    :rules [:$name
                        $rules
                    ]
                }
        EDN;

        return str($template)
            ->replace('$label', $this->label)
            ->replace('$name', $this->name)
            ->replace('$rules', $this->getRules())
            ->value();
    }

    public function getRules()
    {
        $rules = '';

        $overrides = $this->getOverrides();

        foreach ($this->getKeys() as $key) {
            if ($key === $this->key) {
                continue;
            }

            // A key `- all` hands over that does something else (not focus:
            // Karabiner can't, so Hammerspoon's mode still does it there).
            $override = $overrides[$this->keyMap[$key] ?? $key] ?? null;

            // Karabiner can't dictate: the key types as it did without the rule.
            if ($override !== null && $this->isDictate($override)) {
                continue;
            }

            if ($override !== null && ! $this->isFocus($override)) {
                $rules .= str('[:$key [$action] [$conditions]]$newLine$indent')
                    ->replace('$key', $this->keyMap[$key] ?? $key)
                    ->replace('$action', $this->parseAction($override))
                    ->replace('$conditions', $this->getAppCondition('default'))
                    ->replace('$newLine', "\n")
                    ->replace('$indent', indent(4))
                    ->value();

                continue;
            }

            $rules .= str('[:$key [:hsk "$label" "$key"]]$newLine$indent')
                ->replace('$label', $this->label)
                ->replace('$key', $this->keyMap[$key] ?? $key)
                ->replace('$newLine', "\n")
                ->replace('$indent', indent(4))
                ->value();
        }

        foreach ($this->getCustomRules() as $key => $customRules) {
            if ($key === $this->key) {
                continue;
            }

            if ((empty($customRules) && $customRules !== '0') || (is_string($customRules) && $this->isFocus($customRules))) {
                $rules .= str('[:$key [:hsk "$label" "$key"]]$newLine$indent')
                    ->replace('$label', $this->label)
                    ->replace('$key', $this->keyMap[$key] ?? $key)
                    ->replace('$newLine', "\n")
                    ->replace('$indent', indent(4))
                    ->value();

                continue;
            }

            if (is_string($customRules) && $this->isDictate($customRules)) {
                continue;
            }

            if (is_string($customRules)) {
                $rules .= str('[:$key [$action] [$conditions]]$newLine$indent')
                    ->replace('$key', $this->keyMap[$key] ?? $key)
                    ->replace('$action', $this->parseAction($customRules))
                    ->replace('$conditions', $this->getAppCondition('default'))
                    ->replace('$newLine', "\n")
                    ->replace('$indent', indent(4))
                    ->value();

                continue;
            }

            foreach ($customRules as $app => $action) {
                if ($this->isDictate($action)) {
                    continue;
                }

                try {
                    $rules .= str('[:$key [$action] [$conditions]]$newLine$indent')
                        ->replace('$key', $this->keyMap[$key] ?? $key)
                        ->replace('$action', $this->parseAction($action))
                        ->replace('$conditions', $this->getAppCondition($app))
                        ->replace('$newLine', "\n")
                        ->replace('$indent', indent(4))
                        ->value();
                } catch (\Exception $e) {
                    dd('failed?', $app, $action);
                }
            }
        }

        return rtrim($rules);
    }

    public function getCustomRules()
    {
        if (empty($this->rules) || ! empty($this->rules[0])) {
            return [];
        }

        return $this->rules;
    }

    /**
     * After `- all` (or all-left / all-right), a map of the keys that do
     * something else than Hammerspoon's mode: `['all', ['g' => 'focus: vivaldi']]`.
     */
    public function getOverrides()
    {
        $overrides = $this->rules[1] ?? null;

        if (empty($this->rules[0]) || ! is_array($overrides)) {
            return [];
        }

        return collect($overrides)
            ->mapWithKeys(fn ($action, $key) => [$this->keyMap[$key] ?? $key => $action])
            ->all();
    }

    /**
     * `focus: vivaldi`: Keys brings the app forward itself (the Open layer's
     * way); Karabiner still sends the key to Hammerspoon's mode.
     */
    public function isFocus($action)
    {
        return is_string($action) && str_starts_with(trim($action), 'focus:');
    }

    /**
     * `dictate`: Keys listens while the key is held and types what was said
     * (a tap: hands-free until the next press). Keys only; Karabiner's EDN
     * leaves the key out.
     */
    public function isDictate($action)
    {
        return is_string($action) && trim($action) === 'dictate';
    }

    /**
     * A key's actions for Keys: focus (with this layer's Hammerspoon mode as
     * its fallback, for window hints), else parseKeysAction().
     */
    public function keysActionFor($key, $action)
    {
        if (! $this->isFocus($action)) {
            return $this->parseKeysAction($action);
        }

        $name = trim(str($action)->after(':')->value());
        $apps = App::bundles()->get($name) ?? [$name];

        return [['focus' => [
            'apps' => array_values($apps),
            'hammerspoon' => $this->hammerspoonAction($key)['hammerspoon'],
        ]]];
    }

    public function parseAction($action)
    {
        $action = str($action);

        if ($action->test('/^[a-zA-Z]+:\/\/.+$/')) {
            return ':open "' . $action->value() . '"';
        }

        if ($action->contains(' ++ ')) {
            return $action
                ->explode(' ++ ')
                ->map(fn ($part) => $this->parseAction($part))
                ->implode(' ');
        }

        if ($action->startsWith('"') && $action->endsWith('"')) {
            return $action
                ->trim('"')
                ->split(1)
                ->map(fn ($part) => ':' . ($this->keyMap[$part] ?? $part))
                ->implode(' ');
        }

        if ($action->contains(':')) {
            $script = $action->before(':')->trim()->value();
            $value = $action
                ->after(':')
                ->trim()
                ->explode(', ')
                ->map(
                    fn ($value) => $script === 'app'
                        ? '"' . (App::$apps[App::$aliases[$value] ?? null] ?? App::$apps[$value] ?? $value) . '"'
                        : '"' . $value . '"',
                )
                ->implode(' ');

            return ":{$script} {$value}";
        }

        return $action->explode(' ')
            ->map(function ($part) {
                $modifier = null;
                $key = $part;

                $part = str($part);

                if ($part->contains('.')) {
                    $modifier = $part->before('.')->value();
                    $key = $part->after('.')->value();
                }

                if ($modifier) {
                    $modifier = '!' . strtoupper($modifier);
                }

                $key = $this->keyMap[$key] ?? $key;

                return $modifier
                    ? ":{$modifier}{$key}"
                    : ":{$key}";
            })
            ->implode(' ');
    }

    /**
     * The layer for Keys (keys/keys.json): the same rules as rules(), as data.
     * Each key maps to its rules in order (the first whose app matches wins),
     * and a key with no rules for the front app isn't part of the layer.
     */
    public function toKeys()
    {
        if (empty($this->rules)) {
            return null;
        }

        $keys = [];
        $overrides = $this->getOverrides();

        foreach ($this->getKeys() as $key) {
            if ($key === $this->key) {
                continue;
            }

            $name = $this->keyMap[$key] ?? $key;
            $override = $overrides[$name] ?? null;

            $keys[$name][] = ['actions' => $override === null
                ? [$this->hammerspoonAction($key)]
                : $this->keysActionFor($key, $override)];
        }

        foreach ($this->getCustomRules() as $key => $customRules) {
            $name = $this->keyMap[$key] ?? $key;

            if ($key === $this->key) {
                continue;
            }

            if (empty($customRules) && $customRules !== '0') {
                $keys[$name][] = ['actions' => [$this->hammerspoonAction($key)]];

                continue;
            }

            if (is_string($customRules)) {
                $keys[$name][] = ['actions' => $this->keysActionFor($key, $customRules)];

                continue;
            }

            foreach ($customRules as $app => $action) {
                $keys[$name][] = array_filter([
                    'app' => $app === 'default' ? null : $app,
                    'actions' => $this->parseKeysAction($action),
                ], fn ($value) => $value !== null);
            }
        }

        return array_filter([
            'label' => $this->label,
            'trigger' => $this->key,
            'hyper' => $this->name === 'HyperMode' ? true : null,
            'keys' => (object) $keys,
        ], fn ($value) => $value !== null);
    }

    public function hammerspoonAction($key)
    {
        return ['hammerspoon' => ['mode' => $this->label, 'key' => $this->keyMap[$key] ?? $key]];
    }

    /**
     * parseAction(), as a list of actions instead of EDN.
     */
    public function parseKeysAction($action)
    {
        if ($this->isDictate($action)) {
            return [['dictate' => true]];
        }

        $action = str($action);

        if ($action->test('/^[a-zA-Z]+:\/\/.+$/')) {
            return [['open' => $action->value()]];
        }

        if ($action->contains(' ++ ')) {
            return $action
                ->explode(' ++ ')
                ->flatMap(fn ($part) => $this->parseKeysAction($part))
                ->all();
        }

        if ($action->startsWith('"') && $action->endsWith('"')) {
            return $action
                ->trim('"')
                ->split(1)
                ->map(fn ($character) => ctype_upper($character)
                    ? $this->keyStroke('s', strtolower($character))
                    : $this->keyStroke(null, $character))
                ->all();
        }

        if ($action->contains(':')) {
            $script = $action->before(':')->trim()->value();
            $values = $action->after(':')->trim()->explode(', ')->all();

            return [match ($script) {
                'app' => ['app' => App::$apps[App::$aliases[$values[0]] ?? null] ?? App::$apps[$values[0]] ?? $values[0]],
                'open' => ['open' => $values[0]],
                'alfred' => ['alfred' => $values],
                'hs' => ['hammerspoon' => ['event' => $values[0]]],
                'hsk' => ['hammerspoon' => ['mode' => $values[0], 'key' => $values[1] ?? '']],
                'menu' => ['menu' => ['process' => $values[0], 'item' => $values[1], 'menu' => $values[2]]],
                default => throw new InvalidArgumentException("Unknown action: {$script}"),
            }];
        }

        return $action->explode(' ')
            ->map(function ($part) {
                $part = str($part);

                return $part->contains('.')
                    ? $this->keyStroke($part->before('.')->value(), $part->after('.')->value())
                    : $this->keyStroke(null, $part->value());
            })
            ->all();
    }

    /**
     * One key with its modifiers. `$modifiers` is the DSL's letters (`sc`);
     * a $keyMap value may carry Goku modifiers of its own (`!Ssemicolon`).
     */
    public function keyStroke($modifiers, $key)
    {
        $letters = str_split(strtoupper($modifiers ?? ''), 1);
        $letters = array_filter($letters, fn ($letter) => $letter !== '');
        $key = $this->keyMap[$key] ?? $key;

        if (preg_match('/^!([A-Z!]+?)([a-z0-9_]+)$/', $key, $matches)) {
            $letters = [...$letters, ...str_split($matches[1])];
            $key = $matches[2];
        }

        $names = [
            'C' => 'command', 'Q' => 'command',
            'S' => 'shift', 'R' => 'shift',
            'O' => 'option', 'E' => 'option',
            'T' => 'control', 'W' => 'control',
            'F' => 'fn',
        ];

        $modifiers = collect($letters)
            ->flatMap(fn ($letter) => $letter === '!'
                ? ['command', 'shift', 'option', 'control']
                : [$names[$letter] ?? throw new InvalidArgumentException("Unknown modifier: {$letter}")])
            ->unique()
            ->values()
            ->all();

        return array_filter(
            ['key' => $key, 'modifiers' => $modifiers ?: null],
            fn ($value) => $value !== null,
        );
    }

    public function getAppCondition($app)
    {
        if (empty($app) || $app === 'default') {
            return '';
        }

        return ":{$app}";
    }

    public function getKeys() {
        $keys = $this->rules[0] ?? null;

        if (empty($keys)) {
            return [];
        }

        if ($keys === 'all') {
            $keys = '1,2,3,4,5,6,7,8,9,0,tab,q,w,e,r,t,y,u,i,o,p,open_bracket,close_bracket,caps_lock,a,s,d,f,g,h,j,k,l,semicolon,quote,return_or_enter,left_shift,z,x,c,v,b,n,m,comma,period,slash,right_shift,spacebar';
        } elseif ($keys === 'all-left') {
            $keys = 'tab,q,w,e,r,t,caps_lock,a,s,d,f,g,left_shift,z,x,c,v,b,spacebar';
        } elseif ($keys === 'all-right') {
            $keys = 'y,u,i,o,p,open_bracket,close_bracket,h,j,k,l,semicolon,quote,return_or_enter,b,n,m,comma,period,slash,right_shift,spacebar';
        }

        return explode(',', $keys);
    }

    public function newKey($key) {
        $keys = [
            'tab' => 'f9',
            'q' => 'w',
            'w' => 'f17',
            'e' => 'r',
            'r' => 't',
            't' => 'y',
            'y' => 'u',
            'u' => 'i',
            'i' => 'o',
            'o' => 'f13',
            'p' => 'open_bracket',
            'open_bracket' => 'close_bracket',
            'close_bracket' => 'f11',
            'a' => 's',
            's' => 'd',
            'd' => 'f',
            'f' => 'g',
            'g' => 'h',
            'h' => 'j',
            'j' => 'k',
            'k' => 'l',
            'l' => 'semicolon',
            'semicolon' => 'quote',
            'quote' => 'f10',
            'return_or_enter' => 'z',
            'caps_lock' => 'f16',
            'left_shift' => 'f15',
            'z' => 'x',
            'x' => 'c',
            'c' => 'v',
            'v' => 'b',
            'b' => 'n',
            'n' => 'f14',
            'm' => 'spacebar',
            'comma' => 'f18',
            'period' => 'f19',
            'slash' => 'f20',
            'right_shift' => 'f12',
            'spacebar' => 'tab',
        ];

        return $keys[$key] ?? $key;
    }
}
