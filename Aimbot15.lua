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
    TriggerKey = "MouseButton2", -- botão de ativação
    Toggle = false,
    LockPart = "Head",
    Mode = "shot" -- "shot" = só atira, "hold" = segurar botão, "always" = sempre ativo
}

getgenv().Aimbot.FOVSettings = {
    Enabled = true,
    Visible = true,
    Amount = 40,
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
-- FUNÇÕES PRINCIPAIS
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
-- FUNÇÕES PÚBLICAS
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
-- LOOP PRINCIPAL
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

notify("Aimbot", "Script carregado com sucesso! Use Aimbot:Toggle() para ativar/desativar.")
