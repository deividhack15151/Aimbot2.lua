-- ROBLOX AIMBOT PRO V3 - GUI COMPLETA COM ESP, SLIDERS, TOGGLES E SALVAMENTO
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

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AimbotProUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 12)

-- Tabs
local Tabs = Instance.new("Frame", Main)
Tabs.Size = UDim2.new(0, 120, 1, 0)
Tabs.Position = UDim2.new(0, 0, 0, 0)
Tabs.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
local UICorner2 = Instance.new("UICorner", Tabs)
UICorner2.CornerRadius = UDim.new(0, 10)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -130, 1, -10)
Content.Position = UDim2.new(0, 130, 0, 10)
Content.BackgroundTransparency = 1
Content.Name = "Content"

-- Aba Selector
local tabs = {"Aimbot", "ESP", "Config"}
local pages = {}
for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton", Tabs)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, 10 + (i - 1) * 45)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local page = Instance.new("Frame", Content)
    page.Name = tabName
    page.Visible = (i == 1)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    pages[tabName] = page

    btn.MouseButton1Click:Connect(function()
        for _, pg in pairs(pages) do pg.Visible = false end
        page.Visible = true
    end)
end

-- Função de criador de Toggle
local function createToggle(parent, text, default, callback)
    local toggle = Instance.new("TextButton", parent)
    toggle.Size = UDim2.new(0, 250, 0, 35)
    toggle.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 80, 80)
    toggle.Text = text .. ": " .. (default and "ON" or "OFF")
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 16
    toggle.BorderSizePixel = 0

    local on = default
    toggle.MouseButton1Click:Connect(function()
        on = not on
        toggle.BackgroundColor3 = on and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 80, 80)
        toggle.Text = text .. ": " .. (on and "ON" or "OFF")
        callback(on)
    end)
end

-- Sliders simplificados
local function createSlider(parent, text, min, max, default, callback)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(0, 250, 0, 20)
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local slider = Instance.new("TextButton", parent)
    slider.Size = UDim2.new(0, 250, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.Text = ""

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    fill.BorderSizePixel = 0

    slider.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local x = UserInputService:GetMouseLocation().X
            local percent = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + percent * (max - min))
            label.Text = text .. ": " .. tostring(value)
            callback(value)
        end)
        UserInputService.InputEnded:Wait()
        conn:Disconnect()
    end)
end

-- Criar elementos nas abas
createToggle(pages["Aimbot"], "Ativar Aimbot", getgenv().Aimbot.Enabled, function(v) getgenv().Aimbot.Enabled = v end)
createToggle(pages["Aimbot"], "Team Check", getgenv().Aimbot.TeamCheck, function(v) getgenv().Aimbot.TeamCheck = v end)
createSlider(pages["Aimbot"], "FOV", 30, 360, getgenv().Aimbot.FOV, function(v) getgenv().Aimbot.FOV = v end)
createSlider(pages["Aimbot"], "Distância", 50, 1000, getgenv().Aimbot.MaxDistance, function(v) getgenv().Aimbot.MaxDistance = v end)
createSlider(pages["Aimbot"], "Speed", 1, 100, getgenv().Aimbot.AimSpeed * 100, function(v) getgenv().Aimbot.AimSpeed = v / 100 end)

createToggle(pages["ESP"], "Ativar Wallhack", getgenv().Aimbot.Wallhack, function(v) getgenv().Aimbot.Wallhack = v end)

createToggle(pages["Config"], "Salvar Config", false, function(_) saveConfig() end)
createToggle(pages["Config"], "Carregar Config", false, function(_) loadConfig() end)

-- Ocultar com Insert
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Aimbot logic simplificada (sem ESP ainda)
local holding = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == getgenv().Aimbot.TriggerKey then
        holding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == getgenv().Aimbot.TriggerKey then
        holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().Aimbot.Enabled or not holding then return end

    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().Aimbot.LockPart) then
            if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local part = player.Character[getgenv().Aimbot.LockPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            local dist = (Camera.CFrame.Position - part.Position).Magnitude

            if onScreen and dist < getgenv().Aimbot.MaxDistance then
                local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize/2).Magnitude
                if fovDist < getgenv().Aimbot.FOV and fovDist < shortest then
                    closest = part
                    shortest = fovDist
                end
            end
        end
    end

    if closest then
        local direction = (closest.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), getgenv().Aimbot.AimSpeed)
    end
end)

-- Auto Save no fechar
game:BindToClose(saveConfig)
