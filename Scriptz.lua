AimConfig = {
    Enabled = true,  -- Auto-locking always on for mobile
    Smoothness = 6,  -- Lower values = faster snapping, higher values = smoother
    AimFOV = 45,  -- Field of view for auto-lock
    TargetPart = "Head",  -- Part of the enemy to aim at
    Prediction = true,  -- Enables movement prediction
    PredictionFactor = 0.12,  -- Adjust for faster targets
    AutoLock = true,  -- Always locks onto the closest enemy
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Function to smoothly adjust aim towards the target
local function SmoothAim(current, target, factor)
    return current:Lerp(target, 1 / factor)
end

-- Function to find the closest target within Aim FOV
local function GetClosestBot()
    local closestBot = nil
    local shortestDistance = AimConfig.AimFOV

    local camera = Workspace.CurrentCamera

    for _, bot in ipairs(Workspace:GetChildren()) do
        if bot:IsA("Model") and bot:FindFirstChild("Humanoid") then
            local targetPart = bot:FindFirstChild(AimConfig.TargetPart) or bot:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestBot = targetPart
                    end
                end
            end
        end
    end
    return closestBot
end

-- Auto-locking and tracking loop
RunService.RenderStepped:Connect(function()
    if AimConfig.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local botTarget = GetClosestBot()
        if botTarget then
            local character = LocalPlayer.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                local targetPos = botTarget.Position
                if AimConfig.Prediction then
                    local velocity = botTarget.Parent:FindFirstChild("HumanoidRootPart") and botTarget.Parent.HumanoidRootPart.Velocity or Vector3.zero
                    targetPos = targetPos + (velocity * AimConfig.PredictionFactor)
                end
                
                local newCFrame = CFrame.new(rootPart.Position, targetPos)
                rootPart.CFrame = SmoothAim(rootPart.CFrame, newCFrame, AimConfig.Smoothness)
            end
        end
    end
end)
