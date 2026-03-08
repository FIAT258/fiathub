--[[
    Hub Fluent Completo
    Funcionalidades: Aimbot (jogadores + NPCs), ESP, Speed, Infinite Jump, Teleporte, Créditos
    Estrutura baseada no exemplo fornecido.
]]

-- Carrega Fluent e add-ons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "Meu Hub Aimbot",
    SubTitle = "by JX1 & DeepSeek",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,      -- Pode ser detectado, desative se necessário
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Adiciona as abas principais
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Extras = Window:AddTab({ Title = "Extras", Icon = "package" }),
    Creditos = Window:AddTab({ Title = "Créditos", Icon = "heart" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" }) -- para SaveManager
}

-- Variáveis de estado (usando tabelas para facilitar)
local State = {
    Aimbot = {
        Enabled = false,
        TeamRivalOnly = true,
        BodyPart = "Tronco",  -- "Tronco", "Costas", "Cabeça"
        Target = nil,
        Smoothness = 0.2       -- suavização (0 = instantâneo, 1 = muito lento)
    },
    ESP = {
        Enabled = false,
        TeamEnabled = true,
        Objects = {}           -- armazena Highlights e Billboards
    },
    Speed = {
        Enabled = false,
        Value = 16
    },
    InfiniteJump = {
        Enabled = false,
        Connection = nil
    },
    SelectedPlayer = nil       -- para teleporte
}

-- Mapeamento das partes do corpo
local BodyParts = {
    Tronco = "HumanoidRootPart",
    Costas = "UpperTorso",
    Cabeça = "Head"
}

-- Notificação de boas-vindas
Fluent:Notify({
    Title = "Hub Carregado",
    Content = "Bem-vindo! Use as abas para configurar.",
    Duration = 5
})

-- ==================== AIMBOT ====================
-- Dropdown da parte do corpo
Tabs.Aimbot:AddDropdown("BodyPartDropdown", {
    Title = "Parte do Corpo",
    Description = "Selecione onde mirar",
    Values = { "Tronco", "Costas", "Cabeça" },
    Multi = false,
    Default = 1
})
Fluent.Options.BodyPartDropdown:OnChanged(function(Value)
    State.Aimbot.BodyPart = Value
end)

-- Toggle ativar aimbot
Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "Aimbot Players/NPCs",
    Description = "Mira automaticamente no humanoide mais próximo",
    Default = false
})
Fluent.Options.AimbotToggle:OnChanged(function(Value)
    State.Aimbot.Enabled = Value
    if not Value then State.Aimbot.Target = nil end
end)

-- Toggle mirar apenas em rivais
Tabs.Aimbot:AddToggle("TeamRivalToggle", {
    Title = "Apenas Rivais",
    Description = "Ignora aliados (funciona apenas com jogadores)",
    Default = true
})
Fluent.Options.TeamRivalToggle:OnChanged(function(Value)
    State.Aimbot.TeamRivalOnly = Value
end)

-- Slider de suavização da mira (opcional, para melhor controle)
Tabs.Aimbot:AddSlider("SmoothnessSlider", {
    Title = "Suavização da Mira",
    Description = "0 = instantâneo, 1 = muito lento",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Rounding = 2
})
Fluent.Options.SmoothnessSlider:OnChanged(function(Value)
    State.Aimbot.Smoothness = Value
end)

-- Função para encontrar o humanoide mais próximo (jogadores e NPCs)
local function getClosestHumanoid()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestDist = math.huge
    local closestTarget = nil

    -- Verifica jogadores
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            -- Verifica condição de time
            if State.Aimbot.TeamRivalOnly and player.Team and otherPlayer.Team == player.Team then
                -- Pula aliado
            else
                local otherChar = otherPlayer.Character
                if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar.Humanoid.Health > 0 then
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        local dist = (root.Position - otherRoot.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = otherPlayer
                        end
                    end
                end
            end
        end
    end

    -- Verifica NPCs (qualquer modelo com Humanoid que não seja jogador)
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
            local hum = npc:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if npcRoot then
                    local dist = (root.Position - npcRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = npc
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Loop principal do aimbot (usando RenderStepped para suavidade)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if not State.Aimbot.Enabled then return end

    local target = getClosestHumanoid()
    if not target then
        State.Aimbot.Target = nil
        return
    end

    State.Aimbot.Target = target
    local targetChar = target:IsA("Player") and target.Character or target
    if not targetChar then return end

    -- Verifica se o alvo ainda está vivo
    local humanoid = targetChar:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        State.Aimbot.Target = nil
        return
    end

    -- Obtém a parte do corpo alvo
    local partName = BodyParts[State.Aimbot.BodyPart]
    local targetPart = targetChar:FindFirstChild(partName) or targetChar:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end

    -- Movimento suave da câmera
    local camera = workspace.CurrentCamera
    local currentCF = camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPart.Position)
    local smooth = State.Aimbot.Smoothness
    if smooth > 0 then
        -- Interpolação linear (CFrame lerp)
        camera.CFrame = currentCF:Lerp(targetCF, 1 - smooth)
    else
        camera.CFrame = targetCF
    end
end)

