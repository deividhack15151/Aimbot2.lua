--==================================
-- AIMBOT V3 - GUI + MELHORIAS
--==================================

if game:GetService("StarterGui") then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Aimbot V3",
        Text = "Script carregado com sucesso!",
        Duration = 5
    })
end

-- Serviços do Roblox
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
    TeamCheck = true, -- Ativado por padrão
    WallCheck = true,
    AliveCheck = true,
    LockPart = "Head",
    TriggerKey = Enum.UserInputType.MouseButton2,
    Toggle = false,
    AimSpeed = 0.2,
    Priority = "FOV", -- "FOV" ou "Distância"
    MaxDistance = 150,
    FOV = {
        Radius = 90,
        Color = Color3.fromRGB(255, 255, 255),
        LockedColor = Color3.fromRGB(255, 70, 70),
        Thickness = 1,
        Filled = false,
        Visible = true
    }
}

-- Carregar configurações salvas
local configFile = "aimbot_config.json"
if readfile and isfile and isfile(configFile) then
    local data = HttpService:JSONDecode(readfile(configFile))
    for k, v in pairs(data) do getgenv().Aimbot[k] = v end
end

--==============================
-- GUI (Interface)
--==============================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 320)
Frame.Position = UDim2.new(0.02, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Aimbot V3 Config"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Checkbox TeamCheck
local teamCheckButton = Instance.new("TextButton", Frame)
teamCheckButton.Size = UDim2.new(1, -20, 0, 30)
teamCheckButton.Position = UDim2.new(0, 10, 0, 40)
teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
teamCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.TeamCheck = not getgenv().Aimbot.TeamCheck
    teamCheckButton.Text = "Team Check: " .. (getgenv().Aimbot.TeamCheck and "ON" or "OFF")
end)

-- Checkbox WallCheck
local wallCheckButton = Instance.new("TextButton", Frame)
wallCheckButton.Size = UDim2.new(1, -20, 0, 30)
wallCheckButton.Position = UDim2.new(0, 10, 0, 80)
wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
wallCheckButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.WallCheck = not getgenv().Aimbot.WallCheck
    wallCheckButton.Text = "Wall Check: " .. (getgenv().Aimbot.WallCheck and "ON" or "OFF")
end)

-- Distância máxima (slider simples)
local distanceBox = Instance.new("TextBox", Frame)
distanceBox.Size = UDim2.new(1, -20, 0, 30)
distanceBox.Position = UDim2.new(0, 10, 0, 120)
distanceBox.PlaceholderText = "Max Distance (" .. getgenv().Aimbot.MaxDistance .. ")"
distanceBox.Text = ""
distanceBox.FocusLost:Connect(function()
    local val = tonumber(distanceBox.Text)
    if val then
        getgenv().Aimbot.MaxDistance = val
        distanceBox.PlaceholderText = "Max Distance (" .. val .. ")"
    end
end)

-- Prioridade dropdown
local priorityButton = Instance.new("TextButton", Frame)
priorityButton.Size = UDim2.new(1, -20, 0, 30)
priorityButton.Position = UDim2.new(0, 10, 0, 160)
priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
priorityButton.MouseButton1Click:Connect(function()
    getgenv().Aimbot.Priority = getgenv().Aimbot.Priority == "FOV" and "Distância" or "FOV"
    priorityButton.Text = "Prioridade: " .. getgenv().Aimbot.Priority
end)

--==============================
-- DESENHO DO FOV
--==============================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = getgenv().Aimbot.FOV.Thickness
fovCircle.Filled = getgenv().Aimbot.FOV.Filled
fovCircle.Radius = getgenv().Aimbot.FOV.Radius

local function updateFOV()
    fovCircle.Position = Camera.ViewportSize / 2 -- Mira centralizada
    fovCircle.Visible = getgenv().Aimbot.FOV.Visible
end

--==============================
-- FUNÇÕES DE MIRA
--==============================
local function isAlive(player)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- WallCheck aprimorado
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

-- Busca o jogador mais próximo
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

-- Atualização do alvo a cada 0.05s
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
end)

-- Salvar configurações ao fechar
game:BindToClose(function()
    if writefile then
        writefile(configFile, HttpService:JSONEncode(getgenv().Aimbot))
    end
end)

-- ESP Hack Melhorado
-- Visual (Box, Linha, Skeleton Completo RGB animado)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Drawing = Drawing -- assume que Drawing já está disponível

-- Função para gerar cor RGB animada e arredondada
local function createRGBColor()
    local r = math.abs(math.sin(tick() * 2)) * 255
    local g = math.abs(math.sin(tick() * 2 + 2)) * 255
    local b = math.abs(math.sin(tick() * 2 + 4)) * 255
    return Color3.fromRGB(math.floor(r), math.floor(g), math.floor(b))
end

-- Função para criar objetos ESP para um jogador
local function createESPForPlayer(player)
    local esp = {}

    esp.box = Drawing.new("Square")
    esp.box.Thickness = 1.5
    esp.box.Filled = false
    esp.box.Visible = false

    esp.line = Drawing.new("Line")
    esp.line.Thickness = 1
    esp.line.Visible = false

    -- Skeleton completo: vamos criar linhas para conectar membros principais
    esp.skeleton = {}
    -- Total de linhas necessárias para conectar partes: 9 linhas por exemplo
    for i = 1, 9 do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Visible = false
        esp.skeleton[i] = line
    end

    return esp
end

-- Guarda os ESP criados para cada player
local espObjects = {}

