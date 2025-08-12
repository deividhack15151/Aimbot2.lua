--==================================
-- AIMBOT V3 - GUI + MELHORIAS + WALLHACK CONFIGURÁVEL
--==================================

if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DOGAO_RIP V3",
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
    WallhackEnabled = false,
    WallhackMaxDistance = 500, -- Distância configurável wallhack
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

local UserInputService = game:GetService("UserInputService") -- já estava declarado, mas seguro

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DogaoRipGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.Active = true
Frame.Draggable = true

-- Sombra (shadow effect)
local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://3570695787"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(100, 100, 100, 100)

-- Título
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🐶 Dogao RIP V3"
Title.TextColor3 = Color3.fromRGB(255, 180, 60)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextStrokeTransparency = 0.8
Title.TextScaled = true

-- Botão de Minimizar
local minimizeButton = Instance.new("TextButton", Frame)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 18
minimizeButton.BorderSizePixel = 0

-- Botão de Fechar (ocultar GUI)
local closeButton = Instance.new("TextButton", Frame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0

-- Minimizar funcionalidade
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in pairs(Frame:GetChildren()) do
        if child ~= Title and child ~= minimizeButton and child ~= closeButton and child.ClassName ~= "UIListLayout" then
            child.Visible = not isMinimized
        end
    end
end)

-- Ocultar ao clicar em X
closeButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Pressionar tecla Insert para mostrar/ocultar GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)


-- Função para criar Toggle Button estilizado
local function createToggle(name, parent, initialValue, positionY)
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
        if name == "Wallhack" then
            getgenv().Aimbot.WallhackEnabled = toggled
        elseif name == "Team Check" then
            getgenv().Aimbot.TeamCheck = toggled
        elseif name == "Wall Check" then
            getgenv().Aimbot.WallCheck = toggled
        end
    end)
end

-- Função para criar slider para números
local function createSlider(name, parent, min, max, default, positionY, callback)
    local sliderFrame = Instance.new("Frame", parent)
    sliderFrame.Size = UDim2.new(1, -20, 0, 50)
    sliderFrame.Position = UDim2.new(0, 10, 0, positionY)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderFrame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", sliderFrame)
    label.Text = name .. ": " .. tostring(default)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame", sliderFrame)
    slider.Size = UDim2.new(1, -20, 0, 10)
    slider.Position = UDim2.new(0, 10, 0, 30)
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

-- Criar toggles
createToggle("Wallhack", Frame, getgenv().Aimbot.WallhackEnabled, 50)
createToggle("Team Check", Frame, getgenv().Aimbot.TeamCheck, 100)
createToggle("Wall Check", Frame, getgenv().Aimbot.WallCheck, 150)

-- Criar sliders para distâncias
createSlider("Aimbot Max Distance", Frame, 50, 500, getgenv().Aimbot.MaxDistance, 210, function(value)
    getgenv().Aimbot.MaxDistance = value
end)

createSlider("Wallhack Max Distance", Frame, 50, 1000, getgenv().Aimbot.WallhackMaxDistance, 270, function(value)
    getgenv().Aimbot.WallhackMaxDistance = value
end)

-- Priority Button (alternar entre FOV e Distância)
local priorityBtn = Instance.new("TextButton", Frame)
priorityBtn.Size = UDim2.new(1, -20, 0, 40)
priorityBtn.Position = UDim2.new(0, 10, 0, 330)
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
-- WALLHACK MELHORADO LIMITADO DISTÂNCIA CONFIGURÁVEL
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

    if getgenv().Aimbot.WallhackEnabled then
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
                                    local nextPart = joints[i + 1]
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
