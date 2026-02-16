-- Criador de Avatar Copier com Interface Melhorada
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Criar ScreenGui com proteção
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarCopierGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Estilo moderno com gradiente
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
})

-- Frame principal com sombra
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 220)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Aplicar gradiente
gradient.Parent = mainFrame

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.Parent = mainFrame

-- Barra de título com efeito
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- Gradiente da barra
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 50))
})
titleGradient.Parent = titleBar

-- Ícone
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 25, 0, 25)
icon.Position = UDim2.new(0, 10, 0.5, -12.5)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://6031090990" -- Ícone de avatar
icon.ImageColor3 = Color3.fromRGB(100, 150, 255)
icon.Parent = titleBar

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.BackgroundTransparency = 1
title.Text = "COPY AVATAR"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Botão de fechar estilizado
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

-- Arredondar botão
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Container principal
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(1, -30, 1, -60)
container.Position = UDim2.new(0, 15, 0, 50)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Label de instrução
local instructionLabel = Instance.new("TextLabel")
instructionLabel.Name = "InstructionLabel"
instructionLabel.Size = UDim2.new(1, 0, 0, 25)
instructionLabel.BackgroundTransparency = 1
instructionLabel.Text = "Selecione um jogador para copiar:"
instructionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
instructionLabel.TextSize = 14
instructionLabel.Font = Enum.Font.Gotham
instructionLabel.TextXAlignment = Enum.TextXAlignment.Left
instructionLabel.Parent = container

-- Frame do dropdown
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Name = "DropdownFrame"
dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
dropdownFrame.Position = UDim2.new(0, 0, 0, 30)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Parent = container

-- Arredondar dropdown
local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 8)
dropdownCorner.Parent = dropdownFrame

-- Botão do dropdown
local dropdownButton = Instance.new("TextButton")
dropdownButton.Name = "DropdownButton"
dropdownButton.Size = UDim2.new(1, 0, 1, 0)
dropdownButton.BackgroundTransparency = 1
dropdownButton.Text = ""
dropdownButton.Parent = dropdownFrame

-- Texto do botão
local buttonText = Instance.new("TextLabel")
buttonText.Name = "ButtonText"
buttonText.Size = UDim2.new(1, -40, 1, 0)
buttonText.Position = UDim2.new(0, 15, 0, 0)
buttonText.BackgroundTransparency = 1
buttonText.Text = "Clique para selecionar"
buttonText.TextColor3 = Color3.fromRGB(220, 220, 240)
buttonText.TextSize = 16
buttonText.Font = Enum.Font.Gotham
buttonText.TextXAlignment = Enum.TextXAlignment.Left
buttonText.Parent = dropdownButton

-- Seta do dropdown
local arrow = Instance.new("TextLabel")
arrow.Name = "Arrow"
arrow.Size = UDim2.new(0, 30, 1, 0)
arrow.Position = UDim2.new(1, -30, 0, 0)
arrow.BackgroundTransparency = 1
arrow.Text = "▼"
arrow.TextColor3 = Color3.fromRGB(100, 150, 255)
arrow.TextSize = 20
arrow.Font = Enum.Font.GothamBold
arrow.Parent = dropdownButton

-- Menu dropdown (agora como frame separado)
local dropdownMenu = Instance.new("Frame")
dropdownMenu.Name = "DropdownMenu"
dropdownMenu.Size = UDim2.new(1, 0, 0, 200)
dropdownMenu.Position = UDim2.new(0, 0, 0, 45)
dropdownMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
dropdownMenu.BorderSizePixel = 0
dropdownMenu.Visible = false
dropdownMenu.ClipsDescendants = true
dropdownMenu.Parent = container

-- Arredondar menu
local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = dropdownMenu

-- Lista de jogadores (ScrollingFrame)
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -10, 1, -10)
playerList.Position = UDim2.new(0, 5, 0, 5)
playerList.BackgroundTransparency = 1
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerList.Parent = dropdownMenu

-- Layout da lista
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerList

-- Padding da lista
local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.Parent = playerList

-- Botão de copiar com efeito
local copyButton = Instance.new("TextButton")
copyButton.Name = "CopyButton"
copyButton.Size = UDim2.new(1, 0, 0, 50)
copyButton.Position = UDim2.new(0, 0, 1, -55)
copyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
copyButton.Text = ""
copyButton.BorderSizePixel = 0
copyButton.Parent = container

