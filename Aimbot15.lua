--==================================
-- AIMBOT V3 - GUI + MELHORIAS
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
    TeamCheck = true, -- Ativado por padrão
    WallCheck = true,
    AliveCheck = true,
    LockPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    Toggle = false,
    AimSpeed = 0.2,
    Priority = "FOV", -- "FOV" ou "Distância"
    MaxDistance = 150,
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
    local data = HttpService:JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
end

--==============================
-- GUI (Interface)
--==============================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 320)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Aimbot V3 Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Checkbox TeamCheck
local teamCheckButton = Instance.new("TextButton", Frame)
teamCheckButton.Size = UDim2.new(1, -20, 0, 30)
teamCheckButton.Position = UDim2.new(0, 10, 0, 40)
teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
teamCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.TeamCheck = not getgenv().Aimbot.TeamCheck
    teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
end)

-- Checkbox WallCheck
local wallCheckButton = Instance.new("TextButton", Frame)
wallCheckButton.Size = UDim2.new(1, -20, 0, 30)
wallCheckButton.Position = UDim2.new(0, 10, 0, 80)
wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
wallCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.WallCheck = not getgenv().Aimbot.WallCheck
    wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
end)

-- Distância máxima (slider simples)
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

-- Prioridade dropdown
local priorityButton = Instance.new("TextButton", Frame)
priorityButton.Size = UDim2.new(1, -20, 0, 30)
priorityButton.Position = UDim2.new(0, 10, 0, 160)
priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
priorityButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.Priority = getgenv().Aimbot.Priority == "FOV" and "Distância" or "FOV"
    priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
end)

--==============================
-- DESENHO DO FOV
--==============================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = getgenv().Aimbot.FOV.Thickness
fovCircle.Filled = getgenv().Aimbot.FOV.Filled
fovCircle.Radius = getgenv().Aimbot.FOV.Radius

local function updateFOV()
    fovCircle.Position = Camera.ViewportSize / 2 -- Mira centralizada
    fovCircle.Visible = getgenv().Aimbot.FOV.Visible
end

--==============================
-- FUNÇÕES DE MIRA
--==============================
local function isAlive(player)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- WallCheck aprimorado
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

-- Busca o jogador mais próximo
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
        writefile(configFile, HttpService:JSONEncode(getgenv().Aimbot))
    end
end)

-- esp hack

--==============================
-- ESP VISUAL (BOX, LINHA, SKELETON)
--==============================
local function createRGBColor()
    local r = math.abs(math.sin(tick() * 2)) * 255
    local g = math.abs(math.sin(tick() * 2 + 2)) * 255
    local b = math.abs(math.sin(tick() * 2 + 4)) * 255
    return Color3.fromRGB(r, g, b)
end

local function createESPForPlayer(player)
    local esp = {}

    esp.box = Drawing.new("Square")
    esp.box.Thickness = 1.5
    esp.box.Filled = false

    esp.line = Drawing.new("Line")
    esp.line.Thickness = 1

    -- Skeleton (exemplo simplificado com cabeça, torso, braços)
    esp.skeleton = {}

    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        esp.skeleton[i] = line
    end

    return esp
end

local espObjects = {}

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local alive = not getgenv().Aimbot.AliveCheck or isAlive(player)
            local notTeam = not getgenv().Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team

            if alive and notTeam then
                if not espObjects[player] then
                    espObjects[player] = createESPForPlayer(player)
                end

                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local color = createRGBColor()

                    -- Caixa
                    local sizeY = 3
                    local height = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, sizeY, 0)).Y - rootPos.Y)
                    local width = height / 1.5

                    espObjects[player].box.Visible = true
                    espObjects[player].box.Color = color
                    espObjects[player].box.Size = Vector2.new(width, -height)
                    espObjects[player].box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y)

                    -- Linha até o chão
                    espObjects[player].line.Visible = true
                    espObjects[player].line.Color = color
                    espObjects[player].line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espObjects[player].line.To = Vector2.new(rootPos.X, rootPos.Y + height / 2)

                    -- Skeleton simplificado
                    local joints = {
                        char:FindFirstChild("Head"),
                        char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
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
                            espObjects[player].skeleton[i].From = Vector2.new(p1.X, p1.Y)
                            espObjects[player].skeleton[i].To = Vector2.new(p2.X, p2.Y)
                            espObjects[player].skeleton[i].Color = color
                            espObjects[player].skeleton[i].Visible = true
                        else
                            espObjects[player].skeleton[i].Visible = false
                        end
                    end
                else
                    -- Desativa se não está na tela
                    if espObjects[player] then
                        espObjects[player].box.Visible = false
                        espObjects[player].line.Visible = false
                        for _, part in ipairs(espObjects[player].skeleton) do
                            part.Visible = false
                        end
                    end
                end
            else
                -- Desativa se está morto ou aliado
                if espObjects[player] then
                    espObjects[player].box.Visible = false
                    espObjects[player].line.Visible = false
                    for _, part in ipairs(espObjects[player].skeleton) do
                        part.Visible = false
                    end
                end
            end
        elseif espObjects[player] then
            -- Remove objetos de jogadores que saíram
            for _, obj in pairs(espObjects[player]) do
                if typeof(obj) == "table" then
                    for _, sub in pairs(obj) do
                        sub:Remove()
                    end
                else
                    obj:Remove()
                end
            end
            espObjects[player] = nil
        end
    end
end)
game:BindToClose(function()

