--==================================
-- AIMBOT V2 - AUTO UPDATE
-- Criado por deividhack15151
--==================================

-- Notificação inicial
if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimbot V2",
        Text = "Script carregado com sucesso!",
        Duration = 5
    })
end

-- CONFIGURAÇÕES PRINCIPAIS
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

-- CONFIGURAÇÕES DO FOV
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

--===============================
-- RESTANTE DO AIMBOT
--===============================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CurrentTarget = nil
local Holding = false

local function toColor3(colorString)
    local r,g,b = string.match(colorString, "(%d+),%s*(%d+),%s*(%d+)")
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

local function getClosestPlayer()
    local closest = nil
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
                        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                        if dist < shortestDistance and dist <= fov then
                            if not settings.WallCheck or isVisible(part) then
                                shortestDistance = dist
                                closest = player
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

-- FOV Circle (desenho)
local fovCircle = Drawing.new("Circle")
fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
fovCircle.Thickness = getgenv().Aimbot.FOVSettings.Thickness
fovCircle.Filled = getgenv().Aimbot.FOVSettings.Filled
fovCircle.NumSides = getgenv().Aimbot.FOVSettings.Sides
fovCircle.Radius = getgenv().Aimbot.FOVSettings.Amount
fovCircle.Transparency = getgenv().Aimbot.FOVSettings.Transparency

local function updateFOVCircle()
    local settings = getgenv().Aimbot.FOVSettings
    fovCircle.Visible = settings.Enabled and settings.Visible
    fovCircle.Radius = settings.Amount
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end

-- Controle de teclas
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

-- Loop principal
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

-- Mensagem final
if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimbot V2",
        Text = "Aimbot Ativado! Segure o botão direito do mouse para mirar.",
        Duration = 8
    })
end
