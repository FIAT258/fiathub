--// LOAD WIND UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// CREATE WINDOW (NÃO REMOVIDO NADA)
local Window = WindUI:CreateWindow({
    Title = "My Super Hub",
    Icon = "door-open",
    Author = "by .ftgs and .ftgs",
    Folder = "MySuperHub",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("User clicked")
        end,
    },

    KeySystem = {
        Key = { "1234", "5678" },
        Note = "Example Key System.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "Thumbnail",
        },
        URL = "YOUR LINK TO GET KEY",
        SaveKey = false,
    },
})

--// TAG AO LADO DO TÍTULO
Window:Tag({
    Title = "v1",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 6,
})

--// NOTIFICAÇÃO AO ABRIR
WindUI:Notify({
    Title = "WindUI carregado",
    Content = "Interface iniciada com sucesso!",
    Duration = 4,
    Icon = "check",
})

-- Variáveis globais para controle
_G.AimbotEnabled = false
_G.AimbotTargetPlayers = true  -- se deve mirar em players
_G.AimbotTargetNPCs = false     -- se deve mirar em NPCs
_G.SelectedBodyPart = "Tronco"
_G.CurrentTarget = nil
_G.BodyParts = {
    Tronco = "HumanoidRootPart",
    Costas = "UpperTorso",
    Cabeça = "Head"
}

-- Função para obter o alvo mais próximo (players e/ou NPCs)
local function getClosestTarget()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestDist = math.huge
    local closestTarget = nil

    -- Players
    if _G.AimbotTargetPlayers then
        for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherChar = otherPlayer.Character
                if otherChar and otherChar:FindFirstChild("Humanoid") and otherChar.Humanoid.Health > 0 then
                    local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        local dist = (root.Position - otherRoot.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = otherChar
                        end
                    end
                end
            end
        end
    end

    -- NPCs (humanoids que não são players)
    if _G.AimbotTargetNPCs then
        for _, npc in ipairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
                local humanoid = npc:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
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
    end

    return closestTarget
end

-- Loop do aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    if not _G.AimbotEnabled then return end

    local target = getClosestTarget()
    if not target then
        _G.CurrentTarget = nil
        return
    end

    -- Verifica se o alvo ainda está vivo
    local humanoid = target:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        _G.CurrentTarget = nil
        return
    end

    local partName = _G.BodyParts[_G.SelectedBodyPart]
    local targetPart = target:FindFirstChild(partName) or target:FindFirstChild("HumanoidRootPart")
    if targetPart then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPart.Position)
    end
end)

--------------------------------------------------
--// TAB AIM BOT
--------------------------------------------------
local AimTab = Window:Tab({
    Title = "Aim Bot",
    Icon = "crosshair",
})

-- Dropdown parte do corpo
AimTab:Dropdown({
    Title = "Parte do Corpo",
    Desc = "Selecione onde mirar",
    Values = { "Tronco", "Costas", "Cabeça" },
    Value = { "Tronco" },
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        _G.SelectedBodyPart = option[1]
    end
})

-- Toggle aim bot players
AimTab:Toggle({
    Title = "Aim Bot Players",
    Desc = "Mira em jogadores",
    Icon = "users",
    Value = true,
    Callback = function(state)
        _G.AimbotTargetPlayers = state
    end
})

-- Toggle aim bot NPCs
AimTab:Toggle({
    Title = "Aim Bot NPCs",
    Desc = "Mira em NPCs (humanoids não jogadores)",
    Icon = "bot",
    Value = false,
    Callback = function(state)
        _G.AimbotTargetNPCs = state
    end
})

-- Toggle para ativar/desativar o aimbot
AimTab:Toggle({
    Title = "Ativar Aim Bot",
    Desc = "Liga/desliga a mira automática",
    Icon = "target",
    Value = false,
    Callback = function(state)
        _G.AimbotEnabled = state
        if not state then _G.CurrentTarget = nil end
    end
})

--------------------------------------------------
--// TAB ESP
--------------------------------------------------
local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "eye",
})

_G.ESPEnabled = false
_G.ESPTeamEnabled = true
_G.ESPObjects = {}

-- Função para criar/atualizar ESP em um personagem
local function updateESPForCharacter(char, isPlayer, team)
    if not _G.ESPEnabled then return end
    if not char then return end

    local key = char
    if not _G.ESPObjects[key] then _G.ESPObjects[key] = {} end
    local esp = _G.ESPObjects[key]

    -- Cria Highlight
    if not esp.Highlight then
        esp.Highlight = Instance.new("Highlight")
        esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.Highlight.Parent = char
    end
    esp.Highlight.Adornee = char

    -- Define cor baseado no time (se for player)
    if isPlayer and _G.ESPTeamEnabled then
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Team and team == localPlayer.Team then
            esp.Highlight.FillColor = Color3.fromRGB(0, 100, 255) -- azul aliado
            esp.Highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        else
            esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255) -- branco inimigo
            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    else
        esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
        esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end

    -- Cria Billboard para nome e distância (apenas para players)
    if isPlayer then
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if head then
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
                nameLabel.Text = char:GetFullName() or "NPC"
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
            local localChar = game.Players.LocalPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                local dist = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                esp.DistLabel.Text = string.format("Dist: %.1f", dist)
            end
        end
    end
