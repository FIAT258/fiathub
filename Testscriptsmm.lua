-- Interface arrastável com sistema de props
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local dragBar = Instance.new("Frame")
local title = Instance.new("TextLabel")
local playerDropdown = Instance.new("TextButton") -- Vai abrir a lista
local killButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")
local stopButton = Instance.new("TextButton")
local playerListFrame = Instance.new("Frame")
local selectedPlayer = nil
local monitoring = false
local playerDied = false

-- Configurar GUI
gui.Name = "PropControlGUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Frame principal
frame.Name = "MainFrame"
frame.Parent = gui
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Active = true
frame.Draggable = true
frame.Selectable = true

-- Barra de arrasto
dragBar.Name = "DragBar"
dragBar.Parent = frame
dragBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dragBar.BorderSizePixel = 0
dragBar.Size = UDim2.new(1, 0, 0, 30)
dragBar.Active = true

-- Título
title.Name = "Title"
title.Parent = dragBar
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "🎮 Prop Control"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14

-- Dropdown personalizado
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Parent = frame
playerDropdown.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
playerDropdown.Position = UDim2.new(0, 10, 0, 40)
playerDropdown.Size = UDim2.new(0, 230, 0, 30)
playerDropdown.Font = Enum.Font.Gotham
playerDropdown.Text = "📋 Selecionar Player"
playerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
playerDropdown.TextSize = 14

-- Frame da lista de players
playerListFrame.Name = "PlayerList"
playerListFrame.Parent = frame
playerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
playerListFrame.BorderSizePixel = 0
playerListFrame.Position = UDim2.new(0, 10, 0, 71)
playerListFrame.Size = UDim2.new(0, 230, 0, 120)
playerListFrame.Visible = false
playerListFrame.ZIndex = 10

-- Botão Kill
killButton.Name = "KillButton"
killButton.Parent = frame
killButton.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
killButton.Position = UDim2.new(0, 10, 0, 200)
killButton.Size = UDim2.new(0, 230, 0, 35)
killButton.Font = Enum.Font.GothamBold
killButton.Text = "💀 KILL PLAYER"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextSize = 14

-- Status
statusLabel.Name = "StatusLabel"
statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 10, 0, 245)
statusLabel.Size = UDim2.new(0, 230, 0, 20)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Status: Aguardando..."
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 12

-- Botão Stop
stopButton.Name = "StopButton"
stopButton.Parent = frame
stopButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
stopButton.Position = UDim2.new(0, 10, 0, 275)
stopButton.Size = UDim2.new(0, 230, 0, 35)
stopButton.Font = Enum.Font.GothamBold
stopButton.Text = "⏹️ PARAR MONITORAMENTO"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.TextSize = 12
stopButton.Visible = false

-- Charme extra
local charmLabel = Instance.new("TextLabel")
charmLabel.Parent = frame
charmLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
charmLabel.BackgroundTransparency = 1
charmLabel.Position = UDim2.new(0, 10, 0, 315)
charmLabel.Size = UDim2.new(0, 230, 0, 25)
charmLabel.Font = Enum.Font.Gotham
charmLabel.Text = "✨ Pequeno charme especial ✨"
charmLabel.TextColor3 = Color3.fromRGB(180, 130, 255)
charmLabel.TextSize = 11

-- Função para atualizar lista de players
local function updatePlayerList()
    -- Limpar lista anterior
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Adicionar players atuais
    local yPos = 0
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = "Player_" .. plr.Name
            playerButton.Parent = playerListFrame
            playerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            playerButton.BorderSizePixel = 0
            playerButton.Position = UDim2.new(0, 0, 0, yPos)
            playerButton.Size = UDim2.new(1, 0, 0, 25)
            playerButton.Font = Enum.Font.Gotham
            playerButton.Text = plr.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextSize = 12
            playerButton.ZIndex = 11
            
            playerButton.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                playerDropdown.Text = "👤 " .. plr.Name
                playerListFrame.Visible = false
                statusLabel.Text = "Player selecionado: " .. plr.Name
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end)
            
            yPos = yPos + 25
        end
    end
    
    -- Ajustar altura do frame
    playerListFrame.Size = UDim2.new(0, 230, 0, yPos)
