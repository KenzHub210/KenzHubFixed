
--[[ 🔐 ProtectedMain.lua | Optimized Script Core ]]--

-- Settings
getgenv().KenzHub = {
  AimlockEnabled = true,
  HitboxEnabled = true,
  ESPEnabled = true,
  MaxDistance = 1000,
  LockPart = "Head"
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP Setup
local function createESP(player)
  if not player.Character or player == LocalPlayer then return end
  local box = Drawing.new("Square")
  box.Visible = false
  box.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
  box.Thickness = 2
  box.Filled = false
  box.ZIndex = 2
  return box
end

-- Target Calculation
local function getClosestTarget()
  local closest, shortest = nil, math.huge
  for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
      local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
      if distance < KenzHub.MaxDistance and distance < shortest then
        shortest = distance
        closest = player
      end
    end
  end
  return closest, shortest
end

-- Main Loop
RunService.RenderStepped:Connect(function()
  local target, distance = getClosestTarget()

  -- Aimlock
  if KenzHub.AimlockEnabled and target then
    local part = target.Character:FindFirstChild(KenzHub.LockPart)
    if part then
      Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    end
  end

  -- Update UI (if any)
  if getgenv().UpdateKenzHubUI then
    pcall(function()
      UpdateKenzHubUI(distance or "N/A")
    end)
  end
end)