end

-- Toggle ESP
EspTab:Toggle({
    Title = "Ativar ESP",
    Desc = "Mostra contorno e informações dos jogadores",
    Icon = "scan-eye",
    Value = false,
    Callback = function(state)
        _G.ESPEnabled = state
        if not state then
            for _, v in pairs(_G.ESPObjects) do
                if v.Highlight then v.Highlight:Destroy() end
                if v.Billboard then v.Billboard:Destroy() end
            end
            _G.ESPObjects = {}
        end
    end
})

-- Toggle ESP por time
EspTab:Toggle({
    Title = "ESP por Time",
    Desc = "Aliados em azul, inimigos em branco",
    Icon = "users",
    Value = true,
    Callback = function(state)
        _G.ESPTeamEnabled = state
    end
})

-- Atualização contínua do ESP
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPEnabled then
        -- Players
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                updateESPForCharacter(player.Character, true, player.Team)
            end
        end
        -- NPCs (opcional, se quiser também)
        -- for _, npc in ipairs(workspace:GetDescendants()) do
        --     if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
        --         updateESPForCharacter(npc, false)
        --     end
        -- end
    end
end)

-- Limpeza ao remover jogador
game.Players.PlayerRemoving:Connect(function(player)
    if player.Character and _G.ESPObjects[player.Character] then
        if _G.ESPObjects[player.Character].Highlight then _G.ESPObjects[player.Character].Highlight:Destroy() end
        if _G.ESPObjects[player.Character].Billboard then _G.ESPObjects[player.Character].Billboard:Destroy() end
        _G.ESPObjects[player.Character] = nil
    end
end)

--------------------------------------------------
--// TAB EXTRAS
--------------------------------------------------
local ExtrasTab = Window:Tab({
    Title = "Extras",
    Icon = "package",
})

_G.SpeedEnabled = false
_G.SpeedValue = 16

-- Slider velocidade
ExtrasTab:Slider({
    Title = "Velocidade",
    Desc = "Ajusta a velocidade do jogador (0-300)",
    Step = 1,
    Value = { Min = 0, Max = 300, Default = 16 },
    Callback = function(value)
        _G.SpeedValue = value
        if _G.SpeedEnabled then
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid.WalkSpeed = value end
            end
        end
    end
})

-- Toggle speed
ExtrasTab:Toggle({
    Title = "Speed Player",
    Desc = "Ativa a velocidade ajustada",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        _G.SpeedEnabled = state
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = state and _G.SpeedValue or 16
            end
        end
    end
})

-- Infinite jump
_G.InfiniteJumpEnabled = false
ExtrasTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Permite pular infinitamente",
    Icon = "arrow-up",
    Value = false,
    Callback = function(state)
        _G.InfiniteJumpEnabled = state
        if state then
            _G.JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        else
            if _G.JumpConnection then _G.JumpConnection:Disconnect() end
        end
    end
})

-- Dropdown de players
local playerDropdown = ExtrasTab:Dropdown({
    Title = "Players",
    Desc = "Selecione um jogador para teleporte",
    Values = {},
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        _G.SelectedPlayerForTP = option[1]
    end
})

local function updatePlayerList()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    playerDropdown:SetValues(names)
end

game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- Botão teleporte
ExtrasTab:Button({
    Title = "Teleportar para o Player",
    Desc = "Teletransporta você até o jogador selecionado",
    Callback = function()
        if not _G.SelectedPlayerForTP then
            WindUI:Notify({ Title = "Erro", Content = "Nenhum jogador selecionado!", Duration = 3, Icon = "alert-circle" })
            return
        end
        local target = game.Players:FindFirstChild(_G.SelectedPlayerForTP)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            WindUI:Notify({ Title = "Erro", Content = "Jogador inválido!", Duration = 3, Icon = "alert-circle" })
            return
        end
        local localChar = game.Players.LocalPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            localChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            WindUI:Notify({ Title = "Teleportado", Content = "Você foi teleportado para " .. target.Name, Duration = 3, Icon = "check-circle" })
        end
    end
})

--------------------------------------------------
--// TAB CRÉDITOS
--------------------------------------------------
local CreditosTab = Window:Tab({
    Title = "Créditos",
    Icon = "heart",
})

CreditosTab:Paragraph({
    Title = "Créditos",
    Desc = "Interface: deep seek\nDonos: JX1\nCara aleatório: Lorenzo gay",
    Color = "Red",
    Buttons = {}
})

--------------------------------------------------
--// TEMA LARANJA
--------------------------------------------------
WindUI:AddTheme({
    Name = "Laranja Vibrante",
    Accent = Color3.fromHex("#ff8800"),
    Background = Color3.fromHex("#1e1e1e"),
    Outline = Color3.fromHex("#ffaa33"),
    Text = Color3.fromHex("#ffffff"),
    Placeholder = Color3.fromHex("#aaaaaa"),
    Button = Color3.fromHex("#cc5500"),
    Icon = Color3.fromHex("#ffaa33"),
})

-- Tenta aplicar o tema
pcall(function() WindUI:SetTheme("Laranja Vibrante") end)

print("Interface carregada com sucesso!")
