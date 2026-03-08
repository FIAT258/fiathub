-- Carrega a Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Cria a janela principal
local Window = Fluent:CreateWindow({
    Title = "XFIREX HUB (RIPERSHOT)",
    SubTitle = "by JX1 & DeepSeek",
    TabWidth = 160,
    Size = UDim2.fromOffset(460, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Adiciona as abas
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Extras = Window:AddTab({ Title = "Extras", Icon = "package" }),
    Creditos = Window:AddTab({ Title = "Créditos", Icon = "heart" })
}

-- Variáveis globais
local Options = Fluent.Options
_G.Aimbot = {
    Enabled = false,
    TeamRivalOnly = true,
    BodyPart = "Tronco",
    Target = nil
}
_G.ESP = {
    Enabled = false,
    TeamEnabled = true,
    Objects = {}
}
_G.Speed = {
    Enabled = false,
    Value = 16
}
_G.InfiniteJump = {
    Enabled = false,
    Connection = nil
}
_G.BodyParts = {
    Tronco = "HumanoidRootPart",
    Costas = "UpperTorso",
    Cabeça = "Head"
}

-- Notificação de boas-vindas
Fluent:Notify({
    Title = "Hub Carregado",
    Content = "Aimbot e ESP ativados!",
    Duration = 5
})

-- ==================== ABA AIMBOT ====================
-- Dropdown da parte do corpo
Tabs.Aimbot:AddDropdown("BodyPartDropdown", {
    Title = "Parte do Corpo",
    Values = { "Tronco", "Costas", "Cabeça" },
    Multi = false,
    Default = 1,
    Description = "Escolha onde mirar"
})
Options.BodyPartDropdown:OnChanged(function(Value)
    _G.Aimbot.BodyPart = Value
end)

-- Toggle para ativar/desativar o aimbot
Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "Aimbot Players",
    Description = "Atira no humanoide mais próximo",
    Default = false
})
Options.AimbotToggle:OnChanged(function(state)
    _G.Aimbot.Enabled = state
    if not state then _G.Aimbot.Target = nil end
end)

-- Toggle para mirar apenas em rivais
Tabs.Aimbot:AddToggle("TeamRivalToggle", {
    Title = "Mirar em Rivals apenas",
    Description = "Ignora aliados",
    Default = true
})
Options.TeamRivalToggle:OnChanged(function(state)
    _G.Aimbot.TeamRivalOnly = state
end)

-- Função para encontrar o humanoide mais próximo (jogadores OU NPCs)
local function getClosestHumanoid()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestDist = math.huge
    local closestTarget = nil

    -- Procura entre jogadores
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            if _G.Aimbot.TeamRivalOnly and player.Team and otherPlayer.Team == player.Team then
                -- pula aliado
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

    -- Procura entre NPCs (humanoides que não são jogadores)
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
            local npcHumanoid = npc:FindFirstChild("Humanoid")
            if npcHumanoid and npcHumanoid.Health > 0 then
                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
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

-- Loop do aimbot (trava a câmera)
game:GetService("RunService").RenderStepped:Connect(function()
    if not _G.Aimbot.Enabled then return end

    local target = getClosestHumanoid()
    if not target then
        _G.Aimbot.Target = nil
        return
    end

    _G.Aimbot.Target = target
    local targetChar = target:IsA("Player") and target.Character or target
    if not targetChar then return end

    -- Verifica se o alvo ainda está vivo
    local humanoid = targetChar:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        _G.Aimbot.Target = nil
        return
    end

    -- Obtém a parte do corpo selecionada
    local partName = _G.BodyParts[_G.Aimbot.BodyPart]
    local targetPart = targetChar:FindFirstChild(partName) or targetChar:FindFirstChild("HumanoidRootPart")
    if targetPart then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPart.Position)
    end
end)

-- ==================== ABA ESP ====================
-- Toggle ESP
Tabs.ESP:AddToggle("ESPToggle", {
    Title = "ESP",
    Description = "Mostra contorno e informações dos jogadores",
    Default = false
})
Options.ESPToggle:OnChanged(function(state)
    _G.ESP.Enabled = state
    if not state then
        for _, v in pairs(_G.ESP.Objects) do
            if v.Highlight then v.Highlight:Destroy() end
            if v.Billboard then v.Billboard:Destroy() end
        end
        _G.ESP.Objects = {}
    end
end)

-- Toggle ESP por time
Tabs.ESP:AddToggle("ESPTeamToggle", {
    Title = "ESP por Time",
    Description = "Aliados em azul, inimigos em branco",
    Default = true
})
Options.ESPTeamToggle:OnChanged(function(state)
    _G.ESP.TeamEnabled = state
end)