-- Arredondar botão de copiar
local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyButton

-- Texto do botão de copiar
local copyText = Instance.new("TextLabel")
copyText.Name = "CopyText"
copyText.Size = UDim2.new(1, 0, 1, 0)
copyText.BackgroundTransparency = 1
copyText.Text = "📋 COPIAR AVATAR"
copyText.TextColor3 = Color3.fromRGB(255, 255, 255)
copyText.TextSize = 18
copyText.Font = Enum.Font.GothamBold
copyText.Parent = copyButton

-- Efeito de brilho no botão
local copyGlow = Instance.new("ImageLabel")
copyGlow.Name = "Glow"
copyGlow.Size = UDim2.new(1, 20, 1, 20)
copyGlow.Position = UDim2.new(0, -10, 0, -10)
copyGlow.BackgroundTransparency = 1
copyGlow.Image = "rbxassetid://3570695787"
copyGlow.ImageColor3 = Color3.fromRGB(65, 105, 225)
copyGlow.ImageTransparency = 0.7
copyGlow.Parent = copyButton

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -75)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = container

-- Variáveis
local selectedPlayer = nil
local isMenuOpen = false

-- Função para animar o menu
local function toggleMenu()
    isMenuOpen = not isMenuOpen
    
    -- Animação da seta
    local rotation = isMenuOpen and 180 or 0
    tweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = rotation}):Play()
    
    -- Mostrar/esconder menu com animação
    dropdownMenu.Visible = true
    local targetSize = isMenuOpen and UDim2.new(1, 0, 0, 200) or UDim2.new(1, 0, 0, 0)
    tweenService:Create(dropdownMenu, TweenInfo.new(0.3), {Size = targetSize}):Play()
    
    if not isMenuOpen then
        task.wait(0.3)
        dropdownMenu.Visible = false
    else
        updatePlayerList()
    end
end