end

-- Toggle da lista de players
playerDropdown.MouseButton1Click:Connect(function()
    playerListFrame.Visible = not playerListFrame.Visible
    if playerListFrame.Visible then
        updatePlayerList()
    end
end)

-- Fechar lista quando clicar fora
mouse.Button1Down:Connect(function()
    wait()
    if playerListFrame.Visible then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local absPos = playerListFrame.AbsolutePosition
        local absSize = playerListFrame.AbsoluteSize
        
        if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
           mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
            playerListFrame.Visible = false
        end
    end
end)

-- Funções principais
local function executeFirstSequence()
    if not selectedPlayer then
        statusLabel.Text = "❌ Selecione um player primeiro!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    monitoring = true
    killButton.Visible = false
    stopButton.Visible = true
    playerDied = false
    
    statusLabel.Text = "🎯 Iniciando sequência..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    -- Primeiro código
    local args1 = {
        "PickingTools",
        "PropMaker"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args1))
    
    wait(3) -- Aguardar 3 segundos
    
    -- Segundo código
    local args2 = {
        "filterClick",
        {
            name = "FurnitureBleachers",
            itemType = "Props",
            filter = "Home"
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TelemetryClientInteraction"):FireServer(unpack(args2))
    
    statusLabel.Text = "🔧 Monitorando " .. selectedPlayer.Name .. "..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    
    -- Iniciar monitoramento
    monitorPlayer()
end

local function monitorPlayer()
    spawn(function()
        while monitoring and not playerDied do
            -- Verificar se player ainda existe
            if not selectedPlayer or not selectedPlayer.Parent then
                statusLabel.Text = "❌ Player desconectou"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                break
            end
            
            -- Verificar animação ou movimento (simulado)
            local character = selectedPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Se player está sentado ou fazendo animação
                    if humanoid.Sit or humanoid.MoveDirection.Magnitude > 0 then
                        -- Executar código rápido de movimento
                        local args3 = {
                            CFrame.new(-653.845947265625, -101.18560791015625, -37.66075897216797)
                        }
                        workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones"):WaitForChild("Propookjhndvj"):WaitForChild("SetCurrentCFrame"):InvokeServer(unpack(args3))
                        
                        statusLabel.Text = "⚡ Movimento detectado!"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
                    end
                end
                
                -- Verificar se morreu
                if not character or not character:FindFirstChildOfClass("Humanoid") or 
                   character.Humanoid.Health <= 0 then
                    playerDied = true
                    
                    -- Executar código de limpeza
                    local args4 = {
                        "ClearAllProps"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack(args4))
                    
                    statusLabel.Text = "💀 Player morreu! Limpando props..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    
                    -- Aguardar 1 minuto
                    for i = 1, 60 do
                        if not monitoring then break end
                        statusLabel.Text = "⏱️ Aguardando: " .. (60 - i) .. "s"
                        wait(1)
                    end
                    
                    if monitoring then
                        playerDied = false -- Reset para continuar
                        statusLabel.Text = "🔄 Reiniciando monitoramento..."
                        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                    end
                end
            end
            
            wait(2) -- Verificar a cada 2 segundos
        end
        
        -- Limpar ao sair
        if not monitoring then
            statusLabel.Text = "⏸️ Monitoramento parado"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            killButton.Visible = true
            stopButton.Visible = false
        end
    end)
end

-- Eventos dos botões
killButton.MouseButton1Click:Connect(executeFirstSequence)

stopButton.MouseButton1Click:Connect(function()
    monitoring = false
    playerDied = false
    statusLabel.Text = "⏹️ Parando monitoramento..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
    wait(1)
    killButton.Visible = true
    stopButton.Visible = false
end)

-- Fechar lista quando clicar fora
mouse.Button1Down:Connect(function()
    if playerListFrame.Visible then
        wait()
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        local absPos = playerListFrame.AbsolutePosition
        local absSize = playerListFrame.AbsoluteSize
        
        if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
           mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
            playerListFrame.Visible = false
        end
    end
end)

print("✅ Interface carregada! Arraste a barra superior para mover.")
