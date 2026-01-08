Shortcuts
    :add('R', {
        slack = fn.Slack.react,
        vscode = function()
            if is.malachor() then
                return fn.custom.openPrimary()
            end

            local path = fn.window.path()

            if hs.fs.pathToAbsolute(path .. '/routes/web.php') then
                fn.Code.open(path .. '/routes/web.php')
            end
        end,
        cursor = function()
            if is.malachor() then
                return fn.custom.openPrimary()
            end

            local path = fn.window.path()

            if hs.fs.pathToAbsolute(path .. '/routes/web.php') then
                fn.Code.open(path .. '/routes/web.php')
            end
        end,
    })
    :add('T', {
        vscode = function()
            if is.malachor() then
                fn.custom.openInternalTasks()
            else
                md.Hyper.open()
                ks.type('Tests/')
            end
        end,
        cursor = function()
            if is.malachor() then
                fn.custom.openInternalTasks()
            else
                md.Hyper.open()
                ks.type('Tests/')
            end
        end,
    })
    :add('E', {
        vscode = function()
            if is.malachor() then
                return fn.custom.openEod()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Helpers/')

                return
            end

            local path = fn.window.path()

            if hs.fs.pathToAbsolute(path .. '/.env') then
                fn.Code.open(path .. '/.env')
            elseif hs.fs.pathToAbsolute(path .. '/wp-config.php') then
                fn.Code.open(path .. '/wp-config.php')
            end
        end,
        cursor = function()
            if is.malachor() then
                return fn.custom.openEod()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Helpers/')

                return
            end

            local path = fn.window.path()

            if hs.fs.pathToAbsolute(path .. '/.env') then
                fn.Code.open(path .. '/.env')
            elseif hs.fs.pathToAbsolute(path .. '/wp-config.php') then
                fn.Code.open(path .. '/wp-config.php')
            end
        end,
    })
    :add('S', {
        vscode = 'Preferences: Configure User Snippets',
        cursor = 'Preferences: Configure User Snippets'
    })
    :add('Z', {
        warp = 'wd fz',
        vscode = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Modals/')
            else
                md.Hyper.open()
                ks.type('resources/')
            end
        end,
        cursor = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Modals/')
            else
                md.Hyper.open()
                ks.type('resources/')
            end
        end,
    })
    :add('D', {
        warp = 'wd d',
        vscode = function()
            if is.malachor() then
                return fn.custom.openDigitalCreativity()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Modes/')
            else
                md.Hyper.open()
                ks.type('app/Models/')
            end
        end,
        cursor = function()
            if is.malachor() then
                return fn.custom.openDigitalCreativity()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Modes/')
            else
                md.Hyper.open()
                ks.type('app/Models/')
            end
        end,
    })
    :add('C', {
        vscode = function()
            if is.malachor() then
                fn.custom.openClientTasks()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Commands/')
            else
                md.Hyper.open()
                ks.type('app/Http/Controllers/')
            end
        end,
        cursor = function()
            if is.malachor() then
                fn.custom.openClientTasks()
            elseif is.hammerspoon() then
                md.Hyper.open()
                ks.type('Commands/')
            else
                md.Hyper.open()
                ks.type('app/Http/Controllers/')
            end
        end,
        chrome = function()
            if is.github() and fn.Chrome.urlContains('/files$') then
                fn.Chrome.changeUrl(fn.Chrome.currentUrl():gsub('/files$', ''))
            end
        end,
    })
    :add('A', {
        fastmail = function()
            -- Spam
            ks.key('g').down().enter()
        end,
        vscode = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Apps/')
            end
        end,
        cursor = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Apps/')
            end
        end,
    })
    :add('V', {
        vscode = function()
            md.Hyper.open()
            ks.type('resources/views/')
        end,
        cursor = function()
            md.Hyper.open()
            ks.type('resources/views/')
        end,
    })
    :add('SPACEBAR', {
        vscode = function()
            -- Preferences: Open Settings (JSON)
            ks.cmd('k').cmd('p')
        end,
        cursor = function()
            -- Preferences: Open Settings (JSON)
            ks.cmd('k').cmd('p')
        end
    })
    :add('Q', {
        vscode = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Spoons/')
            end
        end,
        cursor = function()
            if is.hammerspoon() then
                md.Hyper.open()
                ks.type('Spoons/')
            end
        end,
    })
    :add('CAPS_LOCK', {
        vscode = function()
            if is.hammerspoon() then
                fn.Code.open(fn.window.path() .. '/init.lua')
            end
        end,
        cursor = function()
            if is.hammerspoon() then
                fn.Code.open(fn.window.path() .. '/init.lua')
            end
        end,
    })
    :add('F', {
        chrome = function()
            if is.github() and fn.Chrome.urlContains('/pull/') then
                fn.Chrome.changeUrl(fn.Chrome.currentUrl() .. '/files')
            end
        end,
        fastmail = function()
            -- Inbox
            ks.key('g').enter()
        end,
    })
