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
    LockPart = "Head"
}

getgenv().Aimbot.FOVSettings = {
    Enabled = true,
    Visible = true,
    Amount = 90,
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
local Holding = false -- para quando não é toggle

-- ==========================
-- FUNÇÕES AUXILIARES
-- ==========================

-- Converte a cor (string) para tabela {r,g,b}
local function toColor3(colorString)
    local r, g, b = string.match(colorString, "(%d+),%s*(%d+),%s*(%d+)")
    return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
end

-- Verifica se player está vivo
local function isAlive(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Verifica se está na tela
local function isOnScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return onScreen
end

-- Verifica se há parede bloqueando a visão
local function isVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    return hitPart == part or hitPart == part.Parent
end

-- ==========================
-- FUNÇÕES PRINCIPAIS
-- ==========================

-- Procura o inimigo mais próximo do mouse dentro do FOV
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

-- Trava a mira no alvo
local function aimAt(target)
    if not target.Character then return end
    local part = target.Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)
    if not part then return end

    local settings = getgenv().Aimbot.Settings
    local targetPos = part.Position

    if settings.ThirdPerson then
        -- Move o mouse (terceira pessoa)
        local screenPos = Camera:WorldToViewportPoint(targetPos)
        mousemoverel((screenPos.X - Mouse.X) / settings.ThirdPersonSensitivity, (screenPos.Y - Mouse.Y) / settings.ThirdPersonSensitivity)
    else
        -- Usa CFrame (primeira pessoa)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
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
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- ajuste do roblox
    fovCircle.Radius = settings.Amount
end

-- ==========================
-- CONTROLES DE TECLA
-- ==========================

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType.Name == getgenv().Aimbot.Settings.TriggerKey then
        if getgenv().Aimbot.Settings.Toggle then
            getgenv().Aimbot.Settings.Enabled = not getgenv().Aimbot.Settings.Enabled
        else
            Holding = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType.Name == getgenv().Aimbot.Settings.TriggerKey and not getgenv().Aimbot.Settings.Toggle then
        Holding = false
    end
end)

-- ==========================
-- LOOP PRINCIPAL
-- ==========================

RunService.RenderStepped:Connect(function()
    updateFOVCircle()

    if getgenv().Aimbot.Settings.Enabled or Holding then
        CurrentTarget = getClosestPlayer()
        if CurrentTarget then
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.LockedColor)
            aimAt(CurrentTarget)
        else
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
        end
    end
end)
