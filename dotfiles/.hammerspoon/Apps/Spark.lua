local Spark = {}
Spark.__index = Spark

-- Spark (com.tidypoint.Spark), the family's launcher: Raycast and Alfred
-- replaced. ⌥Space opens it, ⇧⌥⌘P its clipboard history, and its
-- tidypoint-spark:// links open it with text or run its commands.

function Spark.open()
    ks.alt('space')
end

function Spark.clipboard()
    ks.shiftAltCmd('p')
end

-- Percent-encoded for a link's query (a space is %20, not +).
local function encode(text)
    return (text:gsub('[^%w%-._~]', function(character)
        return string.format('%%%02X', string.byte(character))
    end))
end

-- Opens Spark with text to type on from: Spark.search('ddg ').
function Spark.search(text)
    hs.urlevent.openURL('tidypoint-spark://show?q=' .. encode(text))
end

-- One of the Mac's or Spark's own commands, by its id ('system.sleep').
-- Restart, Shut Down, Log Out and Empty Trash ask first, in the panel.
function Spark.run(id)
    hs.urlevent.openURL('tidypoint-spark://run/' .. id)
end

local function open(path)
    hs.urlevent.openURL('tidypoint-spark://' .. path)
end

-- Its lists: the windows (as ⌥Tab), files and folders by name, the menus of
-- the app in front, what to do with Finder's selection, Hammerspoon's
-- commands.
function Spark.windows()
    open('windows')
end

function Spark.files()
    open('files')
end

function Spark.menu()
    open('menu')
end

function Spark.fileActions()
    open('file-actions')
end

function Spark.commands()
    open('commands')
end

function Spark.sleep()
    Spark.run('system.sleep')
end

function Spark.emptyTrash()
    Spark.run('system.emptyTrash')
end

-- Its panel is up: Spark comes forward while it's open. Its Settings
-- window doesn't count.
function Spark.visible()
    local app = hs.application.frontmostApplication()

    if not app or app:bundleID() ~= 'com.tidypoint.Spark' then
        return false
    end

    local window = app:focusedWindow()

    return window ~= nil and window:title() ~= 'Spark Settings'
end

return Spark
