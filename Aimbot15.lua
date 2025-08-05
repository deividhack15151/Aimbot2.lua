--==================================
-- AIMBOT V3 - GUI + MELHORIAS + WALLHACK MELHORADO
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
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================
-- CONFIGURAÇÕES PADRÃO
--==============================
getgenv().Aimbot = {
    Enabled = true,
    TeamCheck = true,
    WallCheck = true,
    AliveCheck = true,
    LockPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    Toggle = false,
    AimSpeed = 0.2,
    Priority = "FOV",
    MaxDistance = 150,
    FOV = {
        Radius = 90,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 70, 70),
        Thickness = 1,
        Filled = false,
        Visible = true
    },
    WallhackEnabled = false
}

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = HttpService:JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
end

--==============================
-- GUI (Interface)
--==============================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 360)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Aimbot V3 Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- TeamCheck
local teamCheckButton = Instance.new("TextButton", Frame)
teamCheckButton.Size = UDim2.new(1, -20, 0, 30)
teamCheckButton.Position = UDim2.new(0, 10, 0, 40)
teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
teamCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.TeamCheck = not getgenv().Aimbot.TeamCheck
    teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
end)

-- WallCheck
local wallCheckButton = Instance.new("TextButton", Frame)
wallCheckButton.Size = UDim2.new(1, -20, 0, 30)
wallCheckButton.Position = UDim2.new(0, 10, 0, 80)
wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
wallCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.WallCheck = not getgenv().Aimbot.WallCheck
    wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
end)

-- Max Distance
local distanceBox = Instance.new("TextBox", Frame)
distanceBox.Size = UDim2.new(1, -20, 0, 30)
distanceBox.Position = UDim2.new(0, 10, 0, 120)
distanceBox.PlaceholderText = "Max Distance (" .. getgenv().Aimbot.MaxDistance .. ")"
distanceBox.Text = ""
distanceBox.FocusLost:Connect(function()
    local val = tonumber(distanceBox.Text)
    if val then
        getgenv().Aimbot.MaxDistance = val
        distanceBox.PlaceholderText = "Max Distance (" .. val .. ")"
    end
end)

-- Priority
local priorityButton = Instance.new("TextButton", Frame)
priorityButton.Size = UDim2.new(1, -20, 0, 30)
priorityButton.Position = UDim2.new(0, 10, 0, 160)
priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
priorityButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.Priority = getgenv().Aimbot.Priority == "FOV" and "Distância" or "FOV"
    priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
end)

-- Wallhack toggle
local wallhackButton = Instance.new("TextButton", Frame)
wallhackButton.Size = UDim2.new(1, -20, 0, 30)
wallhackButton.Position = UDim2.new(0, 10, 0, 200)
wallhackButton.Text = "Wallhack: OFF"
wallhackButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.WallhackEnabled = not getgenv().Aimbot.WallhackEnabled
    wallhackButton.Text = "Wallhack: " .. (getgenv().Aimbot.WallhackEnabled and "ON" or "OFF")
end)

--==============================
-- FOV CIRCLE
--==============================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = getgenv().Aimbot.FOV.Thickness
fovCircle.Filled = getgenv().Aimbot.FOV.Filled
fovCircle.Radius = getgenv().Aimbot.FOV.Radius

local function updateFOV()
    fovCircle.Position = Camera.ViewportSize / 2
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
    local direction = (part.Position - origin)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local ignoreList = {LocalPlayer.Character}

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not v.CanCollide or v.Transparency >= 0.95 or v.Name:lower():find("effect") then
                table.insert(ignoreList, v)
            end
        end
    end

    raycastParams.FilterDescendantsInstances = ignoreList

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
                local distance3D = (part.Position - Camera.CFrame.Position).Magnitude
                if distance3D <= getgenv().Aimbot.MaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distFOV = (Camera.ViewportSize / 2 - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if distFOV <= getgenv().Aimbot.FOV.Radius then
                            if not getgenv().Aimbot.WallCheck or isVisible(part) then
                                local value = getgenv().Aimbot.Priority == "FOV" and distFOV or distance3D
                                if value < shortest then
                                    shortest = value
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
-- WALLHACK MELHORADO
--==============================
local wallhackObjects = {}

local function createWallhackESP(player)
    local esp = {}

    -- Caixa
    esp.box = Drawing.new("Square")
    esp.box.Thickness = 2
    esp.box.Color = Color3.fromRGB(255, 0, 0)
    esp.box.Filled = false
    esp.box.Visible = false

    -- Nome
    esp.name = Drawing.new("Text")
    esp.name.Text = player.Name
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.Size = 14
    esp.name.Center = true
    esp.name.Visible = false

    -- Skeleton (6 linhas)
    esp.skeleton = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Visible = false
        esp.skeleton[i] = line
    end

    return esp
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

    -- WALLHACK VISUAL
    if getgenv().Aimbot.WallhackEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and isAlive(player) and player.Team ~= LocalPlayer.Team then
                if not wallhackObjects[player] then
                    wallhackObjects[player] = createWallhackESP(player)
                end

                local esp = wallhackObjects[player]
                local char = player.Character

                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")

                if hrp and head and torso then
                    local rootPos, onScreenRoot = Camera:WorldToViewportPoint(hrp.Position)
                    local headPos, onScreenHead = Camera:WorldToViewportPoint(head.Position)
                    local torsoPos, onScreenTorso = Camera:WorldToViewportPoint(torso.Position)

                    if onScreenRoot and onScreenHead and onScreenTorso then
                        local height = (headPos.Y - rootPos.Y) * -1
                        local width = height / 2

                        esp.box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height)
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Visible = true

                        esp.name.Position = Vector2.new(rootPos.X, rootPos.Y - height - 15)
                        esp.name.Visible = true

                        local joints = {
                            head,
                            torso,
                            char:FindFirstChild("LeftUpperArm"),
                            char:FindFirstChild("RightUpperArm"),
                            char:FindFirstChild("LeftUpperLeg"),
                            char:FindFirstChild("RightUpperLeg"),
                        }

                        for i, part in ipairs(joints) do
                            local nextPart = (i == 1) and joints[2] or nil
                            if part and nextPart then
                                local p1 = Camera:WorldToViewportPoint(part.Position)
                                local p2 = Camera:WorldToViewportPoint(nextPart.Position)
                                esp.skeleton[i].From = Vector2.new(p1.X, p1.Y)
                                esp.skeleton[i].To = Vector2.new(p2.X, p2.Y)
                                esp.skeleton[i].Visible = true
                            else
                                esp.skeleton[i].Visible = false
                            end
                        end
                    else
                        esp.box.Visible = false
                        esp.name.Visible = false
                        for _, line in ipairs(esp.skeleton) do
                            line.Visible = false
                        end
                    end
                else
                    esp.box.Visible = false
                    esp.name.Visible = false
                    for _, line in ipairs(esp.skeleton) do
                        line.Visible = false
                    end
                end
            elseif wallhackObjects[player] then
                local esp = wallhackObjects[player]
                esp.box.Visible = false
                esp.name.Visible = false
                for _, line in ipairs(esp.skeleton) do
                    line.Visible = false
                end
            end
        end
    else
        for _, esp in pairs(wallhackObjects) do
            esp.box.Visible = false
            esp.name.Visible = false
            for _, line in ipairs(esp.skeleton) do
                line.Visible = false
            end
        end
    end
end)

-- Salvar configurações ao fechar
game:BindToClose(function()
    if writefile then
        writefile(configFile, HttpService:JSONEncode(getgenv().Aimbot))
    end
end)
