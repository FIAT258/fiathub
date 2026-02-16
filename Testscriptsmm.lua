-- AVATAR COPIER COMPLETO - TODOS OS ITEMS E TODOS OS PLAYERS
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")

-- Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 280)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "👤 COPIADOR COMPLETO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = titleBar

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -45)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Dropdown (MOSTRAR TODOS OS PLAYERS)
local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1, 0, 0, 40)
dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
dropdownButton.Text = "📋 Selecione um jogador ▼"
dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownButton.Parent = container

-- Menu dropdown
local dropdownMenu = Instance.new("ScrollingFrame")
dropdownMenu.Size = UDim2.new(1, 0, 0, 150)
dropdownMenu.Position = UDim2.new(0, 0, 0, 45)
dropdownMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
dropdownMenu.Visible = false
dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownMenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownMenu.Parent = container

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Pronto"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Parent = container

-- Barra de progresso
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(1, 0, 0, 5)
progressBar.Position = UDim2.new(0, 0, 0, 135)
progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
progressBar.Parent = container

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
progressFill.Parent = progressBar

-- Contador
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 0, 20)
counterLabel.Position = UDim2.new(0, 0, 0, 145)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "0/0 itens"
counterLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
counterLabel.TextSize = 11
counterLabel.Parent = container

-- Botão copiar
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(1, 0, 0, 45)
copyButton.Position = UDim2.new(0, 0, 1, -50)
copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
copyButton.Text = "🔄 COPIAR TUDO (1s POR ID)"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = container

-- Variáveis
local selectedPlayer = nil
local isCopying = false
local allIds = {}

