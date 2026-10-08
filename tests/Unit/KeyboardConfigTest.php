<?php

use App\Models\App;
use App\Models\Dictation;
use App\Models\Hammerspoon;
use App\Models\Simlayer;

beforeEach(function () {
    App::use([
        'apps' => ['chrome' => 'com.google.Chrome', 'vivaldi' => 'com.vivaldi.Vivaldi', 'warp' => 'dev.warp.Warp-Stable'],
        'aliases' => ['browsers' => 'browser', 'terminal' => 'warp'],
        'groups' => ['browser' => ['chrome', 'vivaldi']],
    ]);
    Hammerspoon::use(['Hyper', 'Pane'], ['Tab.next']);
});

afterEach(function () {
    App::use(null);
    Hammerspoon::use(null);
});

function keys(string $index, array $rules): array
{
    return json_decode(json_encode((new Simlayer($index, $rules))->toKeys()['keys']), true);
}

test('a blank key is free: not in the layer, in Keys or Karabiner', function () {
    $layer = ['u' => 'hammerspoon', 'y' => null, 'i' => '', 'p' => 'c.p'];

    expect(array_keys(keys('caps : Hyper', $layer)))->toBe(['u', 'p'])
        ->and(keys('caps : Hyper', $layer)['u'][0]['actions'])->toBe([['hammerspoon' => ['mode' => 'Hyper', 'key' => 'u']]]);

    $edn = (new Simlayer('caps : Hyper', $layer))->getRules();
    expect($edn)->toContain('[:u [:hsk "Hyper" "u"]]')
        ->and($edn)->toContain('[:p [:!Cp] []]')
        ->and($edn)->not->toContain(':y')
        ->and($edn)->not->toContain(':i ');
});

test('hammerspoon works per app, and a blank override frees a key of `- all`', function () {
    $layer = ['h' => ['chrome' => 'hammerspoon', 'default' => 'c.[']];
    expect(keys('caps : Hyper', $layer)['h'])->toBe([
        ['app' => 'chrome', 'actions' => [['hammerspoon' => ['mode' => 'Hyper', 'key' => 'h']]]],
        ['actions' => [['key' => 'open_bracket', 'modifiers' => ['command']]]],
    ]);
    expect((new Simlayer('caps : Hyper', $layer))->getRules())->toContain('[:h [:hsk "Hyper" "h"] [:chrome]]');

    $pane = keys('q : Pane', ['all-right', ['j' => null, 'k' => 'dn']]);
    expect($pane)->not->toHaveKey('j')
        ->and($pane['k'][0]['actions'])->toBe([['key' => 'down_arrow']])
        ->and($pane['l'][0]['actions'])->toBe([['hammerspoon' => ['mode' => 'Pane', 'key' => 'l']]]);
});

test('the build refuses keys, apps, modes and events that go nowhere', function () {
    $problems = Simlayer::check([
        'caps : Hyper' => [
            'u' => 'hammerspoon',
            'zz' => 'c.p',
            'p' => 'c.nope',
            'o' => ['firefox' => 'c.t'],
            'i' => 'focus: safari',
            'j' => 'app: safari',
            'k' => 'hs: Tab.close',
            'l' => 'x.p',
        ],
        'd : Vi' => ['p' => 'hammerspoon', 'h' => 'lt'],
        'q : Make' => ['all-left'],
    ]);

    expect($problems)->toBe([
        'Hyper: “zz” isn\'t a key',
        'Hyper p: “nope” isn\'t a key',
        'Hyper o: no app “firefox” in apps.yml',
        'Hyper i: focus: no app “safari” in apps.yml',
        'Hyper j: app: no app “safari” in apps.yml',
        'Hyper k: hs: “Tab.close” isn\'t in init.lua\'s urlEvents (Keys can\'t reach it)',
        'Hyper l: Unknown modifier: X',
        'Vi p: `hammerspoon`, but Hammerspoon has no Vi mode',
        'Make: `- all-left`, but Hammerspoon has no Make mode',
    ]);
});

test('the app registry resolves aliases and groups, and builds Hammerspoon\'s table', function () {
    expect(App::resolve('browsers'))->toBe(['com.google.Chrome', 'com.vivaldi.Vivaldi'])
        ->and(App::bundle('terminal'))->toBe('dev.warp.Warp-Stable')
        ->and(App::bundle('browser'))->toBeNull()
        ->and(App::problems())->toBe([])
        ->and(App::toLua())->toContain("    terminal = 'dev.warp.Warp-Stable',")
        ->and(App::toLua())->toContain("    browsers = { 'chrome', 'vivaldi' },");

    App::use(['apps' => ['end' => 'x'], 'aliases' => ['a' => 'b', 'b' => 'a', 'chrome' => 'end']]);
    expect(App::problems())->toBe([
        'apps.yml: “end” can\'t be a Lua global (Hammerspoon\'s)',
        'apps.yml: a: Apps go round in a circle: a → b → a',
        'apps.yml: b: Apps go round in a circle: b → a → b',
    ]);
});

test('the real simlayers.yml and apps.yml are sound', function () {
    App::use(null);
    Hammerspoon::use(null);

    expect(Simlayer::check(Symfony\Component\Yaml\Yaml::parseFile(anvil_config('simlayers'))))->toBe([]);
});

test('dictation: a modifier on its own, your words and the model, for keys.json', function () {
    $dictation = new Dictation(['key' => 'right_option', 'words' => ['TidyKit', 'link-diag'], 'model' => 'gemma4:12b-mlx']);

    expect($dictation->check())->toBe([])
        ->and(json_decode(json_encode($dictation->toKeys()), true))
        ->toBe(['key' => 'right_option', 'words' => ['TidyKit', 'link-diag'], 'model' => 'gemma4:12b-mlx'])
        ->and(json_encode((new Dictation([]))->toKeys()))->toBe('{}');

    expect((new Dictation(['key' => 'd', 'words' => ['', 'ok'], 'model' => '']))->check())->toBe([
        'dictation: “d” isn\'t a modifier key (right_option, say)',
        'dictation: words are names, one a line ("")',
        'dictation: the model is an Ollama name (gemma4:12b-mlx, say)',
    ]);
});

test('the real dictation.yml is sound', function () {
    expect(Dictation::load()?->check())->toBe([]);
});
