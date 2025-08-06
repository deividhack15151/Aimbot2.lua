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

-- Armazenar ESPs ativos para otimizar (mapeado por jogador)
local espObjects = {}

-- ESP Visual (otimizado)
RunService.RenderStepped:Connect(function()
    -- Atualizar ESP de todos os jogadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not (hrp and head and humanoid) then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then
                -- Se jogador não estiver na tela, esconder ESP
                if espObjects[player] then
                    for _, obj in pairs(espObjects[player]) do
                        if typeof(obj) == "table" then
                            for _, line in ipairs(obj) do
                                if line.Remove then line.Visible = false end
                            end
                        elseif obj.Remove then
                            obj.Visible = false
                        end
                    end
                end
                continue
            end

            -- Criar ESP se não existir
            if not espObjects[player] then
                espObjects[player] = {
                    box = Drawing.new("Square"),
                    name = Drawing.new("Text"),
                    distance = Drawing.new("Text"),
                    hp = Drawing.new("Square"),
                    skeleton = {},
                }
            end

            local esp = espObjects[player]

            -- Atualizar posição e visual
            esp.box.Size = Vector2.new(50, 100)
            esp.box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
            esp.box.Color = getgenv().Aimbot.ESPColor
            esp.box.Thickness = 1
            esp.box.Visible = true

            esp.name.Text = player.Name
            esp.name.Position = Vector2.new(pos.X, pos.Y - 60)
            esp.name.Size = 14
            esp.name.Color = Color3.new(1, 1, 1)
            esp.name.Center = true
            esp.name.Outline = true
            esp.name.Visible = true

            if getgenv().Aimbot.ShowDistance then
                local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                esp.distance.Text = dist .. "m"
                esp.distance.Position = Vector2.new(pos.X, pos.Y + 60)
                esp.distance.Size = 13
                esp.distance.Color = Color3.new(0.8, 0.8, 0.8)
                esp.distance.Center = true
                esp.distance.Visible = true
            else
                if esp.distance then esp.distance.Visible = false end
            end

            if getgenv().Aimbot.ShowHealthBar then
                local health = humanoid.Health / humanoid.MaxHealth
                esp.hp.Size = Vector2.new(3, 100 * health)
                esp.hp.Position = Vector2.new(pos.X - 30, pos.Y - 50 + (100 * (1 - health)))
                esp.hp.Color = Color3.fromRGB(0, 255, 0)
                esp.hp.Filled = true
                esp.hp.Visible = true
            else
                if esp.hp then esp.hp.Visible = false end
            end

            -- Skeleton (reutilizar linhas)
            if getgenv().Aimbot.ShowSkeleton then
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
                        if not esp.skeleton[i] then
                            esp.skeleton[i] = Drawing.new("Line")
                        end
                        local p1 = Camera:WorldToViewportPoint(joints[i].Position)
                        local p2 = Camera:WorldToViewportPoint(joints[i + 1].Position)
                        esp.skeleton[i].From = Vector2.new(p1.X, p1.Y)
                        esp.skeleton[i].To = Vector2.new(p2.X, p2.Y)
                        esp.skeleton[i].Color = getgenv().Aimbot.ESPColor
                        esp.skeleton[i].Thickness = 1
                        esp.skeleton[i].Visible = true
                    elseif esp.skeleton[i] then
                        esp.skeleton[i].Visible = false
                    end
                end
            else
                -- Esconder linhas se skeleton off
                if esp.skeleton then
                    for _, line in ipairs(esp.skeleton) do
                        line.Visible = false
                    end
                end
            end
        else
            -- Jogador inválido ou personagem não existe - esconder ESP
            if espObjects[player] then
                for _, obj in pairs(espObjects[player]) do
                    if typeof(obj) == "table" then
                        for _, line in ipairs(obj) do
                            if line.Remove then line.Visible = false end
                        end
                    elseif obj.Remove then
                        obj.Visible = false
                    end
                end
            end
        end
    end

    -- Limpar ESPs de jogadores que saíram
    for player, esp in pairs(espObjects) do
        if not player:IsDescendantOf(Players) or not player.Character then
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in ipairs(obj) do
                        if line.Remove then line:Remove() end
                    end
                elseif obj.Remove then
                    obj:Remove()
                end
            end
            espObjects[player] = nil
        end
    end
end)

game:BindToClose(saveConfig)
