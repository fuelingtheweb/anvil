local Artisan = {}
Artisan.__index = Artisan

Artisan.mainPath = nil
Artisan.path = nil
Artisan.command = nil
Artisan.watcher = nil
Artisan.commands = {}

function Artisan.setup()
    Artisan.add('migrate', {alias = 'mg'})
    Artisan.add('migrate:fresh', {
        alias = 'mgf',
        description = 'Drop all tables and re-run all migrations',
    })
    Artisan.add('migrate:rollback', {
        alias = 'mgr',
        description = 'Rollback the last database migration',
    })
    Artisan.add('migrate:fresh --seed', {
        alias = 'mgfs',
        description = 'Drop all tables, re-run migrations, and seed',
    })
    Artisan.add('db:seed', {
        alias = 'ds',
        description = 'Seed the database with records',
    })
    Artisan.add('route:list --columns=method,uri,name,action', {
        alias = 'rl',
        description = 'List all registered routes',
        callback = function()
            output = hs.execute(table.concat({'/usr/local/bin/php', Artisan.path, Artisan.command, '--json'}, ' '))
            file = io.open(home_path .. '/Dev/Anvil/custom/artisan-output.log', 'w')
            file:write(output)
            file:close()
            hs.execute(table.concat({
                '/usr/local/bin/php',
                home_path .. '/Dev/TidyPoint/cli/cli',
                'output:routes'
            }, ' '))
        end,
    })
    Artisan.add('--version', {
        alias = 'v',
        description = 'Display this application version',
    })
    Artisan.add('test --parallel', {
        alias = 'tp',
        description = 'Run the application tests in parallel',
    })
    Artisan.add('cache:clear', {
        alias = 'cc',
        description = 'Flush the application cache',
    })
    Artisan.add('key:generate', {
        alias = 'kg',
        description = 'Set the application key',
    })
    Artisan.add('storage:link', {
        alias = 'sl',
        description = 'Create the symbolic links configured for the application',
    })
    Artisan.add('stub:publish', {
        alias = 'sp',
        description = 'Publish all stubs that are available for customization',
    })
    Artisan.add('vendor:publish', {
        alias = 'vp',
        description = 'Publish any publishable assets from vendor packages',
    })
    Artisan.add('view:clear', {
        alias = 'vc',
        description = 'Flush the application cache',
    })
    Artisan.add('make:cast', {
        alias = 'mca',
        args = 'name',
        description = 'Create a new custom Eloquent cast class',
    })
    Artisan.add('make:channel', {
        alias = 'mch',
        args = 'name',
        description = 'Create a new channel class',
    })
    Artisan.add('make:command', {
        alias = 'mcmd',
        args = 'name',
        description = 'Create a new Artisan command',
    })
    Artisan.add('make:component', {
        alias = 'mco',
        args = 'name',
        description = 'Create a new view component class',
    })
    Artisan.add('make:controller {$1}Controller', {
        alias = 'mc',
        args = 'name',
        description = 'Create a new controller class',
    })
    Artisan.add('make:event', {
        alias = 'mev',
        args = 'name',
        description = 'Create a new event class',
    })
    Artisan.add('make:exception', {
        alias = 'mexc',
        args = 'name',
        description = 'Create a new custom exception class',
    })
    Artisan.add('make:factory --model={$1} {$1}Factory', {
        alias = 'mf',
        args = 'name',
        description = 'Create a new model factory',
    })
    Artisan.add('make:job', {
        alias = 'mj',
        args = 'name',
        description = 'Create a new job class',
    })
    Artisan.add('make:listener', {
        alias = 'mls',
        args = 'name',
        description = 'Create a new event listener class',
    })
    Artisan.add('make:livewire', {
        alias = 'mlw',
        args = 'name',
        description = 'Create a new Livewire component',
    })
    Artisan.add('make:mail', {
        alias = 'mma',
        args = 'name',
        description = 'Create a new email class',
    })
    Artisan.add('make:middleware', {
        alias = 'mmi',
        args = 'name',
        description = 'Create a new middleware class',
    })
    Artisan.add('make:migration', {
        alias = 'mmg',
        args = 'name',
        description = 'Create a new migration file',
    })
    Artisan.add('make:migration create_{$1}_table --create={$1}', {
        alias = 'mmgc',
        args = 'name',
        description = 'Create a new migration file',
    })
    Artisan.add('make:model -f', {
        alias = 'mmd',
        args = 'name',
        description = 'Create a new Eloquent model class',
    })
    Artisan.add('make:notification', {
        alias = 'mn',
        args = 'name',
        description = 'Create a new notification class',
    })
    Artisan.add('make:observer', {
        alias = 'mo',
        args = 'name',
        description = 'Create a new observer class',
    })
    Artisan.add('make:policy {$1}Policy', {
        alias = 'mpo',
        args = 'name',
        description = 'Create a new policy class',
    })
    Artisan.add('make:provider', {
        alias = 'mpr',
        args = 'name',
        description = 'Create a new service provider class',
    })
    Artisan.add('make:request {$1}Request', {
        alias = 'mrq',
        args = 'name',
        description = 'Create a new form request class',
    })
    Artisan.add('make:resource', {
        alias = 'mrs',
        args = 'name',
        description = 'Create a new resource',
    })
    Artisan.add('make:rule', {
        alias = 'mrl',
        args = 'name',
        description = 'Create a new validation rule',
    })
    Artisan.add('make:seeder {$1}Seeder', {
        alias = 'ms',
        args = 'name',
        description = 'Create a new seeder class',
    })
    Artisan.add('make:test {$1}Test', {
        alias = 'mt',
        args = 'name',
        description = 'Create a new test class',
    })
    Artisan.add('make:test --unit {$1}Test', {
        alias = 'mtu',
        args = 'name',
        description = 'Create a new test class',
    })
    Artisan.add('make:view', {
        alias = 'mv',
        args = 'name',
        description = 'Create a new view',
        callback = function(params)
            Artisan.openNewFiles(function()
                name = Artisan.convertTo('path', params.name)
                fn.clipboard.set(Artisan.convertTo('dot', name))
                filePath = Artisan.mainPath .. '/resources/views/' .. name .. '.blade.php'
                filePath = filePath:gsub('~', home_path)
                output = hs.execute('mkdir -p "$(dirname "' .. filePath .. '")" && touch "' .. filePath .. '"')
            end)
        end,
    })

    Artisan.loadAlfredJson()
