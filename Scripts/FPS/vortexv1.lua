local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "V0Rt3x Cheat",
   LoadingTitle = "Initializing Vortex...",
   LoadingSubtitle = "by yKyoshi",
   ConfigurationSaving = { Enabled = true, FolderName = "VortexCheat" },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

local AimbotEnabled = false
local AutoShotEnabled = false
local ESPEnabled = false
local WallCheck = false 
local IgnoreRagdoll = true
local fov = 150
local ESP_Color = Color3.fromRGB(128, 0, 128)
local WalkSpeedValue = 16
local JumpPowerValue = 50
local Oscilacao = 0 
local JesusModeActive = false 
local KillAuraEnabled = false
local GodModeLoop = false
local FastLadder = false
local NoDelayArms = false

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Radius = fov

local function canSeeTarget(targetPart)
    if not targetPart then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char, targetPart.Parent, Cam}
    local direction = (targetPart.Position - Cam.CFrame.Position).Unit * (targetPart.Position - Cam.CFrame.Position).Magnitude
    local ray = workspace:Raycast(Cam.CFrame.Position, direction, rayParams)
    return ray == nil
end

local function getTarget()
    local nearest = nil
    local last = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local isRagdoll = (IgnoreRagdoll and hum and (hum:GetState() == Enum.HumanoidStateType.Physics or hum.Health <= 0))
            
            if not isRagdoll then
                if not WallCheck or canSeeTarget(head) then
                    local pos, onScreen = Cam:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - (Cam.ViewportSize / 2)).Magnitude
                        if dist < last and dist < fov then
                            last = dist
                            nearest = p
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local Shooting = false
local function DoAutoShot(target)
    if Shooting then return end
    if not canSeeTarget(target.Character.Head) then return end
    Shooting = true
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    task.wait(0.2) 
    if canSeeTarget(target.Character.Head) then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
    task.wait(0.1) 
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    Shooting = false
end

-- // 4. TABS
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local OPTab = Window:CreateTab("OP Boosts", 4483362458)

CombatTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v; FOVring.Visible = v end})
CombatTab:CreateToggle({Name = "Auto Shot (Snipe Fix)", CurrentValue = false, Callback = function(v) AutoShotEnabled = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheck = v end})
CombatTab:CreateSlider({Name = "Aimbot Shake", Range = {0, 50}, Increment = 1, CurrentValue = 0, Callback = function(v) Oscilacao = v end})
CombatTab:CreateSlider({Name = "FOV Radius", Range = {10, 600}, Increment = 1, CurrentValue = 150, Callback = function(v) fov = v; FOVring.Radius = v end})

VisualsTab:CreateToggle({Name = "Player Highlight", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
VisualsTab:CreateColorPicker({Name = "ESP Color", Color = Color3.fromRGB(128, 0, 128), Callback = function(v) ESP_Color = v end})

PlayerTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) WalkSpeedValue = v end})
PlayerTab:CreateSlider({Name = "JumpPower", Range = {10, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) JumpPowerValue = v end})
PlayerTab:CreateToggle({Name = "Fast Ladder", CurrentValue = false, Callback = function(v) FastLadder = v end})
PlayerTab:CreateToggle({Name = "Jesus Mode", CurrentValue = false, Callback = function(v) JesusModeActive = v end})

OPTab:CreateToggle({Name = "Instant Shot (No Delay)", CurrentValue = false, Callback = function(v) NoDelayArms = v end})
OPTab:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) KillAuraEnabled = v end})
OPTab:CreateToggle({Name = "Infinite Heal Loop", CurrentValue = false, Callback = function(v) GodModeLoop = v end})

RunService.RenderStepped:Connect(function()
    FOVring.Position = Cam.ViewportSize / 2
    if ESPEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("Vortex_ESP") or Instance.new("Highlight", p.Character)
                h.Name = "Vortex_ESP"
                h.OutlineColor = ESP_Color; h.FillColor = ESP_Color; h.DepthMode = "AlwaysOnTop"
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Vortex_ESP") then p.Character.Vortex_ESP:Destroy() end
        end
    end

    if AimbotEnabled then
        local t = getTarget()
        if t then
            local Shake = Vector3.new(math.random(-Oscilacao, Oscilacao)/10, math.random(-Oscilacao, Oscilacao)/10, math.random(-Oscilacao, Oscilacao)/10)
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, t.Character.Head.Position + Shake)
            if AutoShotEnabled then task.spawn(function() DoAutoShot(t) end) end
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.WalkSpeed = WalkSpeedValue
        h.JumpPower = JumpPowerValue
        h.UseJumpPower = true
        
        if FastLadder and h:GetState() == Enum.HumanoidStateType.Climbing then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 0)
        end
        if GodModeLoop then h.Health = 100 end
        
        if NoDelayArms then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                if tool:FindFirstChild("Delay") then tool.Delay.Value = 0 end
                if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end
            end
        end
    end
end)

Rayfield:Notify({Title = "V0Rt3x", Content = "V0Rt3x Cheat was successfully loaded!", Duration = 5})
