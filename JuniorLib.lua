--[[ 
    Junior Hub - Standalone Stealer GUI 
    Salve este arquivo no GitHub.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- --- CONFIGURAÇÕES VISUAIS (TEMA JUNIOR HUB) ---
local Theme = {
	Background = Color3.fromRGB(20, 25, 30),
	Accent = Color3.fromRGB(0, 255, 255), -- Ciano
	Red = Color3.fromRGB(255, 60, 60),    -- Vermelho para "Desativar"
	TextMain = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 180)
}

-- Evita múltiplas janelas abertas ao mesmo tempo
if CoreGui:FindFirstChild("JuniorHubFixed") then
	CoreGui.JuniorHubFixed:Destroy()
end

-- --- CRIAÇÃO DA UI ---

-- 1. ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JuniorHubFixed"
-- Tenta colocar no CoreGui (mais seguro para exploits), senão PlayerGui
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

-- 2. Janela Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 250) -- Menor e mais compacta
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Cantos e Borda
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
local stroke = Instance.new("UIStroke"); stroke.Color = Theme.Accent; stroke.Thickness = 1; stroke.Transparency = 0.7; stroke.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Text = "🔹 Junior Hub | Stealer"
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Theme.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Botão Fechar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Theme.Red
closeBtn.TextColor3 = Theme.TextMain
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Sistema de Arrastar (Draggable)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = mainFrame.Position
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
mainFrame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- --- ESTRUTURA FIXA (1 ABA, 1 BOTÃO) ---

-- Container da Aba (Visual apenas, já que só tem uma)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -30, 0, 35)
tabContainer.Position = UDim2.new(0, 15, 0, 45)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
tabContainer.Parent = mainFrame
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 6); tc.Parent = tabContainer

local tabLabel = Instance.new("TextLabel")
tabLabel.Size = UDim2.new(1, 0, 1, 0)
tabLabel.BackgroundTransparency = 1
tabLabel.Text = "Stealer" -- Nome da Aba fixo
tabLabel.TextColor3 = Theme.Accent
tabLabel.Font = Enum.Font.GothamBold
tabLabel.TextSize = 14
tabLabel.Parent = tabContainer

-- Container do Conteúdo
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -30, 1, -100)
contentFrame.Position = UDim2.new(0, 15, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- --- O BOTÃO DE AÇÃO ---

local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(1, 0, 0, 50) -- Botão grande
actionButton.Position = UDim2.new(0, 0, 0, 10)
actionButton.BackgroundColor3 = Theme.Accent -- Começa Ciano (Para ativar)
actionButton.Text = "Ativar Stealer"
actionButton.TextColor3 = Color3.fromRGB(20, 20, 20) -- Texto escuro no fundo ciano
actionButton.Font = Enum.Font.GothamBold
actionButton.TextSize = 18
actionButton.Parent = contentFrame
local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(0, 8); ac.Parent = actionButton

-- Efeito de brilho no botão
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Theme.Accent
btnStroke.Thickness = 2
btnStroke.Transparency = 0.5
btnStroke.Parent = actionButton

-- --- LÓGICA DO SCRIPT ---

local isRunning = false
local loopConnection = nil

local function StartSteal()
	print(">>> Stealer INICIADO")
	
	-- Exemplo de loop (Substitua pela sua lógica de Brainrot)
	loopConnection = RunService.RenderStepped:Connect(function()
		-- --> AQUI VAI O CÓDIGO QUE VERIFICA OS BRAINROTS
		-- Exemplo:
		-- local target = GetBestBrainrot()
		-- if target then FireServer(target) end
	end)
end

local function StopSteal()
	print(">>> Stealer PARADO")
	if loopConnection then
		loopConnection:Disconnect()
		loopConnection = nil
	end
end

-- Evento de Clique
actionButton.MouseButton1Click:Connect(function()
	if not isRunning then
		-- AÇÃO: LIGAR
		isRunning = true
		
		-- Muda visual para "Desativar" (Vermelho)
		actionButton.Text = "Desativar Stealer"
		TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Red, TextColor3 = Theme.TextMain}):Play()
		TweenService:Create(btnStroke, TweenInfo.new(0.3), {Color = Theme.Red}):Play()
		
		StartSteal()
	else
		-- AÇÃO: DESLIGAR
		isRunning = false
		
		-- Muda visual para "Ativar" (Ciano)
		actionButton.Text = "Ativar Stealer"
		TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(20,20,20)}):Play()
		TweenService:Create(btnStroke, TweenInfo.new(0.3), {Color = Theme.Accent}):Play()
		
		StopSteal()
	end
end)