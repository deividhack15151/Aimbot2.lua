-- ROBLOX AIMBOT PRO V3 - GUI COMPLETA COM ESP BÁSICO, SLIDERS, TOGGLES E SALVAMENTO
-- Versão simplificada do Wallhack para desempenho e visual limpo

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().Aimbot = getgenv().Aimbot or {
    Enabled = true,
    TeamCheck = true,
    LockPart = "Head",
    TriggerKey = Enum.KeyCode.E,
    FOV = 120,
    AimSpeed = 0.3,
    MaxDistance = 500,
    ESPDistance = 400,
    Wallhack = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    SaveFile = "aimbot_config.json"
}

local espBoxes = {}

RunService.RenderStepped:Connect(function()
    if not getgenv().Aimbot.Wallhack then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end

            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            if distance > getgenv().Aimbot.ESPDistance then
                if espBoxes[player] and espBoxes[player].Visible then
                    espBoxes[player].Visible = false
                end
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if not onScreen then
                if espBoxes[player] and espBoxes[player].Visible then
                    espBoxes[player].Visible = false
                end
                continue
            end

            if not espBoxes[player] then
                espBoxes[player] = Drawing.new("Square")
                espBoxes[player].Thickness = 1
                espBoxes[player].Filled = false
                espBoxes[player].Color = getgenv().Aimbot.ESPColor
            end

            espBoxes[player].Size = Vector2.new(50, 100)
            espBoxes[player].Position = Vector2.new(pos.X - 25, pos.Y - 50)
            espBoxes[player].Visible = true
        end
    end

    -- Limpa jogadores desconectados ou mortos
    for player, box in pairs(espBoxes) do
        if not player:IsDescendantOf(Players) or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character:FindFirstChild("Humanoid").Health <= 0 then
            if box then box:Remove() end
            espBoxes[player] = nil
        end
    end
end)

game:BindToClose(function()
    if writefile then
        writefile(getgenv().Aimbot.SaveFile, HttpService:JSONEncode(getgenv().Aimbot))
    end
end)
