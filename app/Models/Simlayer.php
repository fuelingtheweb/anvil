<?php

namespace App\Models;

use InvalidArgumentException;

class Simlayer
{
    public $label;
    public $name;
    public $key;
    public $rules;

    /**
     * The keys Keys knows (its KeyCodes.byName, Karabiner's names): a layer
     * key or a keystroke that isn't one is refused at build time.
     */
    public const KEY_NAMES = [
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
        's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'return_or_enter', 'escape', 'delete_or_backspace', 'delete_forward', 'tab', 'spacebar',
        'hyphen', 'equal_sign', 'open_bracket', 'close_bracket', 'backslash', 'non_us_backslash',
        'semicolon', 'quote', 'grave_accent_and_tilde', 'comma', 'period', 'slash', 'caps_lock',
        'left_control', 'left_shift', 'left_option', 'left_command', 'right_control',
        'right_shift', 'right_option', 'right_command', 'fn', 'f1', 'f2', 'f3', 'f4', 'f5', 'f6',
        'f7', 'f8', 'f9', 'f10', 'f11', 'f12', 'f13', 'f14', 'f15', 'f16', 'f17', 'f18', 'f19',
        'f20', 'up_arrow', 'down_arrow', 'left_arrow', 'right_arrow', 'page_up', 'page_down',
        'home', 'end', 'help', 'mute', 'volume_increment', 'volume_decrement', 'keypad_0',
        'keypad_1', 'keypad_2', 'keypad_3', 'keypad_4', 'keypad_5', 'keypad_6', 'keypad_7',
        'keypad_8', 'keypad_9', 'keypad_period', 'keypad_asterisk', 'keypad_plus',
        'keypad_hyphen', 'keypad_slash', 'keypad_enter', 'keypad_equal_sign', 'keypad_num_lock',
    ];

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

            $name = $this->keyMap[$key] ?? $key;

            // A key `- all` hands over that does something else (not focus:
            // Karabiner can't, so Hammerspoon's mode still does it there), or
            // nothing: blank, it's free.
            if (array_key_exists($name, $overrides)) {
                $override = $overrides[$name];

                if ($this->isFree($override) || $this->isDictate($override)) {
                    continue;
                }

                $rules .= $this->ednRule($key, $override);

                continue;
            }

