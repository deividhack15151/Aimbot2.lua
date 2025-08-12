--==================================
-- AIMBOT V3 - GUI MODERNA (UI REFEITA)
-- Mantive todas as funções originais (aimbot + wallhack).
-- Só troquei a interface por um menu moderno com abas.
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
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--==============================
-- CONFIGURAÇÕES PADRÃO (mantive suas defaults)
--==============================
getgenv().Aimbot = getgenv().Aimbot or {
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

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(configFile))
    end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do getgenv().Aimbot[k] = v end
    end
end

-- ==============================
-- FUNÇÕES DE MIRA e WALLHACK (mantidas)
-- ==============================
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

-- Wallhack structures (Drawing)
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

-- FOV Circle (Drawing)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = getgenv().Aimbot.FOV.Thickness
fovCircle.Filled = getgenv().Aimbot.FOV.Filled
fovCircle.Radius = getgenv().Aimbot.FOV.Radius

local function updateFOV()
    fovCircle.Position = Camera.ViewportSize / 2
    fovCircle.Visible = getgenv().Aimbot.FOV.Visible
end

-- Loop de atualização dos alvos
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

--==============================
-- NOVA UI MODERNA (MENU LATERAL + ABAS)
--==============================
-- Limpa GUI antiga caso exista
pcall(function()
    if game.CoreGui:FindFirstChild("DogaoRipGui") then
        game.CoreGui:FindFirstChild("DogaoRipGui"):Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DogaoRipGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Root frame
local Root = Instance.new("Frame", ScreenGui)
Root.AnchorPoint = Vector2.new(0, 0)
Root.Position = UDim2.new(0.02, 0, 0.12, 0)
Root.Size = UDim2.new(0, 420, 0, 420)
Root.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
Root.BorderSizePixel = 0
Root.ClipsDescendants = true
Root.Name = "Root"
Root.Active = true
Root.Draggable = true
Root.AutoButtonColor = false
Root.Selectable = false
Root.ZIndex = 2
Root.BackgroundTransparency = 0

-- Outer shadow (subtle)
local OuterShadow = Instance.new("ImageLabel", Root)
OuterShadow.Size = UDim2.new(1, 10, 1, 10)
OuterShadow.Position = UDim2.new(0, -5, 0, -5)
OuterShadow.BackgroundTransparency = 1
OuterShadow.Image = "rbxassetid://3570695787"
OuterShadow.ImageColor3 = Color3.new(0, 0, 0)
OuterShadow.ImageTransparency = 0.75
OuterShadow.ScaleType = Enum.ScaleType.Slice
OuterShadow.SliceCenter = Rect.new(100, 100, 100, 100)
OuterShadow.ZIndex = 1

-- Header
local Header = Instance.new("Frame", Root)
Header.Size = UDim2.new(1, 0, 0, 64)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐶 Dogao RIP V3"
Title.TextColor3 = Color3.fromRGB(230, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextYAlignment = Enum.TextYAlignment.Center

-- Small version text
local Version = Instance.new("TextLabel", Header)
Version.Size = UDim2.new(0.38, -16, 1, 0)
Version.Position = UDim2.new(0.6, 8, 0, 0)
Version.BackgroundTransparency = 1
Version.Text = "UI Moderna • by ChatGPT"
Version.TextColor3 = Color3.fromRGB(150, 150, 170)
Version.Font = Enum.Font.Gotham
Version.TextSize = 13
Version.TextXAlignment = Enum.TextXAlignment.Right
Version.TextYAlignment = Enum.TextYAlignment.Center

-- Close & Minimize buttons (modern)
local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0, 28, 0, 28)
BtnClose.Position = UDim2.new(1, -36, 0, 18)
BtnClose.Text = "✕"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 16
BtnClose.TextColor3 = Color3.fromRGB(255,255,255)
BtnClose.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
BtnClose.BorderSizePixel = 0
BtnClose.AutoButtonColor = false
BtnClose.ZIndex = 3

local BtnMin = Instance.new("TextButton", Header)
BtnMin.Size = UDim2.new(0, 28, 0, 28)
BtnMin.Position = UDim2.new(1, -72, 0, 18)
BtnMin.Text = "—"
BtnMin.Font = Enum.Font.GothamBold
BtnMin.TextSize = 16
BtnMin.TextColor3 = Color3.fromRGB(255,255,255)
BtnMin.BackgroundColor3 = Color3.fromRGB(80, 80, 96)
BtnMin.BorderSizePixel = 0
BtnMin.AutoButtonColor = false
BtnMin.ZIndex = 3

-- Sidebar
local Sidebar = Instance.new("Frame", Root)
Sidebar.Size = UDim2.new(0, 120, 0, 356)
Sidebar.Position = UDim2.new(0, 12, 0, 64)
Sidebar.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Name = "Sidebar"

-- Sidebar rounded top decoration
local SidebarTop = Instance.new("Frame", Sidebar)
SidebarTop.Size = UDim2.new(1, 0, 0, 8)
SidebarTop.Position = UDim2.new(0, 0, 0, 0)
SidebarTop.BackgroundTransparency = 1

-- Menu buttons (icons + label)
local function createMenuButton(text, y)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -12, 0, 44)
    btn.Position = UDim2.new(0, 6, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(36, 38, 44)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Name = text .. "Btn"
    btn.ClipsDescendants = true

    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(0, 34, 0, 34)
    icon.Position = UDim2.new(0, 6, 0, 5)
    icon.BackgroundTransparency = 1
    icon.Text = text:sub(1,1)
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.TextColor3 = Color3.fromRGB(200,200,255)
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.TextYAlignment = Enum.TextYAlignment.Center

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -46, 1, 0)
    lbl.Position = UDim2.new(0, 46, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    return btn
end

local btnAimbot = createMenuButton("Aimbot", 16)
local btnWallhack = createMenuButton("Wallhack", 70)
local btnConfig = createMenuButton("Config", 124)

-- Content area
local Content = Instance.new("Frame", Root)
Content.Size = UDim2.new(1, -152, 0, 356)
Content.Position = UDim2.new(0, 140, 0, 64)
Content.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
Content.BorderSizePixel = 0
Content.ClipsDescendants = true

-- Utility to create a panel for each tab
local function createPanel(name)
    local panel = Instance.new("Frame", Content)
    panel.Size = UDim2.new(1, -24, 1, -24)
    panel.Position = UDim2.new(0, 12, 0, 12)
    panel.BackgroundTransparency = 1
    panel.Visible = false
    panel.Name = name .. "Panel"
    return panel
end

local panelAimbot = createPanel("Aimbot")
local panelWallhack = createPanel("Wallhack")
local panelConfig = createPanel("Config")

-- Title for panels
local function panelTitle(panel, text)
    local t = Instance.new("TextLabel", panel)
    t.Size = UDim2.new(1, 0, 0, 26)
    t.Position = UDim2.new(0, 0, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 16
    t.TextColor3 = Color3.fromRGB(220,220,255)
    t.TextXAlignment = Enum.TextXAlignment.Left
end

panelTitle(panelAimbot, "Aimbot Settings")
panelTitle(panelWallhack, "Wallhack Settings")
panelTitle(panelConfig, "General Config")

-- Modern switch (toggle) factory
local function createSwitch(parent, labelText, initial, posY, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 44)
    container.Position = UDim2.new(0, 0, 0, posY)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.66, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switchBG = Instance.new("Frame", container)
    switchBG.Size = UDim2.new(0, 56, 0, 28)
    switchBG.Position = UDim2.new(1, -72, 0, 8)
    switchBG.BackgroundColor3 = initial and Color3.fromRGB(110, 80, 230) or Color3.fromRGB(70, 70, 80)
    switchBG.BorderSizePixel = 0
    switchBG.ClipsDescendants = true
    switchBG.AnchorPoint = Vector2.new(0,0)

    local switchCircle = Instance.new("Frame", switchBG)
    switchCircle.Size = UDim2.new(0, 24, 0, 24)
    switchCircle.Position = initial and UDim2.new(1, -28, 0, 2) or UDim2.new(0, 4/56, 0, 2)
    switchCircle.BackgroundColor3 = Color3.fromRGB(240,240,255)
    switchCircle.BorderSizePixel = 0
    switchCircle.Name = "Circle"
    switchCircle.AnchorPoint = Vector2.new(0,0)
    switchCircle.Rotation = 0
    switchCircle.ClipsDescendants = true
    switchCircle.ZIndex = 4
    switchCircle.Visible = true
    switchCircle.BackgroundTransparency = 0
    switchCircle.AutomaticSize = Enum.AutomaticSize.None
    switchCircle.Size = UDim2.new(0, 24, 0, 24)
    switchCircle.Position = initial and UDim2.new(1, -28, 0, 2) or UDim2.new(0, 4/56, 0, 2)

    -- Round corners (UICorner)
    local corner1 = Instance.new("UICorner", switchBG)
    corner1.CornerRadius = UDim.new(0, 16)
    local corner2 = Instance.new("UICorner", switchCircle)
    corner2.CornerRadius = UDim.new(0, 12)

    -- Hover effect
    switchBG.MouseEnter:Connect(function()
        if not initial then
            TweenService:Create(switchBG, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(90, 90, 110)}):Play()
        end
    end)
    switchBG.MouseLeave:Connect(function()
        if not initial then
            TweenService:Create(switchBG, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
        end
    end)

    local toggled = initial
    switchBG.MouseButton1Down:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(switchBG, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(110, 80, 230)}):Play()
            TweenService:Create(switchCircle, TweenInfo.new(0.14), {Position = UDim2.new(1, -28, 0, 2)}):Play()
        else
            TweenService:Create(switchBG, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
            TweenService:Create(switchCircle, TweenInfo.new(0.14), {Position = UDim2.new(0, 4, 0, 2)}):Play()
        end
        if callback then pcall(callback, toggled) end
    end)

    -- return to allow external set
    return {
        container = container,
        set = function(state)
            toggled = state
            if toggled then
                switchBG.BackgroundColor3 = Color3.fromRGB(110, 80, 230)
                switchCircle.Position = UDim2.new(1, -28, 0, 2)
            else
                switchBG.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                switchCircle.Position = UDim2.new(0, 4, 0, 2)
            end
            if callback then pcall(callback, toggled) end
        end,
        get = function() return toggled end
    }
end

-- Modern slider factory
local function createSliderModern(parent, labelText, min, max, default, posY, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, 0, 0, 56)
    container.Position = UDim2.new(0, 0, 0, posY)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(220,220,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", container)
    valueLabel.Size = UDim2.new(0.36, -12, 0, 20)
    valueLabel.Position = UDim2.new(1, -140, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = Color3.fromRGB(200,200,230)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local trackBG = Instance.new("Frame", container)
    trackBG.Size = UDim2.new(1, -36, 0, 12)
    trackBG.Position = UDim2.new(0, 16, 0, 32)
    trackBG.BackgroundColor3 = Color3.fromRGB(54, 56, 64)
    trackBG.BorderSizePixel = 0
    trackBG.ClipsDescendants = true

    local trackFill = Instance.new("Frame", trackBG)
    trackFill.Size = UDim2.new(math.clamp((default - min)/(max - min), 0, 1), 0, 1, 0)
    trackFill.Position = UDim2.new(0, 0, 0, 0)
    trackFill.BackgroundColor3 = Color3.fromRGB(110, 80, 230)
    trackFill.BorderSizePixel = 0

    local knob = Instance.new("ImageButton", trackBG)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(trackFill.Size.X.Scale, -7, 0, -1)
    knob.BackgroundTransparency = 1
    knob.Image = "rbxassetid://3570695787"
    knob.ImageColor3 = Color3.fromRGB(240,240,255)
    knob.ScaleType = Enum.ScaleType.Slice
    knob.SliceCenter = Rect.new(100,100,100,100)
    knob.AutoButtonColor = false

    local dragging = false
    local function updateFromX(x)
        local relativeX = math.clamp(x - trackBG.AbsolutePosition.X, 0, trackBG.AbsoluteSize.X)
        local percent = relativeX / trackBG.AbsoluteSize.X
        local value = math.floor(min + percent * (max - min))
        trackFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0, -1)
        valueLabel.Text = tostring(value)
        if callback then pcall(callback, value) end
    end

    knob.MouseButton1Down:Connect(function(x,y)
        dragging = true
        updateFromX(x)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(input.Position.X)
        end
    end)

    trackBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateFromX(input.Position.X)
        end
    end)

    -- expose setter/getter
    return {
        set = function(val)
            val = math.clamp(val, min, max)
            local percent = (val - min) / (max - min)
            trackFill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -7, 0, -1)
            valueLabel.Text = tostring(val)
            if callback then pcall(callback, val) end
        end,
        get = function()
            return tonumber(valueLabel.Text)
        end
    }
