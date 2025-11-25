local AlfredCommands = {}
AlfredCommands.__index = AlfredCommands
AlfredCommands.all = {}

function AlfredCommands:add(key, name, icon, handler)
    if self.all[key] then
        hs.alert.show('Command conflict for: ', key)
        hs.notify.new({title = 'Command conflict for: ' .. key}):send()

        return
    end

    self.all[key] = {name = name, icon = icon, handler = handler}

    return self
end

function AlfredCommands:setAlfredJson()
    local items = {}

    fn.each(AlfredCommands.all, function(command, key)
        local iconPath = home_path .. '/Dropbox/Ftw/Alfred/Alfred.alfredpreferences/workflows/user.workflow.7CF5F8CA-70CF-4DDF-8543-642E861FCF88/'
        local icon = 'icon.png'

        if command.icon then
            icon = command.icon
        end

        table.insert(items, {
            uid = key,
            title = command.name,
            arg = key,
            autocomplete = command.name,
            icon = {path = iconPath .. icon}
        })
    end)

    hs.json.write(
        {items = items},
        home_path .. '/Dev/Anvil/custom/alfred-commands.json',
        false,
        true
    )
end

function AlfredCommands:trigger(key)
    command = self.all[key]

    if not command or not command.handler then
        return
    end

    command.handler()
end

function AlfredCommands:addFromConfig()
    require('config.custom.commands')
end

function AlfredCommands:listen()
    hs.urlevent.bind('alfred-command', function(eventName, params)
        self:trigger(params.key)
    end)
end

return AlfredCommands
