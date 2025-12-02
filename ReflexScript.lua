--[[
    ReflexScript.lua (Backend/Lógica)
    Responsável por calcular pesos e decidir qual item roubar.
]]

local Logic = {}

-- 1. Configuração de Pesos (Hierarquia definida por você)
Logic.RarityWeights = {
    ["Common"]        = 1,
    ["Rare"]          = 10,
    ["Epic"]          = 50,
    ["Legendary"]     = 100,
    ["Mythical"]      = 500,
    ["Brainrot God"]  = 1000,
    
    -- Admin e Taco (Menores que Secret/OG)
    ["Admin"]         = 5000, 
    ["Taco"]          = 5000, 

    -- Topo da Cadeia
    ["Secret"]        = 10000,
    ["OG"]            = 100000
}

-- 2. Pasta dos Itens (Ajuste se o jogo usar outro nome, ex: workspace.Drops)
Logic.Folder = workspace:WaitForChild("Brainrots", 5) or workspace

-- 3. Função: Encontrar o Melhor Alvo (Matemática)
function Logic.GetBestTarget()
    local bestItem = nil
    local highestScore = -1 
    
    -- Proteção caso a pasta não exista
    if not Logic.Folder then return nil end

    for _, item in pairs(Logic.Folder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            local rarityName = "Common" -- Padrão
            local itemValue = 0

            -- Tenta ler a raridade (Adaptação para diferentes estruturas de jogo)
            -- Verifica se existe uma pasta Config ou Valores diretos
            if item:FindFirstChild("Config") then
                if item.Config:FindFirstChild("Rarity") then rarityName = item.Config.Rarity.Value end
                if item.Config:FindFirstChild("Value") then itemValue = item.Config.Value.Value end
            elseif item:FindFirstChild("Raridade") then
                rarityName = item.Raridade.Value
            elseif item:FindFirstChild("Rarity") then
                rarityName = item.Rarity.Value
            end

            -- Cálculo do Score
            local weight = Logic.RarityWeights[rarityName] or 0
            
            -- Fórmula: (Peso da Raridade * 1 Milhão) + Valor em Dinheiro
            -- Isso garante que a Raridade sempre ganhe do dinheiro
            local score = (weight * 1000000) + itemValue

            if score > highestScore then
                highestScore = score
                bestItem = item
            end
        end
    end
    return bestItem
end

-- 4. Função: Teleportar (Física)
function Logic.TeleportTo(target)
    local Character = game.Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") and target and target.PrimaryPart then
        -- Teleporta 3 studs acima do item para evitar bugs de chão
        Character.HumanoidRootPart.CFrame = target.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
        
        -- Zera a velocidade para não "escorregar" ao teleportar
        if Character.HumanoidRootPart:FindFirstChild("AssemblyLinearVelocity") then
             Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end

return Logic