            $rules .= $this->ednRule($key, 'hammerspoon');
        }

        foreach ($this->getCustomRules() as $key => $customRules) {
            if ($key === $this->key || $this->isFree($customRules)) {
                continue;
            }

            if (! is_array($customRules)) {
                if (! $this->isDictate($customRules)) {
                    $rules .= $this->ednRule($key, $customRules);
                }

                continue;
            }

            foreach ($customRules as $app => $action) {
                // Karabiner can't dictate: the key types as it did without the rule.
                if (! $this->isFree($action) && ! $this->isDictate($action)) {
                    $rules .= $this->ednRule($key, $action, $app);
                }
            }
        }

        return rtrim($rules);
    }

    /**
     * One EDN rule: to Hammerspoon's mode for `hammerspoon` and `focus:`
     * (Karabiner can't focus), else the action, for `$app` (null: any).
     */
    private function ednRule($key, $action, $app = null)
    {
        $name = $this->keyMap[$key] ?? $key;

        if ($this->isHammerspoon($action) || $this->isFocus($action)) {
            $edn = str(':hsk "$label" "$key"')->replace('$label', $this->label)->replace('$key', $name)->value();
        } else {
            $edn = $this->parseAction($action);
        }

        // As before: a key to Hammerspoon for every app has no conditions.
        $template = $app === null && ($this->isHammerspoon($action) || $this->isFocus($action))
            ? '[:$key [$action]]$newLine$indent'
            : '[:$key [$action] [$conditions]]$newLine$indent';

        return str($template)
            ->replace('$key', $name)
            ->replace('$action', $edn)
            ->replace('$conditions', $this->getAppCondition($app ?? 'default'))
            ->replace('$newLine', "\n")
            ->replace('$indent', indent(4))
            ->value();
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
     * A blank one is free: left out of the layer.
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
     * Blank (or null): the key is free, not in the layer, and types as itself.
     */
    public function isFree($action)
    {
        return $action === null || $action === '' || $action === [];
    }

    /**
     * `hammerspoon`: the layer's Hammerspoon mode does the key
     * (`handle-karabiner`, Modes/<Label>.lua), as every key of a `- all` layer.
     */
    public function isHammerspoon($action)
    {
        return is_string($action) && trim($action) === 'hammerspoon';
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
        if ($this->isHammerspoon($action)) {
            return [$this->hammerspoonAction($key)];
        }

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
                        ? '"' . (App::bundle($value) ?? $value) . '"'
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

            if (! array_key_exists($name, $overrides)) {
                $keys[$name][] = ['actions' => [$this->hammerspoonAction($key)]];

                continue;
            }

            if (! $this->isFree($overrides[$name])) {
                $keys[$name][] = ['actions' => $this->keysActionFor($key, $overrides[$name])];
            }
        }

        foreach ($this->getCustomRules() as $key => $customRules) {
            $name = $this->keyMap[$key] ?? $key;

            if ($key === $this->key || $this->isFree($customRules)) {
                continue;
            }

            if (! is_array($customRules)) {
                $keys[$name][] = ['actions' => $this->keysActionFor($key, $customRules)];

                continue;
            }

            foreach ($customRules as $app => $action) {
                if ($this->isFree($action)) {
                    continue;
                }

                $keys[$name][] = array_filter([
                    'app' => $app === 'default' ? null : $app,
                    'actions' => $this->keysActionFor($key, $action),
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

    /** A key as simlayers.yml writes it ('[', sb) to Karabiner's name (open_bracket, spacebar). */
    public function keyName($key)
    {
        return $this->keyMap[$key] ?? $key;
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
                'app' => ['app' => App::bundle($values[0]) ?? $values[0]],
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

    /**
     * Everything wrong with simlayers.yml and apps.yml, for the build
     * commands to refuse before writing anything.
     */
    public static function check(array $layers): array
    {
        $problems = App::problems();

        foreach ($layers as $index => $rules) {
            $problems = [...$problems, ...(new self($index, $rules))->problems()];
        }

        return $problems;
    }

    /**
     * What's wrong with this layer: a key Keys doesn't know, an app apps.yml
     * doesn't, or a key Hammerspoon would drop (a mode it doesn't load, an
     * `hs:` event init.lua's urlEvents doesn't register).
     */
    public function problems(): array
    {
        $problems = [];

        if (! in_array($this->key, self::KEY_NAMES, true)) {
            $problems[] = "{$this->label}: its trigger “{$this->key}” isn't a key";
        }

        if ($this->getKeys() !== []) {
            if (! Hammerspoon::hasMode($this->label)) {
                $problems[] = "{$this->label}: `- {$this->rules[0]}`, but Hammerspoon has no {$this->label} mode";
            }

            foreach ($this->getOverrides() as $name => $override) {
                $problems = [...$problems, ...$this->ruleProblems($name, $override)];
            }
        }

        foreach ($this->getCustomRules() as $key => $rules) {
            $problems = [...$problems, ...$this->ruleProblems($this->keyMap[$key] ?? $key, $rules)];
        }

        return $problems;
    }

    /** A layer key's value: free, one action, or a map of them by app. */
    private function ruleProblems($name, $rules)
    {
        if (! in_array($name, self::KEY_NAMES, true)) {
            return ["{$this->label}: “{$name}” isn't a key"];
        }

        if ($this->isFree($rules)) {
            return [];
        }

        if (! is_array($rules)) {
            return $this->actionProblems($name, $rules);
        }

        $problems = [];

        foreach ($rules as $app => $action) {
            if ($app !== 'default' && ! App::has((string) $app)) {
                $problems[] = "{$this->label} {$name}: no app “{$app}” in apps.yml";
            }

            if (! $this->isFree($action)) {
                $problems = [...$problems, ...$this->actionProblems($name, $action, $app)];
            }
        }

        return $problems;
    }

    private function actionProblems($name, $action, $app = 'default')
    {
        $where = "{$this->label} {$name}" . ($app === 'default' ? '' : " ({$app})");

        if (! is_string($action)) {
            return ["{$where}: not an action"];
        }

        if ($this->isHammerspoon($action)) {
            return Hammerspoon::hasMode($this->label)
                ? []
                : ["{$where}: `hammerspoon`, but Hammerspoon has no {$this->label} mode"];
        }

        if ($this->isFocus($action)) {
            $target = trim(str($action)->after(':')->value());

            return [
                ...(App::has($target) ? [] : ["{$where}: focus: no app “{$target}” in apps.yml"]),
                ...(Hammerspoon::hasMode($this->label) ? [] : ["{$where}: focus: needs Hammerspoon's {$this->label} mode (window hints)"]),
            ];
        }

        $problems = [];

        foreach (str($action)->explode(' ++ ') as $part) {
            $part = str($part)->trim();

            if ($part->startsWith('app:') && App::bundle($part->after(':')->trim()->value()) === null) {
                $problems[] = "{$where}: app: no app “{$part->after(':')->trim()}” in apps.yml";
            }
        }

        try {
            $actions = $this->parseKeysAction($action);
        } catch (InvalidArgumentException $e) {
            return [...$problems, "{$where}: {$e->getMessage()}"];
        }

        foreach ($actions as $one) {
            if (isset($one['key']) && ! in_array($one['key'], self::KEY_NAMES, true)) {
                $problems[] = "{$where}: “{$one['key']}” isn't a key";
            }

            if (isset($one['hammerspoon']['event']) && ! Hammerspoon::hasEvent($one['hammerspoon']['event'])) {
                $problems[] = "{$where}: hs: “{$one['hammerspoon']['event']}” isn't in init.lua's urlEvents (Keys can't reach it)";
            }

            if (isset($one['hammerspoon']['mode']) && ! Hammerspoon::hasMode($one['hammerspoon']['mode'])) {
                $problems[] = "{$where}: hsk: Hammerspoon has no {$one['hammerspoon']['mode']} mode";
            }
        }

        return $problems;
    }

    public function getAppCondition($app)
    {
        if (empty($app) || $app === 'default') {
            return '';
        }

        return ":{$app}";
    }

    public function getKeys()
    {
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
}
