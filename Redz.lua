local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Chequeo Blox Fruits
if game.PlaceId ~= 2753915549 then
    warn("❌ Este script solo funciona en Blox Fruits!")
    return
end

-- Variables Auto Farm
local autoFarmEnabled = false
local farmConnection
local questTaken = false

-- GUI PRINCIPAL (estilo Redz Hub puro)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WoodHubBeta"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Barra título draggable (roja como Redz)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 WOOD HUB BETA 🔥"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Parent = titleBar

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 1, 0)
versionLabel.Position = UDim2.new(0, 0, 0.6, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "Auto Farm Only - v1.0"
versionLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
versionLabel.TextScaled = true
versionLabel.Font = Enum.Font.Gotham
versionLabel.Parent = titleBar

-- Botón Auto Farm
local farmButton = Instance.new("TextButton")
farmButton.Size = UDim2.new(0.8, 0, 0, 70)
farmButton.Position = UDim2.new(0.1, 0, 0.4, 0)
farmButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
farmButton.Text = "AUTO FARM: OFF"
farmButton.TextColor3 = Color3.new(1, 1, 1)
farmButton.TextScaled = true
farmButton.Font = Enum.Font.GothamBold
farmButton.Parent = mainFrame

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 12)
farmCorner.Parent = farmButton

-- Estado label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Esperando..."
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Drag funcional (móvil/PC)
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Función Auto Farm (mobs + quest auto)
local function startAutoFarm()
    statusLabel.Text = "Estado: Buscando mobs..."
    spawn(function()
        while autoFarmEnabled do
            task.wait()
            pcall(function()
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart or humanoid.Health <= 0 then return end

                -- Tomar quest si no tiene
                if not questTaken then
                    local questGiver = Workspace.NPCs:FindFirstChild("QuestGiver") or Workspace.NPCs:FindFirstChildWhichIsA("Model")
                    if questGiver then
                        rootPart.CFrame = questGiver.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        task.wait(1)
                        fireclickdetector(questGiver.ClickDetector or questGiver:FindFirstChildOfClass("ClickDetector"))
                        questTaken = true
                        statusLabel.Text = "Estado: Quest tomada"
                    end
                end

                -- Buscar mobs vivos
                local closestMob = nil
                local closestDist = math.huge
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                        local dist = (rootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist and dist < 100 then
                            closestDist = dist
                            closestMob = mob
                        end
                    end
                end

                if closestMob then
                    statusLabel.Text = "Estado: Farmando " .. closestMob.Name
                    rootPart.CFrame = closestMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8)
                    humanoid:EquipTool(player.Backpack:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildWhichIsA("Tool"))
                    task.wait(0.2)
                else
                    statusLabel.Text = "Estado: Esperando mobs..."
                    task.wait(2)
                end
            end)
        end
    end)
end

-- Toggle Auto Farm
farmButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        farmButton.Text = "AUTO FARM: ON"
        farmButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        statusLabel.Text = "Estado: Iniciando farm..."
        startAutoFarm()
    else
        farmButton.Text = "AUTO FARM: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
        statusLabel.Text = "Estado: Detenido"
        questTaken = false
    end
end)

farmButton.TouchTap:Connect(function()
    farmButton.MouseButton1Click:Fire()
end)

-- Anti-AFK
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        VirtualInputManager:SendKeyEvent(true, "Space", false, game)
        task.wait()
        VirtualInputManager:SendKeyEvent(false, "Space", false, game)
    end
end)
