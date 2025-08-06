--==================================
-- AIMBOT V3 - GUI + SPEED MOD + WALLHACK CONFIGURÁVEL
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

getgenv().SpeedMod = {
    Enabled = false,
    DefaultWalkSpeed = 16,
    Multiplier = 1,
}

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = HttpService:JSONDecode(readfile(configFile))
    if data.Aimbot then
        for k, v in pairs(data.Aimbot) do getgenv().Aimbot[k] = v end
    end
    if data.SpeedMod then
        for k, v in pairs(data.SpeedMod) do getgenv().SpeedMod[k] = v end
    end
end

--==============================
-- GUI
--==============================

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DogaoRipGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 450)
Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://3570695787"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(100, 100, 100, 100)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🐶 Dogao RIP V3"
Title.TextColor3 = Color3.fromRGB(255, 180, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextStrokeTransparency = 0.8
Title.TextScaled = true

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

-- Funções para criar toggles e sliders
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
    sliderFrame.Size = UDim2.new(1, -20, 0, 35)
    sliderFrame.Position = UDim2.new(0, 10, 0, positionY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderFrame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", sliderFrame)
    label.Text = name .. ": " .. tostring(default)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame", sliderFrame)
    slider.Size = UDim2.new(1, -20, 0, 8)
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

-- Toggles do aimbot
createToggle("Wallhack", Frame, getgenv().Aimbot.WallhackEnabled, 50, function(value)
    getgenv().Aimbot.WallhackEnabled = value
end)

createToggle("Team Check", Frame, getgenv().Aimbot.TeamCheck, 100, function(value)
    getgenv().Aimbot.TeamCheck = value
end)

createToggle("Wall Check", Frame, getgenv().Aimbot.WallCheck, 150, function(value)
    getgenv().Aimbot.WallCheck = value
end)

-- Slider para aimbot MaxDistance
createSlider("Aimbot Max Distance", Frame, 50, 500, getgenv().Aimbot.MaxDistance, 210, function(value)
    getgenv().Aimbot.MaxDistance = value
end)

-- Slider para Wallhack MaxDistance
createSlider("Wallhack Max Distance", Frame, 50, 1000, getgenv().Aimbot.WallhackMaxDistance, 260, function(value)
    getgenv().Aimbot.WallhackMaxDistance = value
end)

-- Prioridade FOV / Distância
local priorityBtn = Instance.new("TextButton", Frame)
priorityBtn.Size = UDim2.new(1, -20, 0, 40)
priorityBtn.Position = UDim2.new(0, 10, 0, 310)
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

-- Speed Mod Toggle
createToggle("Speed Mod", Frame, getgenv().SpeedMod.Enabled, 360, function(value)
    getgenv().SpeedMod.Enabled = value
end)

-- Speed Multiplier Slider (1x até 50x ~ 750 WalkSpeed)
createSlider("Speed Multiplier", Frame, 1, 50, getgenv().SpeedMod.Multiplier, 410, function(value)
    getgenv().SpeedMod.Multiplier = value
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
-- WALLHACK ESP (simplificado)
--==============================
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
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isAlive(player) and (not getgenv().Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local part = player.Character:FindFirstChild(getgenv().Aimbot.LockPart)
            if part and (player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude <= getgenv().Aimbot.WallhackMaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    if not wallhackObjects[player] then
                        wallhackObjects[player] = createWallhackESP(player)
                    end
                    local esp = wallhackObjects[player]
                    local size = 50 -- Ajuste do tamanho do box (pode melhorar calculo)

                    esp.box.Size = size
                    esp.box.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
                    esp.box.Visible = getgenv().Aimbot.WallhackEnabled

                    esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - size/2 - 15)
                    esp.name.Visible = getgenv().Aimbot.WallhackEnabled
                else
                    if wallhackObjects[player] then
                        wallhackObjects[player].box.Visible = false
                        wallhackObjects[player].name.Visible = false
                    end
                end
            else
                if wallhackObjects[player] then
                    wallhackObjects[player].box.Visible = false
                    wallhackObjects[player].name.Visible = false
                end
            end
        end
    end
end

--==============================
-- SPEED MOD
--==============================

-- Atualiza a velocidade do jogador conforme multiplicador
local function updateSpeed()
    if getgenv().SpeedMod.Enabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().SpeedMod.DefaultWalkSpeed * getgenv().SpeedMod.Multiplier
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().SpeedMod.DefaultWalkSpeed
    end
end

-- Atualiza velocidade ao spawnar
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = getgenv().SpeedMod.DefaultWalkSpeed
    wait(0.1)
    updateSpeed()
end)

--==============================
-- MAIN LOOP
--==============================

RunService.RenderStepped:Connect(function()
    if ScreenGui.Enabled then
        updateFOV()
        updateWallhack()
        updateSpeed()

        if getgenv().Aimbot.Enabled and getgenv().Aimbot.Toggle then
            local target = getClosestTarget()
            aimAt(target)
        end
    end
end)

--==============================
-- KEYBINDS
--==============================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == getgenv().Aimbot.TriggerKey then
        getgenv().Aimbot.Toggle = true
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        getgenv().Aimbot.Enabled = not getgenv().Aimbot.Enabled
        print("Aimbot Enabled: ", getgenv().Aimbot.Enabled)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == getgenv().Aimbot.TriggerKey then
        getgenv().Aimbot.Toggle = false
    end
end)
