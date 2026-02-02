local Is = {}
Is.__index = Is

function Is.codeEditor()
    return fn.app.codeEditor()
end

function Is.vimMode()
    return TextManipulation.canManipulateWithVim()
end

function Is.notVimMode()
    return not Is.vimMode()
end

function Is.browser()
    return Is.In(fn.app.fromAlias('browsers'))
end

function Is.chrome()
    return Is.In(chrome)
end

function Is.vivaldi()
    return Is.In(vivaldi)
end

function Is.finder()
    return Is.In(finder)
end

function Is.warp()
    return Is.In(warp)
end

function Is.terminal()
    return Is.In(warp)
end

function Is.vscode()
    return Is.In(vscode, cursor)
end

function Is.obsidian()
    return Is.In(obsidian)
end

function Is.In(bundle, ...)
    if Is.Table(bundle) then
        return fn.app.includes(bundle)
    end

    return fn.app.includes(table.pack(bundle, ...))
end

function Is.notIn(...)
    return not Is.In(table.pack(...))
end

function Is.String(value)
    return type(value) == 'string'
end

function Is.Table(value)
    return type(value) == 'table'
end

function Is.Function(value)
    return type(value) == 'function'
end

function Is.php()
    return fn.window.titleContains('.php')
end

function Is.js()
    return fn.window.titleContains('.js')
end

function Is.blade()
    return fn.window.titleContains('.blade.php')
end

function Is.lua()
    return fn.window.titleContains('.lua')
end

function Is.googleSheet()
    return Is.browser() and fn.Vivaldi.urlContains('docs.google.com') and fn.window.titleContains('Google Sheets')
end

function Is.github()
    return Is.browser() and fn.Vivaldi.urlContains('github.com')
end

function Is.todoOrMarkdown()
    return Is.todo() or Is.markdown()
end

function Is.todo()
    return fn.window.titleContains('.todo')
end

function Is.markdown()
    return fn.window.titleContains('.md')
end

function Is.gmail()
    return Is.browser() and (fn.window.titleContains('Fueling the Web Mail') or fn.window.titleContains('Gmail'))
end

function Is.chat()
    return Is.In(discord, slack)
end

function Is.malachor()
    return fn.window.pathContains('Malachor')
end

function Is.hammerspoon()
    return fn.window.pathContains('.hammerspoon')
end

function Is.quickFind()
    return fn.Raycast.visible()
end

function Is.obsidian()
    return Is.In(obsidian)
end

return Is