-- Função para atualizar lista de jogadores
function updatePlayerList()
    -- Limpar lista
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Obter todos os jogadores
    local players = game.Players:GetPlayers()
    
    -- Ordenar por nome
    table.sort(players, function(a, b)
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    
    -- Criar botões
    for _, plr in ipairs(players) do
        if plr ~= player then
            -- Frame do item
            local itemFrame = Instance.new("TextButton")
            itemFrame.Name = plr.Name
            itemFrame.Size = UDim2.new(1, 0, 0, 40)
            itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            itemFrame.AutoButtonColor = false
            itemFrame.Text = ""
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = playerList
            
            -- Arredondar item
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = itemFrame
            
            -- Ícone do jogador
            local playerIcon = Instance.new("ImageLabel")
            playerIcon.Size = UDim2.new(0, 30, 0, 30)
            playerIcon.Position = UDim2.new(0, 5, 0.5, -15)
            playerIcon.BackgroundTransparency = 1
            playerIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            playerIcon.ImageColor3 = Color3.fromRGB(plr.UserId % 255, (plr.UserId * 2) % 255, (plr.UserId * 3) % 255)
            
            -- Tentar carregar a thumbnail do jogador
            pcall(function()
                local thumbType = Enum.ThumbnailType.AvatarBust
                local thumbSize = Enum.ThumbnailSize.Size48x48
                local content, isReady = game.Players:GetUserThumbnailAsync(plr.UserId, thumbType, thumbSize)
                if isReady then
                    playerIcon.Image = content
                end
            end)
            
            playerIcon.Parent = itemFrame
            
            -- Nome do jogador
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -45, 1, 0)
            nameLabel.Position = UDim2.new(0, 40, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = string.format("%s (@%s)", plr.DisplayName, plr.Name)
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = itemFrame
            
            -- Efeito hover
            itemFrame.MouseEnter:Connect(function()
                tweenService:Create(itemFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
            end)
            
            itemFrame.MouseLeave:Connect(function()
                tweenService:Create(itemFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
            end)
            
            -- Selecionar jogador
            itemFrame.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                buttonText.Text = string.format("✓ %s (%s)", plr.DisplayName, plr.Name)
                buttonText.TextColor3 = Color3.fromRGB(100, 255, 150)
                toggleMenu()
                
                -- Resetar cor depois
                task.wait(0.5)
                buttonText.TextColor3 = Color3.fromRGB(220, 220, 240)
            end)
        end
    end
end

-- Eventos do dropdown
dropdownButton.MouseButton1Click:Connect(toggleMenu)

-- Fechar menu ao clicar fora
userInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isMenuOpen then
        local mousePos = userInputService:GetMouseLocation()
        local dropdownPos = dropdownMenu.AbsolutePosition
        local dropdownSize = dropdownMenu.AbsoluteSize
        
        -- Verificar se clicou fora do menu e do botão
        if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
           mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            
            if mousePos.X < buttonPos.X or mousePos.X > buttonPos.X + buttonSize.X or
               mousePos.Y < buttonPos.Y or mousePos.Y > buttonPos.Y + buttonSize.Y then
                toggleMenu()
            end
        end
    end
end)

-- Função para copiar avatar (lógica melhorada)
function copyAvatar(targetPlayer)
    if not targetPlayer then
        statusLabel.Text = "❌ Selecione um jogador primeiro!"
        return false
    end
    
    statusLabel.Text = "📦 Copiando avatar..."
    
    -- Tentar diferentes abordagens
    local remote = replicatedStorage:FindFirstChild("Remotes")
    if not remote then
        remote = replicatedStorage:FindFirstChild("Remote")
    end
    
    if not remote then
        -- Procurar em qualquer lugar
        for _, obj in ipairs(replicatedStorage:GetChildren()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                if obj.Name:lower():find("outfit") or obj.Name:lower():find("load") or obj.Name:lower():find("avatar") then
                    remote = obj
                    break
                end
            end
        end
    end
    
    if not remote then
        statusLabel.Text = "❌ Remote não encontrado!"
        return false
    end
    
    local loadOutfit = remote:FindFirstChild("LoadOutfit") or remote:FindFirstChild("loadOutfit") or remote
    
    -- Coletar dados do avatar
    local character = targetPlayer.Character
    local outfitData = {}
    
    if character then
        -- Coletar roupas
        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
                outfitData[child.ClassName] = child.ShirtTemplate or child.PantsTemplate or child.Graphic
            end
        end
    end
    
    -- Tentar diferentes formatos de args
    local attempts = {
        {targetPlayer},
        {targetPlayer.UserId},
        {targetPlayer.Character},
        {targetPlayer, outfitData},
        {targetPlayer.Name, outfitData},
        {targetPlayer.UserId, outfitData},
        {[1] = targetPlayer, [2] = outfitData},
        {["player"] = targetPlayer, ["outfit"] = outfitData}
    }
    
    for i, args in ipairs(attempts) do
        local success = pcall(function()
            if loadOutfit:IsA("RemoteFunction") then
                return loadOutfit:InvokeServer(unpack(args))
            elseif loadOutfit:IsA("RemoteEvent") then
                loadOutfit:FireServer(unpack(args))
                return true
            end
        end)
        
        if success then
            statusLabel.Text = string.format("✅ Avatar de %s copiado!", targetPlayer.DisplayName)
            
            -- Animação do botão
            tweenService:Create(copyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 205, 50)}):Play()
            copyText.Text = "✓ AVATAR COPIADO!"
            
            task.wait(1)
            
            tweenService:Create(copyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(65, 105, 225)}):Play()
            copyText.Text = "📋 COPIAR AVATAR"
            
            return true
        end
    end
    
    statusLabel.Text = "❌ Falha ao copiar avatar!"
    
    -- Animação de erro
    tweenService:Create(copyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    copyText.Text = "✗ ERRO"
    
    task.wait(1)
    
    tweenService:Create(copyButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(65, 105, 225)}):Play()
    copyText.Text = "📋 COPIAR AVATAR"
    
    return false
end

-- Conectar botão de cópia
copyButton.MouseButton1Click:Connect(function()
    copyAvatar(selectedPlayer)
end)

-- Atualizar lista quando jogadores entrarem/saírem
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoved:Connect(updatePlayerList)

-- Fechar
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Inicializar lista
task.wait(0.5)
updatePlayerList()
buttonText.Text = "Clique para selecionar"
statusLabel.Text = "✅ Interface carregada!"
task.wait(2)
statusLabel.Text = ""