-- Função para criar/atualizar ESP em um personagem
local function updateESPForCharacter(char, owner)
    if not _G.ESP.Enabled then return end
    if not char then return end

    if not _G.ESP.Objects[owner] then _G.ESP.Objects[owner] = {} end
    local esp = _G.ESP.Objects[owner]

    -- Cria/atualiza Highlight
    if not esp.Highlight then
        esp.Highlight = Instance.new("Highlight")
        esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.Highlight.Parent = char
    end
    esp.Highlight.Adornee = char

    local localPlayer = game.Players.LocalPlayer
    if _G.ESP.TeamEnabled and localPlayer.Team then
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

    -- Cria/atualiza Billboard
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
        if _G.ESP.Enabled then updateESPForCharacter(char, player) end
    end)
    if player.Character and _G.ESP.Enabled then
        updateESPForCharacter(player.Character, player)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.ESP.Objects[player] then
        if _G.ESP.Objects[player].Highlight then _G.ESP.Objects[player].Highlight:Destroy() end
        if _G.ESP.Objects[player].Billboard then _G.ESP.Objects[player].Billboard:Destroy() end
        _G.ESP.Objects[player] = nil
    end
end)

-- ESP para NPCs (procura por novos humanoides)
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("Model") and desc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(desc) then
        local npc = desc
        repeat wait() until npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
        if _G.ESP.Enabled then
            updateESPForCharacter(npc, npc)
        end
    end
end)

-- Loop de atualização do ESP
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESP.Enabled then
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

-- ==================== ABA EXTRAS ====================
-- Slider de velocidade
Tabs.Extras:AddSlider("SpeedSlider", {
    Title = "Velocidade",
    Description = "Ajusta a velocidade do jogador",
    Default = 16,
    Min = 0,
    Max = 300,
    Rounding = 1
})
Options.SpeedSlider:OnChanged(function(value)
    _G.Speed.Value = value
    if _G.Speed.Enabled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = value end
        end
    end
end)

-- Toggle de velocidade
Tabs.Extras:AddToggle("SpeedToggle", {
    Title = "Speed Player",
    Description = "Ativa a velocidade ajustada",
    Default = false
})
Options.SpeedToggle:OnChanged(function(state)
    _G.Speed.Enabled = state
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = state and _G.Speed.Value or 16
        end
    end
end)

-- Toggle infinite jump
Tabs.Extras:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Description = "Pulos infinitos",
    Default = false
})
Options.InfiniteJumpToggle:OnChanged(function(state)
    _G.InfiniteJump.Enabled = state
    if state then
        _G.InfiniteJump.Connection = game:GetService("UserInputService").JumpRequest:Connect(function()
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if _G.InfiniteJump.Connection then
            _G.InfiniteJump.Connection:Disconnect()
            _G.InfiniteJump.Connection = nil
        end
    end
end)

-- Dropdown de players
Tabs.Extras:AddDropdown("PlayerDropdown", {
    Title = "Players",
    Values = {},
    Multi = false,
    Default = 1,
    Description = "Selecione um jogador para teleporte"
})
Options.PlayerDropdown:OnChanged(function(value)
    _G.SelectedPlayer = value
end)

-- Função para atualizar a lista de players
local function updatePlayerList()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    Options.PlayerDropdown:SetValues(names)
end
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Botão de teleporte
Tabs.Extras:AddButton({
    Title = "Teleportar para o Player",
    Description = "Vai até o jogador selecionado",
    Callback = function()
        if not _G.SelectedPlayer then
            Fluent:Notify({
                Title = "Erro",
                Content = "Nenhum jogador selecionado!",
                Duration = 3
            })
            return
        end
        local target = game.Players:FindFirstChild(_G.SelectedPlayer)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            Fluent:Notify({
                Title = "Erro",
                Content = "Jogador inválido!",
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

-- ==================== ABA CRÉDITOS ====================
Tabs.Creditos:AddParagraph({
    Title = "Créditos",
    Content = "Interface: deep seek\nDonos: JX1\nCara aleatório: Lorenzo gay"
})

-- ==================== TEMA LARANJA ====================
-- A Fluent permite temas customizados? Se não, ignoramos.
-- Se quiser, pode alterar o tema padrão da Fluent via:
-- Fluent:SetTheme("Dark") ou "Light"

-- ==================== ADD-ONS (SaveManager e InterfaceManager) ====================
-- Configuração dos add-ons (como no seu exemplo)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MeuHubAimbot")
SaveManager:SetFolder("MeuHubAimbot")

-- Cria a aba de configurações (se você quiser adicionar)
local TabsConfig = Window:AddTab({ Title = "Configurações", Icon = "settings" })
InterfaceManager:BuildInterfaceSection(TabsConfig)
SaveManager:BuildConfigSection(TabsConfig)

-- Carrega configuração automática
SaveManager:LoadAutoloadConfig()

-- Seleciona a primeira aba
Window:SelectTab(1)

Fluent:Notify({
    Title = "Pronto",
    Content = "Hub carregado com sucesso!",
    Duration = 5
})
