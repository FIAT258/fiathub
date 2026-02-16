-- Criação da interface principal
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local guiService = game:GetService("GuiService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopierGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Criar frame principal (arrastável)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 150)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Barra de título (para arrastar)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Avatar Copier"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Botão de fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 1, 0)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BackgroundTransparency = 0.2
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Container principal
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Dropdown Label
local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Name = "DropdownLabel"
dropdownLabel.Size = UDim2.new(1, 0, 0, 20)
dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.Text = "Selecione um jogador:"
dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
dropdownLabel.TextScaled = true
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.Parent = container

-- Criar dropdown
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(1, 0, 0, 35)
dropdownButton.Position = UDim2.new(0, 0, 0, 25)
dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
dropdownButton.Text = "▼ Clique para selecionar"
dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
dropdownButton.TextScaled = true
dropdownButton.Font = Enum.Font.Gotham
dropdownButton.BorderSizePixel = 0
dropdownButton.Parent = container

-- Frame do menu dropdown
local dropdownMenu = Instance.new("ScrollingFrame")
dropdownMenu.Name = "DropdownMenu"
dropdownMenu.Size = UDim2.new(1, 0, 0, 120)
dropdownMenu.Position = UDim2.new(0, 0, 0, 60)
dropdownMenu.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
dropdownMenu.BackgroundTransparency = 0.1
dropdownMenu.BorderSizePixel = 0
dropdownMenu.Visible = false
dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownMenu.ScrollBarThickness = 5
dropdownMenu.Parent = container

-- Layout para o menu
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = dropdownMenu

-- Botão de copiar
local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(1, 0, 0, 40)
copyButton.Position = UDim2.new(0, 0, 1, -45)
copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
copyButton.Text = "COPIAR AVATAR"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.TextScaled = true
copyButton.Font = Enum.Font.GothamBold
copyButton.BorderSizePixel = 0
copyButton.Parent = container

-- Função para atualizar lista de jogadores
local selectedPlayer = nil

local function updatePlayerList()
    -- Limpar menu
    for _, child in ipairs(dropdownMenu:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Obter lista de jogadores
    local players = game.Players:GetPlayers()
    local canvasHeight = #players * 25
    
    dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
    
    -- Criar botões para cada jogador
    for i, plr in ipairs(players) do
        if plr ~= player then -- Não mostrar o próprio jogador
            local playerButton = Instance.new("TextButton")
            playerButton.Name = plr.Name
            playerButton.Size = UDim2.new(1, -5, 0, 25)
            playerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            playerButton.BackgroundTransparency = 0.2
            playerButton.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextScaled = true
            playerButton.Font = Enum.Font.Gotham
            playerButton.BorderSizePixel = 0
            playerButton.Parent = dropdownMenu
            
            -- Efeito hover
            playerButton.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            end)
            
            playerButton.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            end)
            
            -- Selecionar jogador
            playerButton.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                dropdownButton.Text = "▼ " .. plr.DisplayName .. " (" .. plr.Name .. ")"
                dropdownMenu.Visible = false
            end)
        end
    end
end

-- Atualizar lista quando um jogador entrar/sair
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoved:Connect(updatePlayerList)

-- Mostrar/esconder menu dropdown
dropdownButton.MouseButton1Click:Connect(function()
    dropdownMenu.Visible = not dropdownMenu.Visible
    if dropdownMenu.Visible then
        updatePlayerList()
    end
end)

-- Fechar menu quando clicar fora
userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = userInputService:GetMouseLocation()
        local absolutePos = Vector2.new(pos.X, pos.Y)
        
        -- Verificar se clicou fora do menu
        if dropdownMenu.Visible then
            local menuPos = dropdownMenu.AbsolutePosition
            local menuSize = dropdownMenu.AbsoluteSize
            
            if absolutePos.X < menuPos.X or absolutePos.X > menuPos.X + menuSize.X or
               absolutePos.Y < menuPos.Y or absolutePos.Y > menuPos.Y + menuSize.Y then
                dropdownMenu.Visible = false
            end
        end
    end
end)

-- Função para copiar avatar
local function copyAvatar(targetPlayer)
    if not targetPlayer then
        warn("Nenhum jogador selecionado!")
        return
    end
    
    -- Verificar se o jogador ainda está no jogo
    if not targetPlayer.Parent then
        warn("Jogador não está mais no jogo!")
        dropdownButton.Text = "▼ Clique para selecionar"
        selectedPlayer = nil
        return
    end
    
    -- Criar args baseado na estrutura
    -- Estrutura típica: {[1] = player, [2] = outfitData, [3] = etc}
    -- Vamos tentar diferentes formatos comuns
    
    -- Tentativa 1: Formato direto
    local args1 = {
        [1] = targetPlayer
    }
    
    -- Tentativa 2: Formato com outfit
    local args2 = {
        [1] = targetPlayer.Character,
        [2] = targetPlayer.UserId
    }
    
    -- Tentativa 3: Formato com dados do avatar
    local success, result = pcall(function()
        -- Primeiro formato
        local response = replicatedStorage:WaitForChild("Remotes"):WaitForChild("LoadOutfit"):InvokeServer(unpack(args1))
        return response
    end)
    
    if not success then
        -- Tentar segundo formato
        success, result = pcall(function()
            return replicatedStorage:WaitForChild("Remotes"):WaitForChild("LoadOutfit"):InvokeServer(unpack(args2))
        end)
    end
    
    -- Feedback visual
    if success then
        copyButton.Text = "✓ AVATAR COPIADO!"
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
        wait(1)
        copyButton.Text = "COPIAR AVATAR"
        copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    else
        copyButton.Text = "✗ ERRO AO COPIAR"
        copyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        wait(1)
        copyButton.Text = "COPIAR AVATAR"
        copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    end
end

-- Conectar botão de cópia
copyButton.MouseButton1Click:Connect(function()
    copyAvatar(selectedPlayer)
end)

-- Efeito hover nos botões
copyButton.MouseEnter:Connect(function()
    copyButton.BackgroundColor3 = Color3.fromRGB(75, 115, 235)
end)

copyButton.MouseLeave:Connect(function()
    copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
end)

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
end)

closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)

-- Inicializar lista
wait(1)
updatePlayerList()

-- Notificação de carregamento
local notification = Instance.new("TextLabel")
notification.Name = "Notification"
notification.Size = UDim2.new(1, -20, 0, 30)
notification.Position = UDim2.new(0, 10, 0, 100)
notification.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
notification.BackgroundTransparency = 0.2
notification.Text = "Interface carregada! Selecione um jogador."
notification.TextColor3 = Color3.fromRGB(200, 200, 200)
notification.TextScaled = true
notification.Font = Enum.Font.Gotham
notification.BorderSizePixel = 0
notification.Parent = container

wait(3)
notification:Destroy()
