--==================================
-- AIMBOT V3 + SPEED MOD + WALLHACK
--==================================

if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DOGAO_RIP V3",
        Text = "Script carregado com sucesso!",
        Duration = 5
    })
end

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
    WallhackEnabled = false,
    WallhackMaxDistance = 500,
}

-- Config Speed Mod (corrida rápida)
getgenv().SpeedMod = {
    Enabled = false,
    DefaultWalkSpeed = 16,
    Multiplier = 5 -- Multiplicador padrão (5x rápido)
}

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = HttpService:JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
    if data.SpeedMod then
        getgenv().SpeedMod = data.SpeedMod
    end
end

--==============================
-- GUI (Interface)
--==============================

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DogaoRipGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 450)
Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🐶 Dogao RIP V3"
Title.TextColor3 = Color3.fromRGB(255, 180, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextStrokeTransparency = 0.8
Title.TextScaled = true

-- Botões minimizar e fechar (igual no seu script original)
local minimizeButton = Instance.new("TextButton", Frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 18
minimizeButton.BorderSizePixel = 0

local closeButton = Instance.new("TextButton", Frame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in pairs(Frame:GetChildren()) do
        if child ~= Title and child ~= minimizeButton and child ~= closeButton and child.ClassName ~= "UIListLayout" then
            child.Visible = not isMinimized
        end
    end
end)

closeButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Funções para criar toggles e sliders, adaptadas para SpeedMod e Aimbot

local function createToggle(name, parent, initialValue, positionY, callback)
    local btnFrame = Instance.new("Frame", parent)
    btnFrame.Size = UDim2.new(1, -20, 0, 40)
    btnFrame.Position = UDim2.new(0, 10, 0, positionY)
    btnFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btnFrame.BorderSizePixel = 0
    btnFrame.ClipsDescendants = true

    local label = Instance.new("TextLabel", btnFrame)
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", btnFrame)
    toggleBtn.Size = UDim2.new(0, 50, 0, 30)
    toggleBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
    toggleBtn.BackgroundColor3 = initialValue and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
    toggleBtn.Text = initialValue and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 16
    toggleBtn.AutoButtonColor = false
    toggleBtn.ClipsDescendants = true

    toggleBtn.MouseEnter:Connect(function()
        toggleBtn.BackgroundColor3 = initialValue and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(150, 40, 40)
    end)
    toggleBtn.MouseLeave:Connect(function()
        toggleBtn.BackgroundColor3 = initialValue and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
    end)

    local toggled = initialValue
    toggleBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
        toggleBtn.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)
end
local function createSlider(name, parent, min, max, default, positionY, callback)
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = UDim2.new(1, -20, 0, 35) -- diminui altura de 50 para 35
    sliderFrame.Position = UDim2.new(0, 10, 0, positionY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderFrame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", sliderFrame)
    label.Text = name .. ": " .. tostring(default)
    label.Size = UDim2.new(1, 0, 0, 18) -- diminui altura do texto
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14 -- reduz um pouco o texto
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame", sliderFrame)
    slider.Size = UDim2.new(1, -20, 0, 8) -- diminui altura do slider
    slider.Position = UDim2.new(0, 10, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    slider.BorderSizePixel = 0

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    fill.BorderSizePixel = 0

    local function updateValue(x)
        local relativeX = math.clamp(x - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
        local percent = relativeX / slider.AbsoluteSize.X
        local value = math.floor(min + percent * (max - min))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. tostring(value)
        callback(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input.Position.X)
            local conn
            conn = UserInputService.InputChanged:Connect(function(inputMove)
                if inputMove.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(inputMove.Position.X)
                end
            end)
            UserInputService.InputEnded:Wait()
            conn:Disconnect()
        end
    end)

    slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            updateValue(input.Position.X)
        end
    end)
end

-- Criar toggles do Aimbot
createToggle("Wallhack", Frame, getgenv().Aimbot.WallhackEnabled, 50, function(value)
    getgenv().Aimbot.WallhackEnabled = value
end)

createToggle("Team Check", Frame, getgenv().Aimbot.TeamCheck, 100, function(value)
    getgenv().Aimbot.TeamCheck = value
end)

createToggle("Wall Check", Frame, getgenv().Aimbot.WallCheck, 150, function(value)
    getgenv().Aimbot.WallCheck = value
end)

-- Toggle e slider para Speed Mod
createToggle("Speed Mod", Frame, getgenv().SpeedMod.Enabled, 200, function(value)
    getgenv().SpeedMod.Enabled = value
end)

createSlider("Speed Multiplier", Frame, 1, 20, getgenv().SpeedMod.Multiplier, 260, function(value)
    getgenv().SpeedMod.Multiplier = value
end)

-- Slider para Aimbot e Wallhack distâncias
createSlider("Aimbot Max Distance", Frame, 50, 500, getgenv().Aimbot.MaxDistance, 320, function(value)
    getgenv().Aimbot.MaxDistance = value
end)

createSlider("Wallhack Max Distance", Frame, 50, 1000, getgenv().Aimbot.WallhackMaxDistance, 380, function(value)
    getgenv().Aimbot.WallhackMaxDistance = value
end)

-- Botão de prioridade
local priorityBtn = Instance.new("TextButton", Frame)
priorityBtn.Size = UDim2.new(1, -20, 0, 40)
priorityBtn.Position = UDim2.new(0, 10, 0, 440)
priorityBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
priorityBtn.BorderSizePixel = 0
priorityBtn.TextColor3 = Color3.fromRGB(255, 180, 60)
priorityBtn.Font = Enum.Font.GothamBold
priorityBtn.TextSize = 18
priorityBtn.Text = "Prioridade: " .. getgenv().Aimbot.Priority
priorityBtn.MouseButton1Click:Connect(function()
    if getgenv().Aimbot.Priority == "FOV" then
        getgenv().Aimbot.Priority = "Distância"
    else
        getgenv().Aimbot.Priority = "FOV"
    end
    priorityBtn.Text = "Prioridade: " .. getgenv().Aimbot.Priority
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
-- FUNÇÕES DE MIRA E WALLHACK
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

local wallhackObjects = {}

local function createWallhackESP(player)
    local esp = {}

    esp.box = Drawing.new("Square")
    esp.box.Thickness = 2
    esp.box.Color = Color3.fromRGB(255, 0, 0)
    esp.box.Filled = false
    esp.box.Visible = false

    esp.name = Drawing.new("Text")
    esp.name.Text = player.Name
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.Size = 14
    esp.name.Center = true
    esp.name.Visible = false

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

local function updateWallhack()
    if not getgenv().Aimbot.WallhackEnabled then
        for player, esp in pairs(wallhackObjects) do
            esp.box.Visible = false
            esp.name.Visible = false
            for _, line in ipairs(esp.skeleton) do
                line.Visible = false
            end
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isAlive(player) and player.Team ~= LocalPlayer.Team then
            local part = player.Character:FindFirstChild(getgenv().Aimbot.LockPart)
            if part then
                local dist = (part.Position - Camera.CFrame.Position).Magnitude
                if dist <= getgenv().Aimbot.WallhackMaxDistance then
                    if not wallhackObjects[player] then
                        wallhackObjects[player] = createWallhackESP(player)
                    end

                    local esp = wallhackObjects[player]
                    local char = player.Character

                    local p1, visible1 = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position + Vector3.new(-1, 3, 0))
                    local p2, visible2 = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position + Vector3.new(1, 3, 0))
                    local p3, visible3 = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position + Vector3.new(1, 0, 0))
                    local p4, visible4 = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position + Vector3.new(-1, 0, 0))
                    local onScreen = visible1 and visible2 and visible3 and visible4

                    if onScreen then
                        local pos1 = Vector2.new(p1.X, p1.Y)
                        local pos2 = Vector2.new(p2.X, p2.Y)
                        local pos3 = Vector2.new(p3.X, p3.Y)
                        local pos4 = Vector2.new(p4.X, p4.Y)

                        esp.box.Visible = true
                        esp.box.Color = Color3.fromRGB(255, 0, 0)
                        local width = (pos2 - pos1).Magnitude
                        local height = (pos4 - pos1).Magnitude
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Position = pos1

                        esp.name.Visible = true
                        esp.name.Position = Vector2.new((pos1.X + pos2.X) / 2, pos1.Y - 15)
                        esp.name.Text = player.Name

                        for i, line in ipairs(esp.skeleton) do
                            line.Visible = false -- simplificado, para não complicar aqui
                        end
                    else
                        esp.box.Visible = false
                        esp.name.Visible = false
                        for _, line in ipairs(esp.skeleton) do
                            line.Visible = false
                        end
                    end
                else
                    if wallhackObjects[player] then
                        local esp = wallhackObjects[player]
                        esp.box.Visible = false
                        esp.name.Visible = false
                        for _, line in ipairs(esp.skeleton) do
                            line.Visible = false
                        end
                    end
                end
            end
        end
    end
