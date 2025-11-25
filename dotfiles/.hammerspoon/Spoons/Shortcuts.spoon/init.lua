local Shortcuts = {}
Shortcuts.__index = Shortcuts
Shortcuts.all = {}
Shortcuts.appFunctionMapping = {
    discord = fn.Discord.openChannel,
    slack = fn.Slack.openChannel,
    warp = ks.typeAndEnter,
    vscode = fn.Code.run,
    chrome = '',
    mailspring = '',
    mimestream = '',
}

function Shortcuts:add(key, mapping)
    if self.all[key] then
        mapping = self:mergeMapping(key, mapping)
    end

    self.all[key] = mapping

    return self
end

function Shortcuts:mergeMapping(key, source)
    local dest = self.all[key]

    for k, v in pairs(source) do
        if dest[k] then
            local message = 'Shortcut conflict for: ' .. key .. ' > ' .. k
            hs.alert.show(message)
            hs.notify.new({title = message}):send()
        end

        dest[k] = v
    end

    return dest
end

function Shortcuts:handle(key)
    shortcut = self.all[key]

    if not shortcut then
        return
    end

    success = false

    for key, value in pairs(self.appFunctionMapping) do
        app = key
        func = value
        shortcutKey = key
        if type(value) == 'table' then
            app = value['app']
            func = value['func']
            shortcutKey = value['key']
        end

        if is.In(_G[app]) and shortcut[shortcutKey] then
            if type(shortcut[shortcutKey]) == 'function' then
                shortcut[shortcutKey]()
            elseif is.Function(func) then
                func(shortcut[shortcutKey])
            else
                _G[func](shortcut[shortcutKey])
            end
            success = true
            break
        end
    end

    if not success then
        if shortcut['default'] then
            shortcut['default']()
        else
            return 'else'
        end
    end
end

function Shortcuts:addFromConfig()
    require('config.shortcuts')
    require('config.custom.shortcuts')
end

return Shortcuts
