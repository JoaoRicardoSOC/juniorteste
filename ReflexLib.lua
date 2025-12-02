--[[ 
    Reflex Hub - Stealer GUI (Versão Final Completa)
    - Tema: Ciano (Reflex Hub)
    - Funcionalidades: Arrastar, Redimensionar, Minimizar (Animado) e Lógica de Steal.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- --- CONFIGURAÇÕES VISUAIS ---
local Theme = {
	Background = Color3.fromRGB(20, 25, 30),
	Accent = Color3.fromRGB(0, 255, 255), -- Ciano Neon
	Red = Color3.fromRGB(255, 60, 60),    -- Vermelho
	TextMain = Color3.fromRGB(255, 255, 255),
	HeaderHeight = 45 -- Altura da barra de título
}

-- Evita janelas duplicadas na tela
if CoreGui:FindFirstChild("ReflexHub") then
	CoreGui.ReflexHub:Destroy()
end

-- --- 1. JANELA PRINCIPAL ---
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReflexHub"
-- Tenta colocar no CoreGui (Exploits), se falhar vai pro PlayerGui
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 250) -- Tamanho inicial
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Theme.Background
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true -- CRUCIAL: Corta o conteúdo ao minimizar
mainFrame.Parent = screenGui

-- Arredondamento e Borda Neon
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
local stroke = Instance.new("UIStroke"); stroke.Color = Theme.Accent; stroke.Thickness = 1; stroke.Transparency = 0.6; stroke.Parent = mainFrame

-- --- 2. TÍTULO E BOTÕES DE JANELA ---
local title = Instance.new("TextLabel")
title.Text = "🔹 Reflex Hub | Stealer"
title.Size = UDim2.new(1, -100, 0, Theme.HeaderHeight)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Theme.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Container dos botões (Minimizar e Fechar) no canto direito
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

-- Função para criar os botões pequenos do topo
local function createTopBtn(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.TextColor3 = Theme.TextMain
	btn.Size = UDim2.new(0, 28, 0, 28)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Parent = controlsFrame
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Variáveis de controle
local isMinimized = false
local savedSize = mainFrame.Size
local resizeHandle -- Definido mais abaixo

-- BOTÃO MINIMIZAR (-)
local minBtn = createTopBtn("-", Color3.fromRGB(50, 50, 60), function()
	-- Usa 'minBtn' que será definido logo após a criação
end)

-- Lógica do Minimizar (separada para acessar o próprio botão)
minBtn.MouseButton1Click:Connect(function()
	if not isMinimized then
		-- AÇÃO: MINIMIZAR (Fechar persiana)
		savedSize = mainFrame.Size -- Salva o tamanho atual
		if resizeHandle then resizeHandle.Visible = false end -- Esconde o redimensionador
		
		-- Animação para altura do cabeçalho
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(savedSize.X.Scale, savedSize.X.Offset, 0, Theme.HeaderHeight)}):Play()
		
		minBtn.Text = "+" -- Muda ícone para abrir
		isMinimized = true
	else
		-- AÇÃO: RESTAURAR (Abrir persiana)
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = savedSize}):Play()
		
		wait(0.4) -- Espera animação terminar
		if not isMinimized then 
			if resizeHandle then resizeHandle.Visible = true end -- Mostra redimensionador
		end
		
		minBtn.Text = "-" -- Muda ícone para minimizar
		isMinimized = false
	end
end)

-- BOTÃO FECHAR (X)
createTopBtn("X", Theme.Red, function()
	screenGui:Destroy()
end)

-- --- 3. ARRASTAR JANELA (DRAGGABLE) ---
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

-- --- 4. REDIMENSIONAR (RESIZE) ---
resizeHandle = Instance.new("ImageButton")
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20) -- Canto inferior direito
resizeHandle.AnchorPoint = Vector2.new(0, 0)
resizeHandle.BackgroundColor3 = Theme.Accent
resizeHandle.BackgroundTransparency = 0.5 
resizeHandle.Image = "rbxassetid://3577437372" -- Ícone de canto
resizeHandle.ImageColor3 = Theme.Background
resizeHandle.ImageTransparency = 0.2
resizeHandle.Parent = mainFrame
local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,4); rc.Parent = resizeHandle

local isResizing, rStart, origSize = false, nil, nil
resizeHandle.InputBegan:Connect(function(i) 
	if i.UserInputType == Enum.UserInputType.MouseButton1 then 
		isResizing=true; rStart=i.Position; origSize=mainFrame.AbsoluteSize 
	end 
end)
resizeHandle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing=false end end)
UserInputService.InputChanged:Connect(function(i)
	if isResizing and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - rStart
		-- Limite mínimo (300x150) para não quebrar a UI
		mainFrame.Size = UDim2.new(0, math.max(300, origSize.X+delta.X), 0, math.max(150, origSize.Y+delta.Y))
	end
end)

-- --- 5. CONTEÚDO (ABA E BOTÃO DE AÇÃO) ---

-- Aba "Stealer"
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
actionButton.Size = UDim2.new(1, -30, 1, -100) -- Ocupa o resto do espaço automaticamente
actionButton.Position = UDim2.new(0, 15, 0, 90)
actionButton.BackgroundColor3 = Theme.Accent
actionButton.Text = "Ativar Stealer"
actionButton.TextColor3 = Color3.fromRGB(20, 20, 20)
actionButton.Font = Enum.Font.GothamBlack
actionButton.TextSize = 22
actionButton.Parent = mainFrame
local ac = Instance.new("UICorner"); ac.CornerRadius = UDim.new(0, 8); ac.Parent = actionButton

-- --- 6. CONEXÃO COM A LÓGICA (Backend) ---

local LogicURL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/ReflexScript.lua"
local StealerLogic = loadstring(game:HttpGet(LogicURL))()

local isRunning = false
local loopConnection = nil

local function StartSteal()
    print(">>> [REFLEX HUB] Auto-Collect Iniciado (Sem Teleporte)")
    
    loopConnection = RunService.RenderStepped:Connect(function()
        -- 1. Calcula e ILUMINA o melhor alvo
        local target = StealerLogic.GetBestTarget()
        
        -- 2. Se houver um alvo, verifica se você chegou perto dele
        if target then
            StealerLogic.AttemptSteal(target)
        end
    end)
end

local function StopSteal()
    print(">>> [REFLEX HUB] Parado.")
    if loopConnection then 
        loopConnection:Disconnect() 
        loopConnection = nil 
    end
    -- Remove o brilho (ESP) do último item quando desliga
    if StealerLogic.HighlightTarget then StealerLogic.HighlightTarget(nil) end
end

-- Conexão do Botão
actionButton.MouseButton1Click:Connect(function()
    if not isRunning then
        isRunning = true
        actionButton.Text = "Desativar Stealer"
        TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Red, TextColor3 = Theme.TextMain}):Play()
        StartSteal()
    else
        isRunning = false
        actionButton.Text = "Ativar Stealer"
        TweenService:Create(actionButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(20,20,20)}):Play()
        StopSteal()
    end
end)