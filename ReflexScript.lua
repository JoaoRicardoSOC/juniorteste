--[[
    ReflexScript.lua (Versão Legit / No-Teleport)
    - Calcula o melhor item.
    - Destaca o item visualmente (ESP).
    - Coleta automaticamente apenas se você estiver perto.
]]

local Logic = {}

-- 1. Pesos de Raridade
Logic.RarityWeights = {
    ["Common"]        = 1,
    ["Uncommon"]      = 2,
    ["Rare"]          = 10,
    ["Epic"]          = 50,
    ["Legendary"]     = 100,
    ["Mythical"]      = 500,
    ["Brainrot God"]  = 1000,
    ["Admin"]         = 5000, 
    ["Taco"]          = 5000, 
    ["Secret"]        = 10000,
    ["OG"]            = 10000
}

Logic.Folder = workspace:WaitForChild("Brainrots", 5) or workspace

-- Variável para controlar o destaque visual anterior (para apagar quando mudar de alvo)
local currentHighlight = nil

-- Função Scanner (Lê raridade e valor)
function Logic.GetItemData(item)
    local rarity = "Common"
    local value = 0
    
    local rarityNames = {"Rarity", "Raridade", "Tier", "Rank"}
    local valueNames = {"Value", "Valor", "Price", "Cost"}

    local function searchIn(parent)
        for _, name in pairs(rarityNames) do
            if parent:FindFirstChild(name) then rarity = parent[name].Value break end
        end
        for _, name in pairs(valueNames) do
            if parent:FindFirstChild(name) then value = parent[name].Value break end
        end
    end

    searchIn(item)
    if item:FindFirstChild("Config") then searchIn(item.Config) end
    if item:FindFirstChild("Configuration") then searchIn(item.Configuration) end
    if item:GetAttribute("Rarity") then rarity = item:GetAttribute("Rarity") end
    if item:GetAttribute("Value") then value = item:GetAttribute("Value") end

    return rarity, value
end

-- Função para Destacar o Alvo (ESP)
-- Faz o item brilhar para você saber onde ir
function Logic.HighlightTarget(target)
    if not target then 
        if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
        return 
    end

    -- Se já estamos destacando este mesmo item, não faz nada
    if currentHighlight and currentHighlight.Parent == target then return end

    -- Remove destaque do item anterior
    if currentHighlight then currentHighlight:Destroy() end

    -- Cria novo destaque
    local hl = Instance.new("Highlight")
    hl.Name = "ReflexESP"
    hl.FillColor = Color3.fromRGB(0, 255, 255) -- Ciano
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = target
    currentHighlight = hl
end

-- Função Lógica Principal
function Logic.GetBestTarget()
    local bestItem = nil
    local highestScore = -1 
    
    if not Logic.Folder then return nil end

    for _, item in pairs(Logic.Folder:GetChildren()) do
        if item:IsA("Model") then
            local root = item.PrimaryPart or item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("Main")
            if root then
                local rarityName, itemValue = Logic.GetItemData(item)
                local weight = Logic.RarityWeights[rarityName] or 0
                local score = (weight * 1000000) + itemValue

                if score > highestScore then
                    highestScore = score
                    bestItem = item
                end
            end
        end
    end
    
    -- Chama o ESP para mostrar o vencedor
    Logic.HighlightTarget(bestItem)
    
    return bestItem
end

-- Função de Roubo (SEM TELEPORTE)
function Logic.AttemptSteal(target)
    local Character = game.Players.LocalPlayer.Character
    if not target or not Character then return end

    local rootPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Main")
    if not rootPart then return end

    -- 1. Verifica se tem Prompt (Botão E)
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    if prompt and prompt.Enabled then
        -- 2. Verifica a distância MANUALMENTE
        local distance = (Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
        
        -- Se você estiver perto o suficiente (MaxDistance do jogo + margem)
        if distance <= prompt.MaxActivationDistance then
            print("[REFLEX] Item no alcance! Coletando: " .. target.Name)
            fireproximityprompt(prompt)
            return true
        end
    end
    
    return false
end

return Logic