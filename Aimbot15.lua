-- ==========================
-- AIMBOT + ESP + GUI
-- ==========================

-- ==========================
-- CONFIGURAÇÕES DO AIMBOT
-- ==========================

getgenv().Aimbot = {}
getgenv().Aimbot.Settings = {
    SendNotifications = true,
    SaveSettings = true,
    ReloadOnTeleport = true,
    Enabled = true,
    TeamCheck = false,
    AliveCheck = true,
    WallCheck = false,
    Sensitivity = 0,
    ThirdPerson = false,
    ThirdPersonSensitivity = 3,
    TriggerKey = "MouseButton2",
    Toggle = false,
    LockPart = "Head",
    Mode = "shot", -- "shot" = só atira, "hold" = segurar botão, "always" = sempre ativo
    ESPEnabled = true
}

getgenv().Aimbot.FOVSettings = {
    Enabled = true,
    Visible = true,
    Amount = 60, -- FOV menor
    Color = "255, 255, 255",
    LockedColor = "255, 70, 70",
    Transparency = 0.5,
    Sides = 60,
    Thickness = 1,
    Filled = false
}

-- ==========================
-- VARIÁVEIS INICIAIS
-- ==========================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentTarget = nil
local Holding = false
local Shooting = false

-- ==========================
-- FUNÇÕES AUXILIARES
-- ==========================

local function notify(title, text)
    if getgenv().Aimbot.Settings.SendNotifications then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end
end

local function toColor3(colorString)
    local r, g, b = string.match(colorString, "(%d+),%s*(%d+),%s*(%d+)")
    return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
end

local function isAlive(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    return hit == part or hit:IsDescendantOf(part.Parent)
end

-- ==========================
-- FUNÇÕES PRINCIPAIS (AIMBOT)
-- ==========================

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local settings = getgenv().Aimbot.Settings
    local fov = getgenv().Aimbot.FOVSettings.Amount

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if (not settings.TeamCheck or player.Team ~= LocalPlayer.Team) 
               and (not settings.AliveCheck or isAlive(player)) then

                local part = player.Character and player.Character:FindFirstChild(settings.LockPart)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                        if distance < shortestDistance and distance <= fov then
                            if not settings.WallCheck or isVisible(part) then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function aimAt(target)
    if not target.Character then return end
    local part = target.Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)
    if not part then return end

    if getgenv().Aimbot.Settings.ThirdPerson then
        local screenPos = Camera:WorldToViewportPoint(part.Position)
        mousemoverel(
            (screenPos.X - Mouse.X) / getgenv().Aimbot.Settings.ThirdPersonSensitivity,
            (screenPos.Y - Mouse.Y) / getgenv().Aimbot.Settings.ThirdPersonSensitivity
        )
    else
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    end
end

-- ==========================
-- FOV CIRCLE
-- ==========================

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = getgenv().Aimbot.FOVSettings.Amount
fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
fovCircle.Thickness = getgenv().Aimbot.FOVSettings.Thickness
fovCircle.Filled = getgenv().Aimbot.FOVSettings.Filled
fovCircle.Transparency = getgenv().Aimbot.FOVSettings.Transparency
fovCircle.NumSides = getgenv().Aimbot.FOVSettings.Sides

local function updateFOVCircle()
    local settings = getgenv().Aimbot.FOVSettings
    fovCircle.Visible = settings.Enabled and settings.Visible
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    fovCircle.Radius = settings.Amount
end

-- ==========================
-- FUNÇÕES PÚBLICAS (AJUSTES)
-- ==========================

function getgenv().Aimbot:Toggle()
    self.Settings.Enabled = not self.Settings.Enabled
    notify("Aimbot", self.Settings.Enabled and "Ativado" or "Desativado")
end

function getgenv().Aimbot:SetLockPart(partName)
    self.Settings.LockPart = partName
    notify("Aimbot", "Mira agora em: " .. partName)
end

function getgenv().Aimbot:SetFOV(amount)
    self.FOVSettings.Amount = amount
    notify("Aimbot", "FOV ajustado para: " .. tostring(amount))
end

function getgenv().Aimbot:SetMode(mode)
    self.Settings.Mode = mode
    notify("Aimbot", "Modo alterado para: " .. mode)
end

-- ==========================
-- CONTROLES DE TECLA
-- ==========================

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Shooting = true
    end

    if input.UserInputType.Name == getgenv().Aimbot.Settings.TriggerKey then
        if getgenv().Aimbot.Settings.Toggle then
            getgenv().Aimbot.Settings.Enabled = not getgenv().Aimbot.Settings.Enabled
            notify("Aimbot", getgenv().Aimbot.Settings.Enabled and "Ativado" or "Desativado")
        else
            Holding = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Shooting = false
    end

    if input.UserInputType.Name == getgenv().Aimbot.Settings.TriggerKey and not getgenv().Aimbot.Settings.Toggle then
        Holding = false
    end