end

--==============================
-- SPEED MOD - Corrida rápida
--==============================
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if getgenv().SpeedMod.Enabled then
            humanoid.WalkSpeed = getgenv().SpeedMod.DefaultWalkSpeed * getgenv().SpeedMod.Multiplier
        else
            humanoid.WalkSpeed = getgenv().SpeedMod.DefaultWalkSpeed
        end
    end
end)

--==============================
-- LOOP PRINCIPAL
--==============================
RunService.RenderStepped:Connect(function()
    updateFOV()
    updateWallhack()

    if getgenv().Aimbot.Enabled and getgenv().Aimbot.Toggle and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        aimAt(target)
    end
end)

-- Atalhos para ativar/desativar o aimbot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        getgenv().Aimbot.Toggle = true
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        getgenv().Aimbot.Enabled = not getgenv().Aimbot.Enabled
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        getgenv().Aimbot.Toggle = false
    end
end)

-- Salvar configurações
local function saveConfig()
    local toSave = {
        Aimbot = getgenv().Aimbot,
        SpeedMod = getgenv().SpeedMod
    }
    if writefile then
        writefile(configFile, HttpService:JSONEncode(toSave))
    end
end

-- Salvar automaticamente a cada 30s
while task.wait(30) do
    saveConfig()
end
