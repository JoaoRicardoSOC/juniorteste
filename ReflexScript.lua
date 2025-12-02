local Logic = {}

-- [[ 1. CONFIGURAÇÃO DE PESOS (INTELIGÊNCIA) ]]
-- Define o que é mais importante. O número maior ganha.
Logic.RarityWeights = {
    ["Common"]        = 1,
    ["Uncommon"]      = 2,
    ["Rare"]          = 10,
    ["Epic"]          = 50,
    ["Legendary"]     = 100,
    ["Mythical"]      = 500,
    ["Brainrot God"]  = 1000,
    ["Admin"]         = 5000, 
    ["Taco"]          = 5000, -- Nível alto
    ["Secret"]        = 10000, -- Topo
    ["OG"]            = 10000  -- Topo
}

-- Pasta onde o script vai procurar os itens
Logic.Folder = workspace:WaitForChild("Brainrots", 2) or workspace

-- [[ 2. SISTEMA DE LEITURA (SCANNER) ]]
-- Tenta encontrar a raridade e valor em vários lugares possíveis
function Logic.GetItemData(item)
    local rarity = "Common" -- Padrão se não achar nada
    local value = 0

    -- Lista de nomes comuns que devs usam para raridade
    local rarityNames = {"Rarity", "Raridade", "Tier", "Rank"}
    -- Lista de nomes comuns para valor
    local valueNames = {"Value", "Valor", "Price", "Cost"}

    -- Função auxiliar para buscar dentro de um objeto
    local function searchIn(parent)
        for _, name in pairs(rarityNames) do
            if parent:FindFirstChild(name) then rarity = parent[name].Value break end
        end
        for _, name in pairs(valueNames) do
            if parent:FindFirstChild(name) then value = parent[name].Value break end
        end
    end

    -- 1. Procura direto no Item
    searchIn(item)
    -- 2. Procura numa pasta 'Config' ou 'Configuration' (Muito comum)
    if item:FindFirstChild("Config") then searchIn(item.Config) end
    if item:FindFirstChild("Configuration") then searchIn(item.Configuration) end
    -- 3. Procura em Atributos (Sistema novo do Roblox)
    if item:GetAttribute("Rarity") then rarity = item:GetAttribute("Rarity") end
    if item:GetAttribute("Value") then value = item:GetAttribute("Value") end

    return rarity, value
end

-- [[ 3. CÁLCULO DO MELHOR ALVO ]]
function Logic.GetBestTarget()
    local bestItem = nil
    local highestScore = -1 
    
    for _, item in pairs(Logic.Folder:GetChildren()) do
        -- Verifica se o item é um Modelo e tem uma parte física (PrimaryPart ou HumanoidRootPart)
        local root = item.PrimaryPart or item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("Main")
        
        if root then
            -- Lê os dados usando o scanner inteligente
            local rarityName, itemValue = Logic.GetItemData(item)
            
            -- Pega o peso da tabela (se não existir, usa 0)
            local weight = Logic.RarityWeights[rarityName] or 0
            
            -- [[ FÓRMULA MÁGICA ]]
            -- Peso * 1 Milhão + Valor.
            -- Isso garante que uma raridade maior SEMPRE ganhe de dinheiro.
            local score = (weight * 1000000) + itemValue

            if score > highestScore then
                highestScore = score
                bestItem = item
            end
        end
    end
    return bestItem
end

-- [[ 4. VERIFICAÇÃO DE ALCANCE E ROUBO ]]
function Logic.AttemptSteal(target)
    local Player = game.Players.LocalPlayer
    local Character = Player.Character
    
    if not target or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Main")
    if not rootPart then return end

    -- A. TELEPORTE (Mover até o item)
    -- Teleporta para o CFrame do item
    Character.HumanoidRootPart.CFrame = rootPart.CFrame
    
    -- B. INTERAÇÃO (Apertar o botão)
    -- Procura o ProximityPrompt (o botão "E") dentro do item
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
    
    if prompt then
        -- Verifica se o Prompt está ativado
        if prompt.Enabled then
            -- Verifica distância: Só tenta pegar se estiver dentro do alcance permitido pelo jogo
            local distance = (Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            
            -- Se a distância for menor que o alcance máximo do prompt (com uma margem de erro)
            if distance <= prompt.MaxActivationDistance + 2 then
                -- DISPARA O PROMPT (Roubo)
                fireproximityprompt(prompt)
                return true -- Sucesso
            end
        end
    else
        -- Caso o jogo não use Prompt (seja por toque), o teleporte acima já resolve.
        -- Opcional: Mover o item para o jogador (Client-sided visual, as vezes server sided em jogos ruins)
    end
    return false
end

return Logic