end)

-- ==========================
-- LOOP PRINCIPAL AIMBOT
-- ==========================

RunService.RenderStepped:Connect(function()
    updateFOVCircle()

    local mode = getgenv().Aimbot.Settings.Mode

    local canAim = false
    if mode == "always" then
        canAim = getgenv().Aimbot.Settings.Enabled
    elseif mode == "hold" then
        canAim = Holding and getgenv().Aimbot.Settings.Enabled
    elseif mode == "shot" then
        canAim = Shooting and getgenv().Aimbot.Settings.Enabled
    end

    if canAim then
        CurrentTarget = getClosestPlayer()
        if CurrentTarget then
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.LockedColor)
            aimAt(CurrentTarget)
        else
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
        end
    end
end)

-- ==========================
-- ESP (WALLHACK + TRACERS)
-- ==========================

local tracers = {}

local function createESP(player)
    if player.Character and not player.Character:FindFirstChild("AimbotESP") then
        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "AimbotESP"
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character

        -- Cores aliado/inimigo
        if player.Team == LocalPlayer.Team then
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        else
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end

        -- Billboard (nome e vida)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "AimbotESPInfo"
        billboard.Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChildWhichIsA("BasePart")
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = player.Character

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "Vida: 100"
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Font = Enum.Font.SourceSansBold
        healthLabel.TextScaled = true
        healthLabel.Parent = billboard

        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                healthLabel.Text = "Vida: " .. math.floor(health)
                if health > 50 then
                    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif health > 20 then
                    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end

        -- Tracer (linha)
        local tracer = Drawing.new("Line")
        tracer.Thickness = 1.5
        tracer.Transparency = 1
        tracer.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        tracers[player] = tracer
    end
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("AimbotESP") then
        player.Character.AimbotESP:Destroy()
    end
    if player.Character and player.Character:FindFirstChild("AimbotESPInfo") then
        player.Character.AimbotESPInfo:Destroy()
    end
    if tracers[player] then
        tracers[player]:Remove()
        tracers[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().Aimbot.Settings.ESPEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character and getgenv().Aimbot.Settings.ESPEnabled then
            createESP(player)
        end
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if getgenv().Aimbot.Settings.ESPEnabled then
                createESP(player)
            end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not getgenv().Aimbot.Settings.ESPEnabled then
        for _, line in pairs(tracers) do
            line.Visible = false
        end
        return
    end

    for player, line in pairs(tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

function getgenv().Aimbot:ToggleESP()
    self.Settings.ESPEnabled = not self.Settings.ESPEnabled
    if not self.Settings.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                removeESP(player)
            end
        end
        notify("ESP", "ESP desativado!")
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESP(player)
            end
        end
        notify("ESP", "ESP ativado!")
    end
end

-- ==========================
-- GUI (BOTÕES NA TELA)
-- ==========================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Frame

-- Botão AIMBOT
local AimbotButton = Instance.new("TextButton")
AimbotButton.Size = UDim2.new(1, -20, 0, 40)
AimbotButton.Position = UDim2.new(0, 10, 0, 10)
AimbotButton.Text = "Aimbot: ON"
AimbotButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotButton.Font = Enum.Font.SourceSansBold
AimbotButton.TextSize = 18
AimbotButton.Parent = Frame

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 4)
corner1.Parent = AimbotButton

-- Botão ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, -20, 0, 40)
ESPButton.Position = UDim2.new(0, 10, 0, 50)
ESPButton.Text = "ESP: ON"
ESPButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.SourceSansBold
ESPButton.TextSize = 18
ESPButton.Parent = Frame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 4)
corner2.Parent = ESPButton

AimbotButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot:Toggle()
    if getgenv().Aimbot.Settings.Enabled then
        AimbotButton.Text = "Aimbot: ON"
        AimbotButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    else
        AimbotButton.Text = "Aimbot: OFF"
        AimbotButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
end)

ESPButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot:ToggleESP()
    if getgenv().Aimbot.Settings.ESPEnabled then
        ESPButton.Text = "ESP: ON"
        ESPButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    else
        ESPButton.Text = "ESP: OFF"
        ESPButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
    end
end)

notify("Aimbot", "Script carregado com sucesso! GUI ativa.")
