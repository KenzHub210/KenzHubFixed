
--[[ 📦 KenzHub | ProtectedMain.lua (Kavo UI Version) ]]--

-- Load Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("KenzHub UI", "DarkTheme")

-- Tabs
local mainTab = Window:NewTab("Main")
local aimSection = mainTab:NewSection("Aimlock")
local espSection = mainTab:NewSection("ESP")
local hitboxSection = mainTab:NewSection("Hitbox")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
getgenv().KenzHub = {
    Aimlock = false,
    ESP = false,
    Hitbox = false,
    LockPart = "Head",
    MaxDistance = 1000,
    HitboxSize = 20
}

-- Keybinds
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        KenzHub.Aimlock = not KenzHub.Aimlock
    elseif input.KeyCode == Enum.KeyCode.H then
        KenzHub.Hitbox = not KenzHub.Hitbox
    elseif input.KeyCode == Enum.KeyCode.T then
        KenzHub.ESP = not KenzHub.ESP
    end
end)

-- UI Toggles
aimSection:NewToggle("Enable Aimlock [Q]", "Toggle Aimlock", function(state)
    KenzHub.Aimlock = state
end)
aimSection:NewDropdown("LockPart", {"Head", "Torso"}, function(part)
    KenzHub.LockPart = part
end)
aimSection:NewSlider("Max Distance", "Max lock-on distance", 3000, 50, function(val)
    KenzHub.MaxDistance = val
end)

espSection:NewToggle("Enable ESP [T]", "Toggle ESP", function(state)
    KenzHub.ESP = state
end)

hitboxSection:NewToggle("Expand Hitbox [H]", "Expand enemy hitbox", function(state)
    KenzHub.Hitbox = state
end)
hitboxSection:NewSlider("Hitbox Size", "Resize hitbox", 100, 0, function(val)
    KenzHub.HitboxSize = val
end)

-- ESP & Aim Helpers
local function getEnemies()
    local enemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            table.insert(enemies, player)
        end
    end
    return enemies
end

local espBoxes = {}
local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    espBoxes[player] = box
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end

Players.PlayerRemoving:Connect(removeESP)

-- Main loop
RunService.RenderStepped:Connect(function()
    for _, player in pairs(getEnemies()) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos, onscreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude

            -- ESP
            if KenzHub.ESP then
                if not espBoxes[player] then createESP(player) end
                local box = espBoxes[player]
                box.Visible = onscreen
                box.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                if onscreen then
                    box.Size = Vector2.new(60, 100) / (distance / 100)
                    box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
                end
            elseif espBoxes[player] then
                removeESP(player)
            end

            -- Hitbox
            if KenzHub.Hitbox then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
                        v.Size = Vector3.new(KenzHub.HitboxSize/10, KenzHub.HitboxSize/10, KenzHub.HitboxSize/10)
                        v.Transparency = 0.5
                        v.Material = Enum.Material.ForceField
                    end
                end
            end
        end
    end

    -- Aimlock
    if KenzHub.Aimlock then
        local closest, shortest = nil, math.huge
        for _, player in pairs(getEnemies()) do
            if player.Character and player.Character:FindFirstChild(KenzHub.LockPart) then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < KenzHub.MaxDistance and dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild(KenzHub.LockPart) then
            local targetPart = closest.Character[KenzHub.LockPart]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)
