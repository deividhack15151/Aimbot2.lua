--==================================
-- AIMBOT V2 MELHORADO COM MENU
-- Criado por deividhack15151
-- Atualizado por ChatGPT
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

-- Controle de teclas para ativar/desativar o aimbot
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

-- Comandos no chat para mudar configurações em tempo real (mantidos por compatibilidade)
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

-- ==== MENU VISUAL ====

local menuVisible = false
local menuPosition = Vector2.new(100, 100)
local menuWidth, menuHeight = 220, 130

local menuBackground = Drawing.new("Square")
menuBackground.Color = Color3.fromRGB(20, 20, 20)
menuBackground.Transparency = 0.8
menuBackground.Filled = true
menuBackground.Size = Vector2.new(menuWidth, menuHeight)
menuBackground.Position = menuPosition
menuBackground.Visible = false

local menuTitle = Drawing.new("Text")
menuTitle.Text = "Menu Aimbot"
menuTitle.Color = Color3.fromRGB(255, 255, 255)
menuTitle.Size = 20
menuTitle.Position = menuPosition + Vector2.new(10, 5)
menuTitle.Visible = false
menuTitle.Center = false
menuTitle.Outline = true

local statusText = Drawing.new("Text")
statusText.Text = "Status: Desligado"
statusText.Color = Color3.fromRGB(255, 100, 100)
statusText.Size = 16
statusText.Position = menuPosition + Vector2.new(10, 30)
statusText.Visible = false
statusText.Center = false
statusText.Outline = true

local lockPartText = Drawing.new("Text")
lockPartText.Text = "LockPart: Head"
lockPartText.Color = Color3.fromRGB(255, 255, 255)
lockPartText.Size = 16
lockPartText.Position = menuPosition + Vector2.new(10, 55)
lockPartText.Visible = false
lockPartText.Center = false
lockPartText.Outline = true

local fovText = Drawing.new("Text")
fovText.Text = "FOV: 90"
fovText.Color = Color3.fromRGB(255, 255, 255)
fovText.Size = 16
fovText.Position = menuPosition + Vector2.new(10, 80)
fovText.Visible = false
fovText.Center = false
fovText.Outline = true

local instructionsText = Drawing.new("Text")
instructionsText.Text = "M: Mostrar/ocultar menu\nL: Liga/Desliga\nP/N: FOV +/-\nK: Mudar LockPart"
instructionsText.Color = Color3.fromRGB(200, 200, 200)
instructionsText.Size = 12
instructionsText.Position = menuPosition + Vector2.new(10, 105)
instructionsText.Visible = false
instructionsText.Center = false
instructionsText.Outline = true

local function updateMenuTexts()
    statusText.Text = "Status: " .. (getgenv().Aimbot.Settings.Enabled and "Ligado" or "Desligado")
    statusText.Color = getgenv().Aimbot.Settings.Enabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    lockPartText.Text = "LockPart: " .. getgenv().Aimbot.Settings.LockPart
    fovText.Text = "FOV: " .. tostring(getgenv().Aimbot.FOVSettings.Amount)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.M then
        menuVisible = not menuVisible
        menuBackground.Visible = menuVisible
        menuTitle.Visible = menuVisible
        statusText.Visible = menuVisible
        lockPartText.Visible = menuVisible
        fovText.Visible = menuVisible
        instructionsText.Visible = menuVisible
        updateMenuTexts()
    end

    if not menuVisible then return end

    if input.KeyCode == Enum.KeyCode.L then
        getgenv().Aimbot.Settings.Enabled = not getgenv().Aimbot.Settings.Enabled
        updateMenuTexts()
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.P then
        getgenv().Aimbot.FOVSettings.Amount = math.min(getgenv().Aimbot.FOVSettings.Amount + 5, 360)
        updateMenuTexts()
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.N then
        getgenv().Aimbot.FOVSettings.Amount = math.max(getgenv().Aimbot.FOVSettings.Amount - 5, 10)
        updateMenuTexts()
        SaveSettings()
    elseif input.KeyCode == Enum.KeyCode.K then
        local parts = {"Head", "Torso", "HumanoidRootPart"}
        local current = getgenv().Aimbot.Settings.LockPart
        local idx = table.find(parts, current) or 1
        idx = idx + 1
        if idx > #parts then idx = 1 end
        getgenv().Aimbot.Settings.LockPart = parts[idx]
        updateMenuTexts()
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
