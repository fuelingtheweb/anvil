local Vivaldi = {}
Vivaldi.__index = Vivaldi

function Vivaldi.open(url)
    hs.osascript.applescript([[
        tell application "Vivaldi"
            tell front window
                make new tab with properties {URL:"]] .. url .. [["}
            end tell

            activate
        end tell
    ]])
end

function Vivaldi.urlContains(needle)
    return str.contains(needle:gsub('-', '%%-'), Vivaldi.currentUrl())
end

function Vivaldi.currentUrl()
    return fn.clipboard.preserve(function ()
        hs.osascript.applescript([[
            tell application "Vivaldi"
                set currentURL to URL of active tab of window 1
                set the clipboard to currentUrl
            end tell
        ]])
        -- set currentURL to URL of active tab of window 1
        -- set currentTitle to title of active tab of window 1
    end)
end

function Vivaldi.copyUrl()
    hs.osascript.applescript([[
        tell application "Vivaldi"
            set pageURL to URL of active tab of window 1
            set the clipboard to pageURL
        end tell
    ]])
end

function Vivaldi.copyMarkdownUrl()
    local ok, result = hs.osascript.applescript([[
        tell application "Vivaldi"
            set pageTitle to title of active tab of window 1
            set pageURL to URL of active tab of window 1
        end tell
        return {pageTitle, pageURL}
    ]])

    if not ok then return end

    local title = result[1]
    local url = result[2]

    if is.github() then
        title = Vivaldi.cleanGithubTitle(title)
    end

    fn.clipboard.set(title .. " - " .. url)
end

function Vivaldi.cleanGithubTitle(title)
    -- PR: "Title by author · Pull Request #123 · org/repo"
    local prTitle, num, repo = title:match("^(.+) by .+ · Pull Request #(%d+) · .+/(.+)$")
    if prTitle then
        return repo:sub(1, 1):upper() .. repo:sub(2) .. " #" .. num .. " - " .. prTitle
    end

    -- Issue: "Title · Issue #123 · org/repo"
    local issueTitle, issueNum, issueRepo = title:match("^(.+) · Issue #(%d+) · .+/(.+)$")
    if issueTitle then
        return issueRepo:sub(1, 1):upper() .. issueRepo:sub(2) .. " #" .. issueNum .. " - " .. issueTitle
    end

    return title
end

return Vivaldi
