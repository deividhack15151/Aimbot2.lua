--==================================
-- AIMBOT V3 - GUI + OTIMIZAÇÕES
--==================================

if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimbot V3",
        Text = "Script carregado com sucesso!",
        Duration = 5
    })
end

-- Serviços do Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================
-- CONFIGURAÇÕES PADRÃO
--==============================
getgenv().Aimbot = {
    Enabled = true,
    TeamCheck = false,
    WallCheck = false,
    AliveCheck = true,
    LockPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    Toggle = false,
    AimSpeed = 0.2,
    Priority = "FOV", -- "FOV" ou "Distância"
    FOV = {
        Radius = 90,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 70, 70),
        Thickness = 1,
        Filled = false,
        Visible = true
    }
}

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = game:GetService("HttpService"):JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
end

--==============================
-- GUI (Interface)
--==============================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Aimbot V3 Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Checkbox exemplo: TeamCheck
local teamCheckButton = Instance.new("TextButton", Frame)
teamCheckButton.Size = UDim2.new(1, -20, 0, 30)
teamCheckButton.Position = UDim2.new(0, 10, 0, 40)
teamCheckButton.Text = "Team Check: OFF"
teamCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.TeamCheck = not getgenv().Aimbot.TeamCheck
    teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
end)

-- (Adicione sliders, dropdowns e outras configs aqui...)

--==============================
-- DESENHO DO FOV
--==============================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = getgenv().Aimbot.FOV.Thickness
fovCircle.Filled = getgenv().Aimbot.FOV.Filled
fovCircle.Radius = getgenv().Aimbot.FOV.Radius

local function updateFOV()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    fovCircle.Visible = getgenv().Aimbot.FOV.Visible
end

--==============================
-- FUNÇÕES DE MIRA
--==============================
local function isAlive(player)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, raycastParams)
    return (not result) or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestTarget()
    local closest = nil
    local shortest = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer 
            and (not getgenv().Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team)
            and (not getgenv().Aimbot.AliveCheck or isAlive(player)) then

            local part = player.Character and player.Character:FindFirstChild(getgenv().Aimbot.LockPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist <= getgenv().Aimbot.FOV.Radius then
                        if not getgenv().Aimbot.WallCheck or isVisible(part) then
                            if getgenv().Aimbot.Priority == "FOV" then
                                if dist < shortest then
                                    shortest = dist
                                    closest = player
                                end
                            else
                                local distance3D = (part.Position - Camera.CFrame.Position).Magnitude
                                if distance3D < shortest then
                                    shortest = distance3D
                                    closest = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

local function aimAt(target)
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(getgenv().Aimbot.LockPart)
    if not part then return end

    local camPos = Camera.CFrame.Position
    local direction = (part.Position - camPos).Unit
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + direction), getgenv().Aimbot.AimSpeed)
end

--==============================
-- LOOP PRINCIPAL
--==============================
local holding = false
local currentTarget = nil

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == getgenv().Aimbot.TriggerKey then
        if getgenv().Aimbot.Toggle then
            getgenv().Aimbot.Enabled = not getgenv().Aimbot.Enabled
        else
            holding = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == getgenv().Aimbot.TriggerKey and not getgenv().Aimbot.Toggle then
        holding = false
    end
end)

-- Atualização do alvo a cada 0.05s
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().Aimbot.Enabled or holding then
            currentTarget = getClosestTarget()
        else
            currentTarget = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    updateFOV()

    if currentTarget then
        fovCircle.Color = getgenv().Aimbot.FOV.LockedColor
        aimAt(currentTarget)
    else
        fovCircle.Color = getgenv().Aimbot.FOV.Color
    end
end)

-- Salvar configurações ao fechar
game:BindToClose(function()
    if writefile then
        writefile(configFile, game:GetService("HttpService"):JSONEncode(getgenv().Aimbot))
    end
end)
