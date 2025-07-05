
--[[ 🔒 KenzHub Loader - Anti BAC Injection Bypass ]]--

-- Delay load to avoid injection flag
task.wait(5)

-- Deferred Module Execution
local function safeRequire(url)
  local s, r = pcall(function()
    return loadstring(game:HttpGet(url, true))()
  end)
  if not s then
    warn("[KenzHub] Failed to load:", r)
  end
  return r
end

-- Main Script Hosted Separately (Separated for anti-cheat)
safeRequire("https://raw.githubusercontent.com/KenzHub210/KenzHubFixed/main/ProtectedMain.lua")