end

-- Fill panels with controls (Aimbot)
local y = 36
local switchAimbotEnable = createSwitch(panelAimbot, "Aimbot Enabled", getgenv().Aimbot.Enabled, y, function(v) getgenv().Aimbot.Enabled = v end); y = y + 48
local switchTeamCheck    = createSwitch(panelAimbot, "Team Check", getgenv().Aimbot.TeamCheck, y, function(v) getgenv().Aimbot.TeamCheck = v end); y = y + 48
local switchWallCheck    = createSwitch(panelAimbot, "Wall Check", getgenv().Aimbot.WallCheck, y, function(v) getgenv().Aimbot.WallCheck = v end); y = y + 48
local sliderMaxDist      = createSliderModern(panelAimbot, "Max Distance", 50, 500, getgenv().Aimbot.MaxDistance, y, function(v) getgenv().Aimbot.MaxDistance = v end); y = y + 64
local sliderAimSpeed     = createSliderModern(panelAimbot, "Aim Speed (0-100)", 1, 100, math.floor(getgenv().Aimbot.AimSpeed * 100), y, function(v) getgenv().Aimbot.AimSpeed = v/100 end); y = y + 64
local sliderFOVRadius    = createSliderModern(panelAimbot, "FOV Radius", 10, 300, getgenv().Aimbot.FOV.Radius, y, function(v) getgenv().Aimbot.FOV.Radius = v fovCircle.Radius = v end); y = y + 64