-- ==================== ESP ====================
-- Toggle ESP
Tabs.ESP:AddToggle("ESPToggle", {
    Title = "ESP",
    Description = "Mostra contorno e informações dos jogadores/NPCs",
    Default = false
})
Fluent.Options.ESPToggle:OnChanged(function(Value)
    State.ESP.Enabled = Value
    if not Value then
        -- Remove todos os objetos ESP
        for _, v in pairs(State.ESP.Objects) do
            if v.Highlight then v.Highlight:Destroy() end
            if v.Billboard then v.Billboard:Destroy() end
        end
        State.ESP.Objects = {}
    end
end)

-- Toggle ESP por time
Tabs.ESP:AddToggle("ESPTeamToggle", {
    Title = "ESP por Time",
    Description = "Aliados em azul, inimigos em branco",
    Default = true
})
Fluent.Options.ESPTeamToggle:OnChanged(function(Value)
    State.ESP.TeamEnabled = Value
end)

-- Função para criar/atualizar ESP em um personagem
local function updateESPForCharacter(char, owner)
    if not State.ESP.Enabled then return end
    if not char then return end

    if not State.ESP.Objects[owner] then State.ESP.Objects[owner] = {} end
    local esp = State.ESP.Objects[owner]

    -- Cria/atualiza Highlight
    if not esp.Highlight then
        esp.Highlight = Instance.new("Highlight")
        esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.Highlight.Parent = char
    end
    esp.Highlight.Adornee = char

    local localPlayer = game.Players.LocalPlayer
    if State.ESP.TeamEnabled and localPlayer.Team then
        if owner:IsA("Player") and owner.Team == localPlayer.Team then
            esp.Highlight.FillColor = Color3.fromRGB(0, 100, 255) -- azul aliado
            esp.Highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        else
            esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255) -- branco inimigo/NPC
            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    else
        esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
        esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end

    -- Cria/atualiza Billboard (nome e distância)
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end

    if not esp.Billboard then
        esp.Billboard = Instance.new("BillboardGui")
        esp.Billboard.Size = UDim2.new(0, 200, 0, 50)
        esp.Billboard.StudsOffset = Vector3.new(0, 3, 0)
        esp.Billboard.AlwaysOnTop = true
        esp.Billboard.Parent = char

        local frame = Instance.new("Frame", esp.Billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1

        local nameLabel = Instance.new("TextLabel", frame)
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = (owner:IsA("Player") and owner.Name) or "NPC"
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextStrokeTransparency = 0.5
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 16

        local distLabel = Instance.new("TextLabel", frame)
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "Dist: ?"
        distLabel.TextColor3 = Color3.new(1,1,1)
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Font = Enum.Font.SourceSans
        distLabel.TextSize = 14

        esp.NameLabel = nameLabel
        esp.DistLabel = distLabel
    end
    esp.Billboard.Adornee = head

    -- Atualiza distância
    local localChar = localPlayer.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
        local dist = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
        esp.DistLabel.Text = string.format("Dist: %.1f", dist)
    end
end

-- Conecta eventos para ESP em jogadores
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        if State.ESP.Enabled then
            updateESPForCharacter(char, player)
        end
    end)
    if player.Character and State.ESP.Enabled then
        updateESPForCharacter(player.Character, player)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if State.ESP.Objects[player] then
        if State.ESP.Objects[player].Highlight then State.ESP.Objects[player].Highlight:Destroy() end
        if State.ESP.Objects[player].Billboard then State.ESP.Objects[player].Billboard:Destroy() end
        State.ESP.Objects[player] = nil
    end
