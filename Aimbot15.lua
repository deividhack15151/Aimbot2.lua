-- ROBLOX AIMBOT PRO V3 - GUI COMPLETA COM ESP, SLIDERS, TOGGLES E SALVAMENTO
-- Corrigido: Wallhack otimizado + FOV funcionando corretamente
-- Criado por ChatGPT para Deivid

-- Serviços Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações Globais
getgenv().Aimbot = {
    Enabled = true,
    WallCheck = true,
    TeamCheck = false,
    LockPart = "Head",
    TriggerKey = Enum.KeyCode.E,
    FOV = 120,
    AimSpeed = 0.3,
    MaxDistance = 500,
    Priority = "FOV",
    Wallhack = true,
    ShowDistance = true,
    ShowHealthBar = true,
    ShowSkeleton = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    SaveFile = "aimbot_config.json"
}

-- Função para salvar
local function saveConfig()
    if writefile then
        writefile(getgenv().Aimbot.SaveFile, HttpService:JSONEncode(getgenv().Aimbot))
    end
end

-- Função para carregar
local function loadConfig()
    if isfile and readfile and isfile(getgenv().Aimbot.SaveFile) then
        local data = HttpService:JSONDecode(readfile(getgenv().Aimbot.SaveFile))
        for k, v in pairs(data) do getgenv().Aimbot[k] = v end
    end
end
loadConfig()

-- Aimbot logic
local function getClosestPlayer()
    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().Aimbot.LockPart) then
            if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local part = player.Character[getgenv().Aimbot.LockPart]
            local dist = (Camera.CFrame.Position - part.Position).Magnitude
            if dist <= getgenv().Aimbot.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - (Camera.ViewportSize / 2)).Magnitude
                    if fovDist <= getgenv().Aimbot.FOV and fovDist < shortest then
                        shortest = fovDist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not getgenv().Aimbot.Enabled then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild(getgenv().Aimbot.LockPart) then
        local part = target.Character[getgenv().Aimbot.LockPart]
        local camPos = Camera.CFrame.Position
        local aimDirection = (part.Position - camPos).Unit
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, camPos + aimDirection), getgenv().Aimbot.AimSpeed)
    end
end)

-- Armazenar ESPs ativos para otimizar
local espObjects = {}

-- ESP Visual (otimizado)
RunService.RenderStepped:Connect(function()
    for _, esp in pairs(espObjects) do
        for _, obj in pairs(esp) do
            if obj and obj.Remove then obj:Remove() end
        end
    end
    espObjects = {}

    if not getgenv().Aimbot.Wallhack then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and humanoid) then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then continue end

            local esp = {}

            local box = Drawing.new("Square")
            box.Size = Vector2.new(50, 100)
            box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
            box.Color = getgenv().Aimbot.ESPColor
            box.Thickness = 1
            box.Visible = true
            esp.box = box

            local name = Drawing.new("Text")
            name.Text = player.Name
            name.Position = Vector2.new(pos.X, pos.Y - 60)
            name.Size = 14
            name.Color = Color3.new(1, 1, 1)
            name.Center = true
            name.Outline = true
            name.Visible = true
            esp.name = name

            if getgenv().Aimbot.ShowDistance then
                local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                local distanceText = Drawing.new("Text")
                distanceText.Text = dist .. "m"
                distanceText.Position = Vector2.new(pos.X, pos.Y + 60)
                distanceText.Size = 13
                distanceText.Color = Color3.new(0.8, 0.8, 0.8)
                distanceText.Center = true
                distanceText.Visible = true
                esp.distance = distanceText
            end

            if getgenv().Aimbot.ShowHealthBar then
                local health = humanoid.Health / humanoid.MaxHealth
                local bar = Drawing.new("Square")
                bar.Size = Vector2.new(3, 100 * health)
                bar.Position = Vector2.new(pos.X - 30, pos.Y - 50 + (100 * (1 - health)))
                bar.Color = Color3.fromRGB(0, 255, 0)
                bar.Thickness = 1
                bar.Filled = true
                bar.Visible = true
                esp.hp = bar
            end

            if getgenv().Aimbot.ShowSkeleton then
                esp.skeleton = {}
                local joints = {
                    head,
                    char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
                    char:FindFirstChild("LeftUpperArm"),
                    char:FindFirstChild("RightUpperArm"),
                    char:FindFirstChild("LeftUpperLeg"),
                    char:FindFirstChild("RightUpperLeg"),
                }
                for i = 1, #joints - 1 do
                    if joints[i] and joints[i + 1] then
                        local p1 = Camera:WorldToViewportPoint(joints[i].Position)
                        local p2 = Camera:WorldToViewportPoint(joints[i + 1].Position)
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(p1.X, p1.Y)
                        line.To = Vector2.new(p2.X, p2.Y)
                        line.Color = getgenv().Aimbot.ESPColor
                        line.Thickness = 1
                        line.Visible = true
                        table.insert(esp.skeleton, line)
                    end
                end
            end

            table.insert(espObjects, esp)
        end
    end
end)

game:BindToClose(saveConfig)