-- Wallhack panel controls
local wy = 36
local switchWHEnable  = createSwitch(panelWallhack, "Wallhack Enabled", getgenv().Aimbot.WallhackEnabled, wy, function(v) getgenv().Aimbot.WallhackEnabled = v end); wy = wy + 48
local switchWHTeamChk = createSwitch(panelWallhack, "Ignore Same Team", (not getgenv().Aimbot.TeamCheck) and false or true, wy, function(v) getgenv().Aimbot.TeamCheck = v end); wy = wy + 48
local sliderWHDist    = createSliderModern(panelWallhack, "WH Max Distance", 50, 1000, getgenv().Aimbot.WallhackMaxDistance, wy, function(v) getgenv().Aimbot.WallhackMaxDistance = v end); wy = wy + 64

-- Config panel controls
local cy = 36
local toggleFOVVisible = createSwitch(panelConfig, "Show FOV Circle", getgenv().Aimbot.FOV.Visible, cy, function(v) getgenv().Aimbot.FOV.Visible = v end); cy = cy + 48
local toggleLockPart   = createSwitch(panelConfig, "Lock to Head", (getgenv().Aimbot.LockPart == "Head"), cy, function(v) if v then getgenv().Aimbot.LockPart = "Head" else getgenv().Aimbot.LockPart = "UpperTorso" end end); cy = cy + 48
local priorityBtn = Instance.new("TextButton", panelConfig)
priorityBtn.Size = UDim2.new(0, 180, 0, 34)
priorityBtn.Position = UDim2.new(0, 8, 0, cy)
priorityBtn.BackgroundColor3 = Color3.fromRGB(92, 64, 220)
priorityBtn.BorderSizePixel = 0
priorityBtn.TextColor3 = Color3.fromRGB(255,255,255)
priorityBtn.Font = Enum.Font.GothamBold
priorityBtn.TextSize = 14
priorityBtn.Text = "Priority: " .. getgenv().Aimbot.Priority
priorityBtn.ZIndex = 3

