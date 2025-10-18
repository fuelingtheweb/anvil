<?php

namespace App\Models;

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

        foreach ($this->getKeys() as $key) {
            if ($key === $this->key) {
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

            if (empty($customRules) && $customRules !== '0') {
                $rules .= str('[:$key [:hsk "$label" "$key"]]$newLine$indent')
                    ->replace('$label', $this->label)
                    ->replace('$key', $this->keyMap[$key] ?? $key)
                    ->replace('$newLine', "\n")
                    ->replace('$indent', indent(4))
                    ->value();

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

    public function parseAction($action)
    {
        $action = str($action);

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
