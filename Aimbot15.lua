--==================================
-- AIMBOT V2 MELHORADO - AUTO UPDATE
-- Criado por deividhack15151
-- Atualizado por ChatGPT
--==================================

-- Notificação inicial
if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "menu deividpaim V2",
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

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CurrentTarget = nil
local Holding = false
local AimSpeed = 0.2 -- Suavização da mira (quanto menor, mais rápido)

-- Salvar e carregar configurações usando shared (temporário)
local function SaveSettings()
    if getgenv().Aimbot.Settings.SaveSettings then
        shared.AimbotSettings = getgenv().Aimbot.Settings
        shared.AimbotFOVSettings = getgenv().Aimbot.FOVSettings
    end
end

local function LoadSettings()
    if shared.AimbotSettings then
        getgenv().Aimbot.Settings = shared.AimbotSettings
    end
    if shared.AimbotFOVSettings then
        getgenv().Aimbot.FOVSettings = shared.AimbotFOVSettings
    end
end

LoadSettings()

-- Função para converter string RGB para Color3
local function toColor3(colorString)
    local r,g,b = string.match(colorString, "(%d+),%s*(%d+),%s*(%d+)")
    return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
end

-- Checa se jogador está vivo
local function isAlive(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Checa se parte está visível (usando raycast moderno)
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return false
end

-- Retorna o jogador mais próximo do mouse dentro do FOV configurado
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

-- Mira suavemente no alvo usando interpolação
local function aimAt(target)
    if not target.Character then return end
    local part = target.Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)
    if not part then return end

    local cameraPos = Camera.CFrame.Position
    local targetPos = part.Position
    local direction = (targetPos - cameraPos).Unit

    local currentLookVector = Camera.CFrame.LookVector
    local newLookVector = currentLookVector:Lerp(direction, AimSpeed)

    Camera.CFrame = CFrame.new(cameraPos, cameraPos + newLookVector)
end

-- Criar círculo do FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
fovCircle.Thickness = getgenv().Aimbot.FOVSettings.Thickness
fovCircle.Filled = getgenv().Aimbot.FOVSettings.Filled
fovCircle.NumSides = getgenv().Aimbot.FOVSettings.Sides
fovCircle.Radius = getgenv().Aimbot.FOVSettings.Amount
fovCircle.Transparency = getgenv().Aimbot.FOVSettings.Transparency

-- Linha para alvo
local fovLine = Drawing.new("Line")
fovLine.Color = toColor3(getgenv().Aimbot.FOVSettings.LockedColor)
fovLine.Thickness = 1
fovLine.Transparency = 1

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
        SaveSettings()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType.Name == getgenv().Aimbot.Settings.TriggerKey and not getgenv().Aimbot.Settings.Toggle then
        Holding = false
        SaveSettings()
    end
end)

-- Comandos no chat para mudar configurações em tempo real
LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg:lower(), " ")
    if args[1] == "!aimbot" then
        if args[2] == "toggle" then
            getgenv().Aimbot.Settings.Enabled = not getgenv().Aimbot.Settings.Enabled
            print("Aimbot ativado:", getgenv().Aimbot.Settings.Enabled)
        elseif args[2] == "lockpart" and args[3] then
            getgenv().Aimbot.Settings.LockPart = args[3]:gsub("^%l", string.upper)
            print("LockPart alterado para", getgenv().Aimbot.Settings.LockPart)
        elseif args[2] == "fov" and tonumber(args[3]) then
            getgenv().Aimbot.FOVSettings.Amount = tonumber(args[3])
            print("FOV alterado para", args[3])
        end
        SaveSettings()
    end
end)

-- Loop principal
RunService.RenderStepped:Connect(function()
    updateFOVCircle()

    if getgenv().Aimbot.Settings.Enabled or Holding then
        CurrentTarget = getClosestPlayer()
        if CurrentTarget then
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.LockedColor)

            local part = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    fovLine.Visible = true
                    fovLine.From = Vector2.new(Mouse.X, Mouse.Y + 36)
                    fovLine.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    fovLine.Visible = false
                end
            else
                fovLine.Visible = false
            end

            aimAt(CurrentTarget)
        else
            fovCircle.Color = toColor3(getgenv().Aimbot.FOVSettings.Color)
            fovLine.Visible = false
        end
    else
        fovLine.Visible = false
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
