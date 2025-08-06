-- Criar GUI
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
local JumpButton = Instance.new("TextButton", ScreenGui)

-- Estilo do botão
JumpButton.Size = UDim2.new(0, 150, 0, 50)
JumpButton.Position = UDim2.new(0, 20, 0, 100)
JumpButton.Text = "Super Pulo: OFF"
JumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpButton.Font = Enum.Font.SourceSansBold
JumpButton.TextSize = 18
JumpButton.BorderSizePixel = 2
JumpButton.BorderColor3 = Color3.fromRGB(0, 255, 0)

-- Lógica do super pulo
local superPuloAtivo = false
local user = game.Players.LocalPlayer
local humanoid = user.Character:WaitForChild("Humanoid")

JumpButton.MouseButton1Click:Connect(function()
	superPuloAtivo = not superPuloAtivo

	if superPuloAtivo then
		JumpButton.Text = "Super Pulo: ON"
		humanoid.JumpPower = 150 -- valor alto, pode ajustar
	else
		JumpButton.Text = "Super Pulo: OFF"
		humanoid.JumpPower = 50 -- valor padrão do Roblox
	end
end)