end

function Artisan.add(command, attributes)
    attributes = attributes or {}
    attributes['name'] = command

    Artisan.commands[command] = attributes
end

function Artisan.loadAlfredJson()
    local items = {}

    fn.each(Artisan.commands, function(command)
        local alias = command.alias or ''

        table.insert(items, {
            uid = command.name,
            title = command.name,
            subtitle = command.description,
            match = alias .. ' ' .. command.name,
            arg = command.name:gsub(' ', ':s:'):gsub('{%$1}', ':1:'):gsub('=', ':eq:')
        })
    end)

    hs.json.write(
        {items = items},
        home_path .. '/Dev/Anvil/custom/artisan.json',
        false,
        true
    )
end

function Artisan.start()
    local path = fn.window.path()

    if hs.fs.attributes(path .. '/artisan') then
        Artisan.mainPath = path
        Artisan.path = path .. '/artisan'

        fn.Alfred.run('artisan', 'com.fuelingtheweb.commands')
    else
        ray('artisan not found')
    end
end

function Artisan.showNewScreen()
    Ray.newScreen('artisan ' .. Artisan.command .. ' (' .. Artisan.mainPath .. ')')
end

function Artisan.setupArgs()
    args = {Artisan.path:gsub('~', home_path), '--no-ansi'}

    fn.each(hs.fnutils.split(Artisan.command, ' '), function(arg)
        table.insert(args, arg)
    end)

    return args
end

function Artisan.run(notify)
    hs.task.new(
        '/usr/local/bin/php',
        function(exitCode, stdOut, stdErr)
            if stdOut then
                Artisan.success(stdOut)

                if notify then
                    hs.notify.new({
                        title = 'artisan ' .. Artisan.command,
                        informativeText = stdOut
                    }):send()
                end
            end

            if stdErr then
                Artisan.error(stdErr)
            end
        end,
        function(task, stdOut, stdErr)
            if stdOut then
                Artisan.success(stdOut)
            end

            if stdErr then
                Artisan.error(stdErr)
            end

            return true
        end,
        Artisan.setupArgs()
    ):start()
end

function Artisan.success(value)
    Ray.green(value:gsub('[\n\r]', '<br>'))
end

function Artisan.error(value)
    Ray.red(value:gsub('[\n\r]', '<br>'))
end

hs.urlevent.bind('artisan', function(eventName, params)
    Artisan.command = params.command:gsub(':s:', ' '):gsub(':1:', '{$1}'):gsub(':eq:', '=')
    print(Artisan.command)
    command = Artisan.commands[Artisan.command]

    if command.args then
        return fn.Alfred.run(
            'artisan-command',
            'com.fuelingtheweb.commands',
            command.name
        )
    end

    if command.callback then
        Artisan.showNewScreen()

        return command.callback()
    end

    Artisan.showNewScreen()
    Artisan.run()
end)

hs.urlevent.bind('artisan-command', function(eventName, params)
    command = Artisan.commands[Artisan.command]

    if command.callback then
        return command.callback({name = params.name})
    end

    Artisan.openNewFiles(function()
        converter = 'pascal'

        if str.contains('migration', Artisan.command) then
            converter = 'snake'
        end

        parts = hs.fnutils.map(
            hs.fnutils.split(params.name, '/'),
            function(text)
                return Artisan.convertTo(converter, text)
            end
        )
        name = table.concat(parts, '/')
        fn.clipboard.set(name)

        if str.contains('{$1}', Artisan.command) then
            Artisan.command = Artisan.command:gsub('{$1}', name)
        else
            Artisan.command = Artisan.command .. ' ' .. name
        end

        Artisan.showNewScreen()
        Artisan.run(true)
    end)
end)

function Artisan.openNewFiles(callback)
    if Artisan.watcher then Artisan.watcher:stop() end

    Artisan.watcher = hs.pathwatcher.new(Artisan.mainPath .. '/',
        function(paths)
            fn.each(paths, function(path)
                if str.contains('.php', path) then
                    fn.Code.open(path)
                end
            end)

            local app = hs.application.find(cursor) or hs.application.find(vscode)
            if app then
                app:activate()
            end
            ks.save()
        end):start()

    callback()

    hs.timer.doAfter(0.5, function()
        Artisan.watcher:stop()
    end)
end

function Artisan.convertTo(converter, text)
    return str.trim(hs.execute('/Users/nathan/.nvm/versions/node/v12.4.0/bin/node /Users/nathan/Dev/Anvil/bin/change-case/bin/index.js "' .. converter .. '" "' .. text .. '"')):gsub('/Users/nathan', home_path)
end

function Artisan.migrateFreshAndSeed()
    ks.typeAndEnter('amgfs')
end

Artisan.setup()

return Artisan
