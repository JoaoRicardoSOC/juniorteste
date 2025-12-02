--[[ 
    Junior Hub - Standalone Stealer GUI (Completo)
    Recursos: Arrastar, Redimensionar, Minimizar, Fechar e Botão Único.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- --- TEMA JUNIOR HUB ---
local Theme = {
	Background = Color3.fromRGB(20, 25, 30),
	Accent = Color3.fromRGB(0, 255, 255), -- Ciano
	Red = Color3.fromRGB(255, 60, 60),
	TextMain = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 180),
	HeaderHeight = 45
}

-- Evita duplicatas
if CoreGui:FindFirstChild("JuniorHubFixed") then
	CoreGui.JuniorHubFixed:Destroy()
end

-- --- 1. CRIAÇÃO DA BASE ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JuniorHubFixed"
-- Tenta CoreGui (Exploit), senão PlayerGui (Studio)
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 250) -- Tamanho inicial
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true -- IMPORTANTE PARA O MINIMIZAR FUNCIONAR
mainFrame.Parent = screenGui

local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
local stroke = Instance.new("UIStroke"); stroke.Color = Theme.Accent; stroke.Thickness = 1; stroke.Transparency = 0.6; stroke.Parent = mainFrame

-- --- 2. SISTEMA DE ARRASTAR (DRAGGABLE) ---
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = mainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- --- 3. CABEÇALHO E BOTÕES DE CONTROLE ---
local title = Instance.new("TextLabel")
title.Text = "🔹 Junior Hub | Stealer"
title.Size = UDim2.new(1, -100, 0, Theme.HeaderHeight)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Theme.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Container dos botões (Minimizar e Fechar)
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(0, 80, 0, Theme.HeaderHeight)
controlsFrame.Position = UDim2.new(1, -85, 0, 0)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = controlsFrame

local function createCtrlBtn(txt, color, callback)
	local btn = Instance.new("TextButton")
	btn.Text = txt; btn.BackgroundColor3 = color; btn.TextColor3 = Theme.TextMain
	btn.Size = UDim2.new(0, 28, 0, 28); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
	btn.Parent = controlsFrame
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Botão Minimizar (-)
local isMinimized = false
local savedSize = mainFrame.Size -- Guarda o tamanho antes de minimizar
local resizeHandle -- Declarar aqui para usar depois

createCtrlBtn("-", Color3.fromRGB(50, 50, 60), function()
	if not isMinimized then
		-- MINIMIZAR
		savedSize = mainFrame.Size
		resizeHandle.Visible = false -- Esconde o puxador
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(savedSize.X.Scale, savedSize.X.Offset, 0, Theme.HeaderHeight)}):Play()
		isMinimized = true
	else
		-- RESTAURAR
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = savedSize}):Play()
		wait(0.4)
		if not isMinimized then resizeHandle.Visible = true end -- Mostra o puxador de volta
		isMinimized = false
	end
end)

-- Botão Fechar (X)
createCtrlBtn("X", Theme.Red, function() screenGui:Destroy() end)

-- --- 4. REDIMENSIONAR (RESIZE HANDLE) ---
resizeHandle = Instance.new("ImageButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.AnchorPoint = Vector2.new(0, 0)
resizeHandle.BackgroundColor3 = Theme.Accent
resizeHandle.BackgroundTransparency = 0.5 
resizeHandle.Image = "rbxassetid://3577437372"
resizeHandle.ImageColor3 = Theme.Background
resizeHandle.ImageTransparency = 0.2
resizeHandle.Parent = mainFrame
local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,4); rc.Parent = resizeHandle

local isResizing, rStart, origSize = false, nil, nil
resizeHandle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing=true; rStart=i.Position; origSize=mainFrame.AbsoluteSize end end)
resizeHandle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing=false end end)
UserInputService.InputChanged:Connect(function(i)
	if isResizing and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - rStart
		-- Limite mínimo: 300x150
		mainFrame.Size = UDim2.new(0, math.max(300, origSize.X+delta.X), 0, math.max(150, origSize.Y+delta.Y))
	end
end)

-- --- 5. CONTEÚDO (ABA + BOTÃO) ---

-- Aba Visual "Stealer"
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -30, 0, 30)
tabContainer.Position = UDim2.new(0, 15, 0, 50)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
tabContainer.Parent = mainFrame
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 6); tc.Parent = tabContainer

local tabLabel = Instance.new("TextLabel")
tabLabel.Size = UDim2.new(1, 0, 1, 0)
tabLabel.BackgroundTransparency = 1
tabLabel.Text = "Stealer"
tabLabel.TextColor3 = Theme.Accent
tabLabel.Font = Enum.Font.GothamBold
tabLabel.TextSize = 14
tabLabel.Parent = tabContainer

-- Botão Gigante de Ação
local actionButton = Instance.new("TextButton")
actionButton.Size = UDim2.new(1, -30, 1, -100) -- Ocupa o resto do espaço
actionButton.Position = UDim2.new(0, 15, 0, 90)
actionButton.BackgroundColor3 = Theme.Accent
actionButton.Text = "Ativar Stealer"
actionButton.TextColor3 = Color3.fromRGB(20, 20, 20)
actionButton.Font = Enum.Font.GothamBlack -- Fonte mais grossa
actionButton.TextSize = 22
actionButton.Parent = mainFrame
local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(0, 8); ac.Parent = actionButton

-- --- 6. LÓGICA DO SCRIPT ---

local isRunning = false
local loopConnection = nil

-- Função de Roubo (Substitua pela sua lógica real)
local function StartSteal()
	loopConnection = RunService.RenderStepped:Connect(function()
		-- Lógica aqui
	end)
end

local function StopSteal()
	if loopConnection then loopConnection:Disconnect() loopConnection = nil end
end

actionButton.MouseButton1Click:Connect(function()
	if not isRunning then
		-- LIGAR
		isRunning = true
		actionButton.Text = "Desativar Stealer"
		TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Red, TextColor3 = Theme.TextMain}):Play()
		StartSteal()
	else
		-- DESLIGAR
		isRunning = false
		actionButton.Text = "Ativar Stealer"
		TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(20,20,20)}):Play()
		StopSteal()
	end
end)