priorityBtn.MouseButton1Down:Connect(function()
    if getgenv().Aimbot.Priority == "FOV" then
        getgenv().Aimbot.Priority = "Distância"
    else
        getgenv().Aimbot.Priority = "FOV"
    end
    priorityBtn.Text = "Priority: " .. getgenv().Aimbot.Priority
end)

-- Helper to show a panel
local function showPanel(panel)
    for _, v in pairs(Content:GetChildren()) do
        if v:IsA("Frame") and v.Name:find("Panel") then
            v.Visible = false
        end
    end
    panel.Visible = true
end

-- Menu button actions
btnAimbot.MouseButton1Down:Connect(function()
    showPanel(panelAimbot)
end)
btnWallhack.MouseButton1Down:Connect(function()
    showPanel(panelWallhack)
end)
btnConfig.MouseButton1Down:Connect(function()
    showPanel(panelConfig)
end)

-- Start with Aimbot tab
showPanel(panelAimbot)

-- Close and minimize behavior
local minimized = false
BtnClose.MouseButton1Down:Connect(function()
    ScreenGui.Enabled = false
end)

BtnMin.MouseButton1Down:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Root, TweenInfo.new(0.18), {Size = UDim2.new(0, 200, 0, 40)}):Play()
        -- hide content
        for _,v in pairs(Root:GetChildren()) do
            if v ~= Header and v ~= BtnClose and v ~= BtnMin then
                v.Visible = false
            end
        end
    else
        TweenService:Create(Root, TweenInfo.new(0.18), {Size = UDim2.new(0, 420, 0, 420)}):Play()
        wait(0.18)
        for _,v in pairs(Root:GetChildren()) do
            v.Visible = true
        end
        showPanel(panelAimbot)
    end
end)

-- Show/hide GUI with Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Save config on close
game:BindToClose(function()
    if writefile then
        pcall(function()
            writefile(configFile, HttpService:JSONEncode(getgenv().Aimbot))
        end)
    end
end)

-- final message
print("[DogaoRipV3] UI carregada (moderna).")