end)

-- ESP para NPCs (novos descendentes com Humanoid)
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Model") and desc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(desc) then
        local npc = desc
        repeat wait() until npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
        if State.ESP.Enabled then
            updateESPForCharacter(npc, npc)
        end
    end
end)

-- Loop de atualização contínua do ESP
RunService.RenderStepped:Connect(function()
    if State.ESP.Enabled then
        -- Jogadores
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                updateESPForCharacter(player.Character, player)
            end
        end
        -- NPCs
        for _, npc in ipairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
                updateESPForCharacter(npc, npc)
            end
        end
    end
end)

-- ==================== EXTRAS ====================
-- Slider de velocidade
Tabs.Extras:AddSlider("SpeedSlider", {
    Title = "Velocidade",
    Description = "Ajusta a velocidade de caminhada",
    Default = 16,
    Min = 0,
    Max = 300,
    Rounding = 1
})
Fluent.Options.SpeedSlider:OnChanged(function(Value)
    State.Speed.Value = Value
    if State.Speed.Enabled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
end)

-- Toggle de velocidade
Tabs.Extras:AddToggle("SpeedToggle", {
    Title = "Speed Player",
    Description = "Ativa a velocidade ajustada",
    Default = false
})
Fluent.Options.SpeedToggle:OnChanged(function(Value)
    State.Speed.Enabled = Value
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value and State.Speed.Value or 16
        end
    end
end)

-- Toggle infinite jump
Tabs.Extras:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Description = "Pulos infinitos",
    Default = false
})
Fluent.Options.InfiniteJumpToggle:OnChanged(function(Value)
    State.InfiniteJump.Enabled = Value
    if Value then
        State.InfiniteJump.Connection = game:GetService("UserInputService").JumpRequest:Connect(function()
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if State.InfiniteJump.Connection then
            State.InfiniteJump.Connection:Disconnect()
            State.InfiniteJump.Connection = nil
        end
    end
end)

-- Dropdown de players (sempre atualizado)
local playerNames = {}
Tabs.Extras:AddDropdown("PlayerDropdown", {
    Title = "Players",
    Description = "Selecione um jogador para teleporte",
    Values = playerNames,
    Multi = false,
    Default = 1
})
Fluent.Options.PlayerDropdown:OnChanged(function(Value)
    State.SelectedPlayer = Value
end)

-- Função para atualizar a lista de players
local function updatePlayerList()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    Fluent.Options.PlayerDropdown:SetValues(names)
end
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Botão de teleporte
Tabs.Extras:AddButton({
    Title = "Teleportar para o Player",
    Description = "Teletransporta você até o jogador selecionado",
    Callback = function()
        if not State.SelectedPlayer then
            Fluent:Notify({
                Title = "Erro",
                Content = "Nenhum jogador selecionado!",
                Duration = 3
            })
            return
        end
        local target = game.Players:FindFirstChild(State.SelectedPlayer)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({
                Title = "Erro",
                Content = "Jogador inválido ou sem personagem!",
                Duration = 3
            })
            return
        end
        local localChar = game.Players.LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            localChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            Fluent:Notify({
                Title = "Teleportado",
                Content = "Você foi teleportado para " .. target.Name,
                Duration = 3
            })
        end
    end
})

-- ==================== CRÉDITOS ====================
Tabs.Creditos:AddParagraph({
    Title = "Créditos",
    Content = "Interface: deep seek\nDonos: JX1\nCara aleatório: Lorenzo gay"
})

-- ==================== CONFIGURAÇÕES (SaveManager) ====================
-- Inicializa os add-ons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignora configurações de tema no save (não queremos salvar o tema)
SaveManager:IgnoreThemeSettings()

-- Pastas para salvar configurações
InterfaceManager:SetFolder("MeuHubAimbot")
SaveManager:SetFolder("MeuHubAimbot")

-- Constrói a seção de interface (permite trocar tema, etc.)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

-- Constrói a seção de configurações (salvar/carregar)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Carrega configuração automática se existir
SaveManager:LoadAutoloadConfig()

-- Seleciona a primeira aba
Window:SelectTab(1)

-- Notificação final
Fluent:Notify({
    Title = "Hub Pronto",
    Content = "Todas as funcionalidades carregadas!",
    Duration = 5
})