-- ========== FUNÇÃO COMPLETA DE EXTRAÇÃO ==========
local function extrairTodasPartes(jogador)
    local ids = {}
    local char = jogador.Character
    if not char then 
        print("❌ Personagem não carregado:", jogador.Name)
        return ids 
    end
    
    print("\n🔍 Extraindo TODOS os items de:", jogador.Name)
    statusLabel.Text = "🔍 Extraindo items..."
    
    -- 1. ACESSÓRIOS (chapéus, cabelo, óculos, mochilas, etc)
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                -- Mesh (acessórios 3D)
                local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("BlockMesh")
                if mesh and mesh.MeshId ~= "" then
                    local id = mesh.MeshId:match("%d+")
                    if id then 
                        table.insert(ids, tonumber(id))
                        print("   🎩 Acessório (Mesh):", id)
                    end
                end
                
                -- Textura
                local texture = handle:FindFirstChild("Texture")
                if texture and texture.Texture ~= "" then
                    local id = texture.Texture:match("%d+")
                    if id then 
                        table.insert(ids, tonumber(id))
                        print("   🎨 Acessório (Textura):", id)
                    end
                end
            end
        end
    end
    
    -- 2. ROUPAS PRINCIPAIS
    local shirt = char:FindFirstChildOfClass("Shirt")
    if shirt and shirt.ShirtTemplate ~= "" then
        local id = shirt.ShirtTemplate:match("%d+")
        if id then 
            table.insert(ids, tonumber(id))
            print("   👕 Camisa:", id)
        end
    end
    
    local pants = char:FindFirstChildOfClass("Pants")
    if pants and pants.PantsTemplate ~= "" then
        local id = pants.PantsTemplate:match("%d+")
        if id then 
            table.insert(ids, tonumber(id))
            print("   👖 Calça:", id)
        end
    end
    
    local graphic = char:FindFirstChildOfClass("ShirtGraphic")
    if graphic and graphic.Graphic ~= "" then
        local id = graphic.Graphic:match("%d+")
        if id then 
            table.insert(ids, tonumber(id))
            print("   🖼️ Graphic:", id)
        end
    end
    
    -- 3. PARTES DO CORPO (HUMANOID DESCRIPTION)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Tentar pegar HumanoidDescription
        local desc = humanoid:FindFirstChild("HumanoidDescription") or Instance.new("HumanoidDescription")
        pcall(function() 
            desc = humanoid:GetAppliedDescription() 
        end)
        
        -- Face
        if desc.Face and desc.Face ~= 0 then
            table.insert(ids, desc.Face)
            print("   😀 Face:", desc.Face)
        end
        
        -- Cabeça
        if desc.Head and desc.Head ~= 0 then
            table.insert(ids, desc.Head)
            print("   🧠 Cabeça:", desc.Head)
        end
        
        -- Torso
        if desc.Torso and desc.Torso ~= 0 then
            table.insert(ids, desc.Torso)
            print("   👕 Torso:", desc.Torso)
        end
        
        -- Braços
        if desc.LeftArm and desc.LeftArm ~= 0 then
            table.insert(ids, desc.LeftArm)
            print("   💪 Braço Esquerdo:", desc.LeftArm)
        end
        
        if desc.RightArm and desc.RightArm ~= 0 then
            table.insert(ids, desc.RightArm)
            print("   💪 Braço Direito:", desc.RightArm)
        end
        
        -- Pernas
        if desc.LeftLeg and desc.LeftLeg ~= 0 then
            table.insert(ids, desc.LeftLeg)
            print("   🦵 Perna Esquerda:", desc.LeftLeg)
        end
        
        if desc.RightLeg and desc.RightLeg ~= 0 then
            table.insert(ids, desc.RightLeg)
            print("   🦵 Perna Direita:", desc.RightLeg)
        end
    end
    
    -- 4. ANIMAÇÕES
    local animate = char:FindFirstChild("Animate")
    if animate then
        for _, anim in ipairs(animate:GetChildren()) do
            if anim:IsA("Animation") and anim.AnimationId ~= "" then
                local id = anim.AnimationId:match("%d+")
                if id then 
                    table.insert(ids, tonumber(id))
                    print("   💃 Animação:", id)
                end
            end
        end
    end
    
    -- 5. CORPO PADRÃO (se tiver)
    for _, part in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local meshPart = char:FindFirstChild(part)
        if meshPart and meshPart:IsA("MeshPart") and meshPart.MeshId ~= "" then
            local id = meshPart.MeshId:match("%d+")
            if id then 
                table.insert(ids, tonumber(id))
                print("   🧩 Mesh " .. part .. ":", id)
            end
        end
    end
    
    -- Remover duplicatas
    local unicos = {}
    local vistos = {}
    for _, id in ipairs(ids) do
        if not vistos[id] then
            vistos[id] = true
            table.insert(unicos, id)
        end
    end
    
    print("✅ TOTAL de IDs únicos:", #unicos)
    return unicos
end

-- ========== APLICAR ID ==========
local function aplicarId(id)
    local args = {id}  -- <<< ID ATUAL
    local success = pcall(function()
        replicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(unpack(args))
    end)
    return success
end

-- ========== CÓPIA SEQUENCIAL ==========
local function copiarTudo(jogador)
    if not jogador then 
        statusLabel.Text = "❌ Selecione um jogador!" 
        return 
    end
    
    if isCopying then 
        statusLabel.Text = "⏳ Já está copiando..." 
        return 
    end
    
    statusLabel.Text = "🔍 Extraindo TODOS os items..."
    allIds = extrairTodasPartes(jogador)
    
    if #allIds == 0 then
        statusLabel.Text = "❌ Nenhum item encontrado!"
        return
    end
    
    isCopying = true
    copyButton.Text = "⏸️ PARAR"
    copyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    counterLabel.Text = string.format("0/%d itens", #allIds)
    
    local sucessos = 0
    local falhas = 0
    
    for i, id in ipairs(allIds) do
        if not isCopying then break end
        
        -- Atualizar progresso
        progressFill.Size = UDim2.new((i-1)/#allIds, 0, 1, 0)
        counterLabel.Text = string.format("%d/%d itens", i-1, #allIds)
        statusLabel.Text = string.format("📦 ID %d/%d: %d", i, #allIds, id)
        
        print(string.format("▶️ Aplicando ID %d/%d: %d", i, #allIds, id))
        
        if aplicarId(id) then
            sucessos = sucessos + 1
            print("   ✅ Sucesso")
        else
            falhas = falhas + 1
            print("   ❌ Falha")
        end
        
        if i < #allIds and isCopying then
            wait(1)  -- 1 SEGUNDO ENTRE IDs
        end
    end
    
    if isCopying then
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        counterLabel.Text = string.format("%d/%d itens", #allIds, #allIds)
        statusLabel.Text = string.format("✅ Concluído! S:%d F:%d", sucessos, falhas)
        print(string.format("\n✅ FINALIZADO! Sucessos: %d, Falhas: %d", sucessos, falhas))
    else
        statusLabel.Text = "⏹️ Parado pelo usuário"
        print("\n⏹️ Cópia interrompida")
    end
    
    isCopying = false
    copyButton.Text = "🔄 COPIAR TUDO (1s POR ID)"
    copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
end

-- ========== ATUALIZAR LISTA (TODOS OS PLAYERS) ==========
local function atualizarLista()
    -- Limpar menu
    for _, child in ipairs(dropdownMenu:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Pegar TODOS os players (incluindo você mesmo)
    local todosPlayers = game.Players:GetPlayers()
    
    -- Ordenar por nome
    table.sort(todosPlayers, function(a, b)
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    
    -- Criar botões para CADA jogador
    for _, plr in ipairs(todosPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        btn.Text = ""
        btn.Parent = dropdownMenu
        
        -- Nome com ícone
        local nomeLabel = Instance.new("TextLabel")
        nomeLabel.Size = UDim2.new(1, -10, 1, 0)
        nomeLabel.Position = UDim2.new(0, 5, 0, 0)
        nomeLabel.BackgroundTransparency = 1
        nomeLabel.Text = string.format("👤 %s (@%s)", plr.DisplayName, plr.Name)
        nomeLabel.TextColor3 = plr == player and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 255, 255)
        nomeLabel.TextSize = 13
        nomeLabel.Font = Enum.Font.Gotham
        nomeLabel.TextXAlignment = Enum.TextXAlignment.Left
        nomeLabel.Parent = btn
        
        -- Evento de clique
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = plr
            dropdownButton.Text = string.format("✓ %s ▼", plr.DisplayName)
            dropdownMenu.Visible = false
            
            -- Preview dos IDs
            local ids = extrairTodasPartes(plr)
            statusLabel.Text = string.format("📊 %d items encontrados", #ids)
            counterLabel.Text = string.format("0/%d itens", #ids)
        end)
    end
end

-- ========== EVENTOS ==========
dropdownButton.MouseButton1Click:Connect(function()
    dropdownMenu.Visible = not dropdownMenu.Visible
    if dropdownMenu.Visible then 
        atualizarLista()
    end
end)

userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownMenu.Visible then
        task.wait()
        if not dropdownButton:IsMouseOver() and not dropdownMenu:IsMouseOver() then
            dropdownMenu.Visible = false
        end
    end
end)

copyButton.MouseButton1Click:Connect(function()
    if isCopying then
        isCopying = false
        statusLabel.Text = "⏹️ Parando..."
    else
        copiarTudo(selectedPlayer)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Atualizar quando jogadores entrarem/saírem
game.Players.PlayerAdded:Connect(atualizarLista)
game.Players.PlayerRemoved:Connect(atualizarLista)

-- Inicializar
atualizarLista()
print("✅ Script carregado! TODOS os players aparecem no dropdown")
print("📌 Inclui: Acessórios, Roupas, Partes do Corpo, Animações")
