--==================================
-- AIMBOT V3 - GUI MODERNA + MELHORIAS + WALLHACK CONFIGURÁVEL
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

local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = HttpService:JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
end

--==============================
-- GUI MODERNA
--==============================

-- Remove GUI antiga
if game.CoreGui:FindFirstChild("DogaoRipGui") then
    game.CoreGui.DogaoRipGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DogaoRipGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 440)
Frame.Position = UDim2.new(0.02, 0, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Shadow = Instance.new("ImageLabel", Frame)
Shadow.Size = UDim2.new(1, 15, 1, 15)
Shadow.Position = UDim2.new(0, -7, 0, -7)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://3570695787"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.75
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(100, 100, 100, 100)
Shadow.ZIndex = 0

local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
TitleBar.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Text = "🐶 Dogao RIP V3"
TitleText.TextColor3 = Color3.fromRGB(255, 180, 60)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 24
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
CloseBtn.Name = "CloseButton"

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 40, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -90, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 28
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
MinimizeBtn.Name = "MinimizeButton"

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = MinimizeBtn

MinimizeBtn.MouseEnter:Connect(function()
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
end)
MinimizeBtn.MouseLeave:Connect(function()
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    for _, child in ipairs(Frame:GetChildren()) do
        if child ~= TitleBar and child.Name ~= "Shadow" then
            child.Visible = not isMinimized
        end
    end
    Frame.Size = isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 440)
end)

local ContentFrame = Instance.new("ScrollingFrame", Frame)
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
ContentFrame.ScrollBarThickness = 8
ContentFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout", ContentFrame)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 12)

local function createToggle(name, initialValue)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Name = name .. "Toggle"
    toggleFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleFrame

    local label = Instance.new("TextLabel", toggleFrame)
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", toggleFrame)
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0, 7)
    btn.BackgroundColor3 = initialValue and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
    btn.Text = initialValue and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.AutoButtonColor = false
    btn.Name = "ToggleButton"

    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 8)
    cornerBtn.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = initialValue and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(150, 40, 40)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = initialValue and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
    end)

    return toggleFrame, btn
end

local function createSlider(name, min, max, default, onChange)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = sliderFrame

    local label = Instance.new("TextLabel", sliderFrame)
    label.Text = string.format("%s: %d", name, default)
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Gotham
    label.TextSize = 17
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBar = Instance.new("Frame", sliderFrame)
    sliderBar.Size = UDim2.new(1, -30, 0, 10)
    sliderBar.Position = UDim2.new(0, 15, 0, 35)
    sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    sliderBar.BorderSizePixel = 0
    sliderBar.ClipsDescendants = true

    local sliderFill = Instance.new("Frame", sliderBar)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    sliderFill.BorderSizePixel = 0

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFill

    local dragging = false

    local function updateSlider(x)
        local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
        local percent = relativeX / sliderBar.AbsoluteSize.X
        local value = math.floor(min + percent * (max - min))
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = string.format("%s: %d", name, value)
        onChange(value)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return sliderFrame
end

-- Criar controles e adicionar ao ContentFrame
local toggles = {
    {"Wallhack", getgenv().Aimbot.WallhackEnabled, function(val) getgenv().Aimbot.WallhackEnabled = val end},
    {"Team Check", getgenv().Aimbot.TeamCheck, function(val) getgenv().Aimbot.TeamCheck = val end},
    {"Wall Check", getgenv().Aimbot.WallCheck, function(val) getgenv().Aimbot.WallCheck = val end},
}

local y = 10
for i, t in ipairs(toggles) do
    local frame, btn = createToggle(t[1], ContentFrame, t[2])
    frame.Parent = ContentFrame
    btn.MouseButton1Click:Connect(function()
        local newVal = btn.Text == "OFF"
        btn.BackgroundColor3 = newVal and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(180, 60, 60)
        btn.Text = newVal and "ON" or "OFF"
        t[3](newVal)
    end)
end

local maxDistanceSlider = createSlider("Aimbot Max Distance", 50, 500, getgenv().Aimbot.MaxDistance, function(value)
    getgenv().Aimbot.MaxDistance = value
end)
maxDistanceSlider.Parent = ContentFrame

local wallhackDistanceSlider = createSlider("Wallhack Max Distance", 50, 1000, getgenv().Aimbot.WallhackMaxDistance, function(value)
    getgenv().Aimbot.WallhackMaxDistance = value
end)
wallhackDistanceSlider.Parent = ContentFrame

local priorityBtn = Instance.new("TextButton")
priorityBtn.Size = UDim2.new(1, 0, 0, 45)
priorityBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
priorityBtn.BorderSizePixel = 0
priorityBtn.Font = Enum.Font.GothamBold
priorityBtn.TextSize = 20
priorityBtn.TextColor3 = Color3.fromRGB(255, 180, 60)
priorityBtn.Text = "Prioridade: " .. getgenv().Aimbot.Priority
priorityBtn.ClipsDescendants = true

local cornerPriority = Instance.new("UICorner")
cornerPriority.CornerRadius = UDim.new(0, 8)
cornerPriority.Parent = priorityBtn

priorityBtn.MouseEnter:Connect(function()
    priorityBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)
priorityBtn.MouseLeave:Connect(function()
    priorityBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
end)

priorityBtn.MouseButton1Click:Connect(function()
    if getgenv().Aimbot.Priority == "FOV" then
        getgenv().Aimbot.Priority = "Distância"
    else
        getgenv().Aimbot.Priority = "FOV"
    end
    priorityBtn.Text = "Prioridade: " .. getgenv().Aimbot.Priority
end)

priorityBtn.Parent = ContentFrame

-- Atualizar canvas size para scroll
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
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
-- FUNÇÕES DE MIRA (igual ao seu original)
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

-- Atalho para mostrar/ocultar GUI com Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
