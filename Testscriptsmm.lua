-- AVATAR COPIER SEQUENCIAL - VERSÃO COMPACTA
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")

-- Interface principal
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.Active = true
mainFrame.Draggable = true  -- ARRASTÁVEL
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
title.Text = "🎭 COPIAR AVATAR"
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

-- Dropdown
local dropdownButton = Instance.new("TextButton")
dropdownButton.Size = UDim2.new(1, 0, 0, 40)
dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
dropdownButton.Text = "📋 Selecionar Jogador ▼"
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
copyButton.Text = "🔄 COPIAR (1s POR ID)"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = container

-- Variáveis
local selectedPlayer = nil
local isCopying = false
local itemIds = {}

-- ========== FUNÇÕES ==========

-- Extrair IDs do avatar
local function extrairIds(jogador)
    local ids = {}
    local char = jogador.Character
    if not char then return ids end
    
    -- Acessórios
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") and obj:FindFirstChild("Handle") then
            local mesh = obj.Handle:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.MeshId ~= "" then
                local id = mesh.MeshId:match("%d+")
                if id then table.insert(ids, tonumber(id)) end
            end
        end
    end
    
    -- Roupas
    local shirt = char:FindFirstChildOfClass("Shirt")
    if shirt and shirt.ShirtTemplate ~= "" then
        local id = shirt.ShirtTemplate:match("%d+")
        if id then table.insert(ids, tonumber(id)) end
    end
    
    local pants = char:FindFirstChildOfClass("Pants")
    if pants and pants.PantsTemplate ~= "" then
        local id = pants.PantsTemplate:match("%d+")
        if id then table.insert(ids, tonumber(id)) end
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
    
    return unicos
end

-- Aplicar ID (PARTE IMPORTANTE)
local function aplicarId(id)
    local args = {id}  -- <<< ID ATUAL
    local success = pcall(function()
        replicatedStorage:WaitForChild("Remotes"):WaitForChild("Wear"):InvokeServer(unpack(args))
    end)
    return success
end

-- Copiar sequencial
local function copiarSequencial(jogador)
    if not jogador then statusLabel.Text = "❌ Selecione um jogador!" return end
    if isCopying then statusLabel.Text = "⏳ Já está copiando..." return end
    
    statusLabel.Text = "🔍 Extraindo IDs..."
    itemIds = extrairIds(jogador)
    
    if #itemIds == 0 then
        statusLabel.Text = "❌ Nenhum item encontrado!"
        return
    end
    
    isCopying = true
    copyButton.Text = "⏸️ PARAR"
    copyButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    counterLabel.Text = string.format("0/%d itens", #itemIds)
    
    local sucessos = 0
    for i, id in ipairs(itemIds) do
        if not isCopying then break end
        
        progressFill.Size = UDim2.new((i-1)/#itemIds, 0, 1, 0)
        counterLabel.Text = string.format("%d/%d itens", i-1, #itemIds)
        statusLabel.Text = string.format("📦 ID: %d", id)
        
        if aplicarId(id) then
            sucessos = sucessos + 1
        end
        
        if i < #itemIds and isCopying then
            wait(1)  -- 1 SEGUNDO ENTRE IDs
        end
    end
    
    if isCopying then
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        counterLabel.Text = string.format("%d/%d itens", #itemIds, #itemIds)
        statusLabel.Text = string.format("✅ Concluído! %d/%d", sucessos, #itemIds)
    end
    
    isCopying = false
    copyButton.Text = "🔄 COPIAR (1s POR ID)"
    copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
end

-- Atualizar lista de jogadores
local function atualizarLista()
    for _, child in ipairs(dropdownMenu:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Parent = dropdownMenu
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                dropdownButton.Text = "✓ " .. plr.DisplayName .. " ▼"
                dropdownMenu.Visible = false
                
                local ids = extrairIds(plr)
                statusLabel.Text = string.format("📊 %d itens encontrados", #ids)
                counterLabel.Text = string.format("0/%d itens", #ids)
            end)
        end
    end
end

-- Eventos
dropdownButton.MouseButton1Click:Connect(function()
    dropdownMenu.Visible = not dropdownMenu.Visible
    if dropdownMenu.Visible then atualizarLista() end
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
        copiarSequencial(selectedPlayer)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Inicializar
atualizarLista()
print("✅ Script carregado! Interface arrastável.")
