
--[[ 🔒 KenzHub Loader - Final Stable Version ]]--

-- Delay load to avoid anti-cheat detection
task.wait(5)

-- Safe remote load
local function safeRequire(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not success then
        warn("[KenzHub Loader] Failed to load script:", result)
    end
    return result
end

-- Load main protected logic
safeRequire("https://raw.githubusercontent.com/KenzHub210/KenzHubFixed/main/ProtectedMain.lua")
