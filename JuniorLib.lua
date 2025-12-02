-- Junior Hub UI Library (Cyan Theme)
-- Salve no GitHub como "JuniorLib.lua"

local Library = {}

-- Serviços
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Paleta de Cores (Fácil de editar no futuro)
local Theme = {
	Background = Color3.fromRGB(20, 25, 30),      -- Fundo escuro azulado
	Accent = Color3.fromRGB(0, 255, 255),         -- Ciano Neon
	TextMain = Color3.fromRGB(255, 255, 255),     -- Branco
	TextDim = Color3.fromRGB(180, 180, 180),      -- Cinza claro
	ButtonOff = Color3.fromRGB(40, 45, 50),       -- Botão desligado
	ButtonOn = Color3.fromRGB(0, 200, 220),       -- Botão ligado (Ciano levemente mais escuro para leitura)
	Red = Color3.fromRGB(255, 60, 60)             -- Botão fechar
}

function Library:CreateWindow(titleText)
	local Window = {}
	
	-- 1. ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "JuniorHubUI"
	
	-- Detecta se é Jogo ou Studio/Exploit
	if game.PlaceId == 0 then
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	else
		pcall(function() screenGui.Parent = CoreGui end)
		if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
	end
	screenGui.ResetOnSpawn = false

	-- 2. MainFrame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 500, 0, 350)
	mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
	mainFrame.BackgroundColor3 = Theme.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui

	-- Cantos Arredondados
	local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = mainFrame
	
	-- Borda Neon (Stroke) - Toque moderno extra
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Accent
	stroke.Thickness = 1
	stroke.Transparency = 0.8 -- Bem sutil
	stroke.Parent = mainFrame
	
	-- Título
	local title = Instance.new("TextLabel")
	title.Text = "🔹 " .. titleText -- Adicionei um ícone simples
	title.Size = UDim2.new(1, -100, 0, 45)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Theme.Accent -- Título em Ciano
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = mainFrame

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
	mainFrame.InputEnded:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
	end)

	-- Botões de Controle (Minimizar/Fechar)
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Size = UDim2.new(0, 90, 0, 45)
	controlsFrame.Position = UDim2.new(1, -95, 0, 0)
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.Parent = mainFrame
	
	local layoutControls = Instance.new("UIListLayout")
	layoutControls.FillDirection = Enum.FillDirection.Horizontal
	layoutControls.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layoutControls.VerticalAlignment = Enum.VerticalAlignment.Center
	layoutControls.Padding = UDim.new(0, 8); layoutControls.Parent = controlsFrame
	
	local function makeCtrlBtn(txt, col, cb)
		local b = Instance.new("TextButton")
		b.Text = txt; b.TextColor3 = Theme.TextMain; b.BackgroundColor3 = col
		b.Size = UDim2.new(0,30,0,30); b.Parent = controlsFrame
		b.Font = Enum.Font.GothamBold; b.TextSize = 14
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = b -- Quadrado arredondado (moderno)
		b.MouseButton1Click:Connect(cb)
		return b
	end
	
	-- Lógica Minimizar/Fechar
	local minimized = false
	local savedSize = mainFrame.Size
	local minBtn = makeCtrlBtn("-", Color3.fromRGB(50, 50, 60), function() -- Botão cinza escuro
		if not minimized then
			savedSize = mainFrame.Size
			TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(savedSize.X.Scale, savedSize.X.Offset, 0, 45)}):Play()
			minimized = true
		else
			TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = savedSize}):Play()
			minimized = false
		end
	end)
	makeCtrlBtn("X", Theme.Red, function() screenGui:Destroy() end)

	-- Handle de Redimensionar (Triângulo Ciano)
	local resizeHandle = Instance.new("ImageButton")
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.AnchorPoint = Vector2.new(0,0); resizeHandle.BackgroundColor3 = Theme.Accent
	resizeHandle.BackgroundTransparency = 0.5 
	resizeHandle.Image = "rbxassetid://3577437372"
	resizeHandle.ImageColor3 = Theme.Background -- Ícone escuro sobre fundo ciano
	resizeHandle.ImageTransparency = 0.2
	resizeHandle.Parent = mainFrame
	local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,4); rc.Parent = resizeHandle

	-- Lógica Resize
	local isResizing, resizeStart, originalSize = false, nil, nil
	resizeHandle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing=true; resizeStart=i.Position; originalSize=mainFrame.AbsoluteSize end end)
	resizeHandle.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing=false end end)
	UserInputService.InputChanged:Connect(function(i)
		if isResizing and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - resizeStart
			mainFrame.Size = UDim2.new(0, math.max(300, originalSize.X+delta.X), 0, math.max(200, originalSize.Y+delta.Y))
		end
	end)

	-- Containers
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Size = UDim2.new(1, -30, 0, 35); tabsContainer.Position = UDim2.new(0, 15, 0, 50); tabsContainer.BackgroundTransparency = 1; tabsContainer.Parent = mainFrame
	local tabsLayout = Instance.new("UIListLayout"); tabsLayout.FillDirection = Enum.FillDirection.Horizontal; tabsLayout.Padding = UDim.new(0, 8); tabsLayout.Parent = tabsContainer

	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -30, 1, -100); contentContainer.Position = UDim2.new(0, 15, 0, 95); contentContainer.BackgroundTransparency = 1; contentContainer.Parent = mainFrame

	local tabs = {} 

	-- --- FUNÇÃO CRIAR ABA ---
	function Window:CreateTab(name)
		local Tab = {}
		
		local tabBtn = Instance.new("TextButton")
		tabBtn.Text = name
		tabBtn.Size = UDim2.new(0, 0, 1, 0) -- Largura automática (veja abaixo)
		tabBtn.AutomaticSize = Enum.AutomaticSize.X -- Ajusta largura ao texto
		tabBtn.PaddingLeft = UDim.new(0, 15); tabBtn.PaddingRight = UDim.new(0, 15) -- Espaçamento interno
		tabBtn.Parent = tabsContainer
		tabBtn.BackgroundColor3 = Theme.ButtonOff
		tabBtn.TextColor3 = Theme.TextDim
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 13
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = tabBtn
		
		-- Página
		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false; page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Theme.Accent
		page.Parent = contentContainer
		local pLayout = Instance.new("UIListLayout"); pLayout.Padding = UDim.new(0, 8); pLayout.Parent = page
		
		-- Trocar Aba
		tabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(contentContainer:GetChildren()) do p.Visible = false end
			for _, t in pairs(tabsContainer:GetChildren()) do 
				if t:IsA("TextButton") then 
					TweenService:Create(t, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ButtonOff, TextColor3 = Theme.TextDim}):Play()
				end 
			end
			page.Visible = true
			TweenService:Create(tabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background}):Play() -- Fica Ciano com texto escuro
		end)
		
		-- Ativar primeira aba
		if #tabs == 0 then
			page.Visible = true
			tabBtn.BackgroundColor3 = Theme.Accent; tabBtn.TextColor3 = Theme.Background
		end
		table.insert(tabs, page)

		-- --- ELEMENTOS (TOGGLE) ---
		function Tab:CreateToggle(text, default, callback)
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Size = UDim2.new(1, -5, 0, 42)
			toggleBtn.Parent = page
			toggleBtn.Font = Enum.Font.GothamMedium
			toggleBtn.TextSize = 14
			toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
			toggleBtn.Text = "      " .. text -- Espaço para o ícone
			toggleBtn.BackgroundColor3 = Theme.ButtonOff
			toggleBtn.TextColor3 = Theme.TextDim
			toggleBtn.AutoButtonColor = false -- Animação manual
			
			local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = toggleBtn
			
			-- Indicador Visual (Bolinha ou Quadrado na direita)
			local statusInd = Instance.new("Frame")
			statusInd.Size = UDim2.new(0, 10, 0, 10)
			statusInd.Position = UDim2.new(1, -25, 0.5, -5)
			statusInd.BackgroundColor3 = Color3.fromRGB(60,60,60)
			statusInd.Parent = toggleBtn
			local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(1,0); sc.Parent = statusInd
			
			local isOn = default
			local function update()
				if isOn then
					TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background}):Play() -- Fundo fica escuro
					TweenService:Create(statusInd, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play() -- Bolinha fica Ciano
					toggleBtn.TextColor3 = Theme.TextMain
					
					-- Efeito Neon na Bolinha
					local glow = statusInd:FindFirstChild("Glow") or Instance.new("UIStroke")
					glow.Name = "Glow"; glow.Color = Theme.Accent; glow.Thickness = 2; glow.Transparency = 0.5; glow.Parent = statusInd
				else
					TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.ButtonOff}):Play()
					TweenService:Create(statusInd, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
					toggleBtn.TextColor3 = Theme.TextDim
					if statusInd:FindFirstChild("Glow") then statusInd.Glow:Destroy() end
				end
				pcall(callback, isOn)
			end
			
			toggleBtn.MouseButton1Click:Connect(function() isOn = not isOn; update() end)
			if default then update() end
		end
		
		-- --- ELEMENTOS (BUTTON) ---
		function Tab:CreateButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -5, 0, 42)
			btn.Text = text
			btn.BackgroundColor3 = Theme.ButtonOff
			btn.TextColor3 = Theme.TextMain
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.Parent = page
			local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = btn
			
			btn.MouseButton1Click:Connect(function()
				-- Efeito de clique rápido
				local oldColor = btn.BackgroundColor3
				btn.BackgroundColor3 = Theme.Accent
				btn.TextColor3 = Theme.Background
				wait(0.1)
				TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = oldColor, TextColor3 = Theme.TextMain}):Play()
				callback()
			end)
		end

		return Tab
	end
	
	return Window
end

return Library