-- Função para checar se jogador está vivo
local function isAlive(player)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        return character.Humanoid.Health > 0
    end
    return false
end

-- Função para projetar 3D para 2D e validar visibilidade
local function getScreenPosition(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen and screenPos.Z > 0
end

-- Atualização por frame
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Check alive and team (se quiser implementar)
            local alive = isAlive(player)
            local notTeam = true -- você pode colocar sua lógica de time aqui

            if alive and notTeam then
                if not espObjects[player] then
                    espObjects[player] = createESPForPlayer(player)
                end

                local esp = espObjects[player]
                local char = player.Character

                -- Pegando partes principais para cálculo da box e skeleton
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local leftUpperArm = char:FindFirstChild("LeftUpperArm")
                local leftLowerArm = char:FindFirstChild("LeftLowerArm")
                local rightUpperArm = char:FindFirstChild("RightUpperArm")
                local rightLowerArm = char:FindFirstChild("RightLowerArm")
                local leftUpperLeg = char:FindFirstChild("LeftUpperLeg")
                local leftLowerLeg = char:FindFirstChild("LeftLowerLeg")
                local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
                local rightLowerLeg = char:FindFirstChild("RightLowerLeg")

                -- Verifica se todas as partes essenciais existem
                if not (hrp and head and torso) then
                    -- Esconde ESP se faltar parte importante
                    esp.box.Visible = false
                    esp.line.Visible = false
                    for _, line in ipairs(esp.skeleton) do
                        line.Visible = false
                    end
                    continue
                end

                local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if not onScreen then
                    -- Jogador fora da tela, esconde ESP
                    esp.box.Visible = false
                    esp.line.Visible = false
                    for _, line in ipairs(esp.skeleton) do
                        line.Visible = false
                    end
                    continue
                end

                -- Cor RGB animada para o ESP
                local color = createRGBColor()

                -- Calcula altura da caixa pela diferença do head e do pé (aproximado)
                local headPos2D, headOnScreen = getScreenPosition(head.Position)
                local footPos = hrp.Position - Vector3.new(0, 3, 0) -- aproximando os pés 3 studs abaixo do hrp
                local footPos2D, footOnScreen = getScreenPosition(footPos)

                if not (headOnScreen and footOnScreen) then
                    esp.box.Visible = false
                    esp.line.Visible = false
                    for _, line in ipairs(esp.skeleton) do
                        line.Visible = false
                    end
                    continue
                end

                local height = math.abs(headPos2D.Y - footPos2D.Y)
                local width = height / 2.5 -- Proporção mais realista

                -- Atualiza caixa ESP
                esp.box.Visible = true
                esp.box.Color = color
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(rootPos.X - width / 2, headPos2D.Y)

                -- Linha do chão até o centro da tela (posição dos pés)
                esp.line.Visible = true
                esp.line.Color = color
                esp.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.line.To = Vector2.new(footPos2D.X, footPos2D.Y)

                -- Skeleton - liga partes com linhas
                local function drawLineBetweenParts(line, partA, partB)
                    if partA and partB then
                        local p1, v1 = getScreenPosition(partA.Position)
                        local p2, v2 = getScreenPosition(partB.Position)
                        if v1 and v2 then
                            line.Visible = true
                            line.Color = color
                            line.From = p1
                            line.To = p2
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end

                -- Conexões do skeleton (ordem das linhas)
                -- 1: Head to Torso
                drawLineBetweenParts(esp.skeleton[1], head, torso)
                -- 2: Torso to LeftUpperArm
                drawLineBetweenParts(esp.skeleton[2], torso, leftUpperArm)
                -- 3: LeftUpperArm to LeftLowerArm
                drawLineBetweenParts(esp.skeleton[3], leftUpperArm, leftLowerArm)
                -- 4: Torso to RightUpperArm
                drawLineBetweenParts(esp.skeleton[4], torso, rightUpperArm)
                -- 5: RightUpperArm to RightLowerArm
                drawLineBetweenParts(esp.skeleton[5], rightUpperArm, rightLowerArm)
                -- 6: Torso to LeftUpperLeg
                drawLineBetweenParts(esp.skeleton[6], torso, leftUpperLeg)
                -- 7: LeftUpperLeg to LeftLowerLeg
                drawLineBetweenParts(esp.skeleton[7], leftUpperLeg, leftLowerLeg)
                -- 8: Torso to RightUpperLeg
                drawLineBetweenParts(esp.skeleton[8], torso, rightUpperLeg)
                -- 9: RightUpperLeg to RightLowerLeg
                drawLineBetweenParts(esp.skeleton[9], rightUpperLeg, rightLowerLeg)

            else
                -- Jogador morto ou aliado: esconde ESP
                if espObjects[player] then
                    espObjects[player].box.Visible = false
                    espObjects[player].line.Visible = false
                    for _, line in ipairs(espObjects[player].skeleton) do
                        line.Visible = false
                    end
                end
            end
        elseif espObjects[player] then
            -- Jogador saiu do jogo, remove ESP
            for _, obj in pairs(espObjects[player]) do
                if typeof(obj) == "table" then
                    for _, sub in pairs(obj) do
                        sub:Remove()
                    end
                else
                    obj:Remove()
                end
            end
            espObjects[player] = nil
        end
    end
end)

-- Limpa os objetos quando o jogo fecha
game:BindToClose(function()
    for _, esp in pairs(espObjects) do
        if esp.box then esp.box:Remove() end
        if esp.line then esp.line:Remove() end
        for _, line in pairs(esp.skeleton) do
            if line then line:Remove() end
        end
    end
end)

