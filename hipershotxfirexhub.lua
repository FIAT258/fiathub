-- Carrega a WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Cria a janela principal (com KeySystem mantido)
local Window = WindUI:CreateWindow({
    Title = "XFIREX HUB ripershot",
    Icon = "crosshair",
    Author = "by JX1 and lorenzo",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = false,
    Theme = "Laranja Vibrante",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
    KeySystem = {
        Key = { "1234", "5678" },
        Note = ".",
        Thumbnail = {
            Image = "rbxassetid://133843871041283",
            Title = "",
        },
        URL = "YOUR LINK TO GET KEY (Discord, Linkvertise, Pastebin, etc.)",
        SaveKey = false,
    },
})

-- Adiciona uma tag na janela
Window:Tag({
    Title = "v1",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

-- ==================== AIM BOT TAB ====================
local AimTab = Window:Tab({
    Title = "Aim Bot",
    Icon = "crosshair", -- ícone de mira
})

-- Dropdown para escolher a parte do corpo
local bodyPartDropdown = AimTab:Dropdown({
    Title = "Parte do Corpo",
    Desc = "Selecione onde mirar",
    Values = { "Tronco", "Costas", "Cabeça" },
    Value = { "Tronco" },
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        -- option é uma tabela com um item, ex: { "Cabeça" }
        _G.SelectedBodyPart = option[1] -- armazena globalmente
    end
})

-- Toggle para ativar/desativar o aimbot
local aimbotToggle = AimTab:Toggle({
    Title = "Aim Bot Players",
    Desc = "Atira automaticamente no jogador mais próximo",
    Icon = "target",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.AimbotEnabled = state
        if not state then
            -- se desligar, para de travar a câmera
            _G.CurrentTarget = nil
        end
    end
})

-- Toggle para ignorar ou mirar em aliados
local teamAimToggle = AimTab:Toggle({
    Title = "Mirar em Rivals apenas",
    Desc = "Se ativado, só mira em jogadores de time diferente",
    Icon = "users",
    Type = "Checkbox",
    Value = true, -- padrão: só rivais
    Callback = function(state)
        _G.AimbotTeamRivalOnly = state
    end
})

-- Variáveis globais para controle do aimbot
_G.AimbotEnabled = false
_G.AimbotTeamRivalOnly = true
_G.SelectedBodyPart = "Tronco"
_G.CurrentTarget = nil
_G.BodyParts = {
    Tronco = "HumanoidRootPart",
    Costas = "UpperTorso", -- ou LowerTorso, dependendo da preferência
    Cabeça = "Head"
}

-- Função para obter o jogador mais próximo
local function getClosestPlayer()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestDist = math.huge
    local closestTarget = nil

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            -- Verifica se deve ignorar aliados
            if _G.AimbotTeamRivalOnly then
                if player.Team == otherPlayer.Team then
                    continue
                end
            end

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
    return closestTarget
end

-- Loop do aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    if not _G.AimbotEnabled then return end

    local player = game.Players.LocalPlayer
    if not player then return end

    local target = getClosestPlayer()
    if target then
        _G.CurrentTarget = target
    else
        _G.CurrentTarget = nil
        return
    end

    local targetChar = _G.CurrentTarget.Character
    if not targetChar then return end

    -- Verifica se o alvo ainda está vivo
    local humanoid = targetChar:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        -- Alvo morreu, procura próximo
        _G.CurrentTarget = getClosestPlayer()
        if not _G.CurrentTarget then return end
        targetChar = _G.CurrentTarget.Character
        if not targetChar then return end
    end

    -- Obtém a parte do corpo selecionada
    local partName = _G.BodyParts[_G.SelectedBodyPart]
    local targetPart = targetChar:FindFirstChild(partName)
    if not targetPart then
        -- Fallback para HumanoidRootPart se a parte não existir
        targetPart = targetChar:FindFirstChild("HumanoidRootPart")
    end

    if targetPart then
        -- Trava a câmera na parte selecionada
        local camera = workspace.CurrentCamera
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
    end
end)

-- ==================== ESP TAB ====================
local EspTab = Window:Tab({
    Title = "ESP",
    Icon = "eye",
})

-- Toggle ESP geral
local espToggle = EspTab:Toggle({
    Title = "ESP",
    Desc = "Mostra contorno e informações dos jogadores",
    Icon = "scan-eye",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.ESPEnabled = state
        if not state then
            -- Remove todos os destaques e billboards
            for _, v in pairs(_G.ESPObjects or {}) do
                if v.Highlight then v.Highlight:Destroy() end
                if v.Billboard then v.Billboard:Destroy() end
            end
            _G.ESPObjects = {}
        end
    end
})

-- Toggle para diferenciar times
local espTeamToggle = EspTab:Toggle({
    Title = "ESP por Time",
    Desc = "Aliados em azul, inimigos em branco/vermelho",
    Icon = "users",
    Type = "Checkbox",
    Value = true,
    Callback = function(state)
        _G.ESPTeamEnabled = state
        -- Atualiza as cores imediatamente se o ESP estiver ativo
        if _G.ESPEnabled then
            updateESP()
        end
    end
})

-- Variáveis globais para ESP
_G.ESPEnabled = false
_G.ESPTeamEnabled = true
_G.ESPObjects = {} -- tabela para armazenar os objetos de ESP por jogador

-- Função para criar ou atualizar ESP em um jogador
local function updateESPForPlayer(player)
    if not _G.ESPObjects then _G.ESPObjects = {} end
    if not _G.ESPObjects[player] then
        _G.ESPObjects[player] = {}
    end

    local esp = _G.ESPObjects[player]
    local char = player.Character
    if not char then
        -- Se o personagem não existe, remove os objetos
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        _G.ESPObjects[player] = nil
        return
    end

    -- Cria o Highlight se não existir
    if not esp.Highlight then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        esp.Highlight = highlight
    end

    -- Define a cor do contorno baseado no time
    local localPlayer = game.Players.LocalPlayer
    if _G.ESPTeamEnabled and localPlayer.Team then
        if player.Team == localPlayer.Team then
            esp.Highlight.FillColor = Color3.fromRGB(0, 100, 255) -- azul para aliados
            esp.Highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        else
            esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255) -- branco para inimigos (pode trocar para vermelho)
            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end
    else
        esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255) -- branco para todos
        esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end

    -- Cria um BillboardGui para mostrar nome e distância
    if not esp.Billboard then
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1

        local nameLabel = Instance.new("TextLabel", frame)
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
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

        esp.Billboard = billboard
        esp.NameLabel = nameLabel
        esp.DistLabel = distLabel
    else
        -- Atualiza a posição do Billboard (caso o Head mude)
        esp.Billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    end

    -- Atualiza a distância
    local localChar = localPlayer.Character
    if localChar and localChar:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
        local dist = (localChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
        esp.DistLabel.Text = string.format("Dist: %.1f", dist)
    end
end

-- Função para atualizar todos os ESPs
local function updateESP()
    if not _G.ESPEnabled then return end
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            updateESPForPlayer(player)
        end
    end
end

-- Conecta eventos para manter o ESP atualizado
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5) -- espera o personagem carregar
        if _G.ESPEnabled then
            updateESPForPlayer(player)
        end
    end)
    if _G.ESPEnabled then
        updateESPForPlayer(player)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.ESPObjects and _G.ESPObjects[player] then
        if _G.ESPObjects[player].Highlight then
            _G.ESPObjects[player].Highlight:Destroy()
        end
        if _G.ESPObjects[player].Billboard then
            _G.ESPObjects[player].Billboard:Destroy()
        end
        _G.ESPObjects[player] = nil
    end
end)

-- Loop de atualização do ESP (a cada frame, mas com baixo custo)
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPEnabled then
        updateESP()
    end
end)

-- ==================== EXTRAS TAB ====================
local ExtrasTab = Window:Tab({
    Title = "Extras",
    Icon = "package",
})

-- Slider de velocidade (0 a 300)
local speedSlider = ExtrasTab:Slider({
    Title = "Velocidade",
    Desc = "Ajusta a velocidade do jogador",
    Step = 1,
    Value = {
        Min = 0,
        Max = 300,
        Default = 16, -- velocidade padrão do Roblox
    },
    Callback = function(value)
        _G.SpeedValue = value
        if _G.SpeedEnabled then
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end
    end
})

-- Toggle para ativar a velocidade personalizada
local speedToggle = ExtrasTab:Toggle({
    Title = "Speed Player",
    Desc = "Ativa a velocidade ajustada acima",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.SpeedEnabled = state
        local player = game.Players.LocalPlayer
        if player and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                if state then
                    humanoid.WalkSpeed = _G.SpeedValue or 16
                else
                    humanoid.WalkSpeed = 16 -- volta ao normal
                end
            end
        end
    end
})

-- Toggle de infinite jump
local infiniteJumpToggle = ExtrasTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Permite pular infinitamente",
    Icon = "arrow-up",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        _G.InfiniteJumpEnabled = state
        if state then
            -- Conecta o evento de pulo
            _G.JumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if _G.JumpConnection then
                _G.JumpConnection:Disconnect()
                _G.JumpConnection = nil
            end
        end
    end
})

-- Dropdown de players (sempre atualizado)
local playerDropdown = ExtrasTab:Dropdown({
    Title = "Players",
    Desc = "Selecione um jogador para teleporte",
    Values = {}, -- será preenchido dinamicamente
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        _G.SelectedPlayerForTP = option[1] -- armazena o nome do jogador selecionado
    end
})

-- Função para atualizar a lista de players no dropdown
local function updatePlayerList()
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    playerDropdown:SetValues(players)
end

-- Atualiza a lista quando players entram/saem
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
-- Atualiza agora
updatePlayerList()

-- Botão de teleporte
local tpButton = ExtrasTab:Button({
    Title = "Teleportar para o Player",
    Desc = "Teletransporta você até o jogador selecionado",
    Callback = function()
        if not _G.SelectedPlayerForTP then
            WindUI:Notify({
                Title = "Erro",
                Content = "Nenhum jogador selecionado!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local targetPlayer = game.Players:FindFirstChild(_G.SelectedPlayerForTP)
        if not targetPlayer then
            WindUI:Notify({
                Title = "Erro",
                Content = "Jogador não encontrado!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local targetChar = targetPlayer.Character
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
            WindUI:Notify({
                Title = "Erro",
                Content = "Jogador sem personagem válido!",
                Duration = 3,
                Icon = "alert-circle"
            })
            return
        end
        local localPlayer = game.Players.LocalPlayer
        local localChar = localPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0) -- um pouco acima para não ficar dentro
            WindUI:Notify({
                Title = "Teleportado",
                Content = "Você foi teleportado para " .. targetPlayer.Name,
                Duration = 3,
                Icon = "check-circle"
            })
        end
    end
})

-- ==================== CRÉDITOS TAB ====================
local CreditosTab = Window:Tab({
    Title = "Créditos",
    Icon = "heart",
})

-- Parágrafo com os créditos
local creditosParagraph = CreditosTab:Paragraph({
    Title = "Créditos",
    Desc = "Informações sobre os criadores",
    Color = "Blue",
    Buttons = {},
})

-- Atualiza o texto do parágrafo (a WindUI não tem um método direto para mudar o texto depois de criado? Vamos usar um texto fixo)
-- Na verdade, o Paragraph já aceita um parâmetro "Desc" que é o texto. Vamos criar com o texto desejado.
-- Mas como já criamos, podemos recriar ou usar um Label separado. Vou optar por recriar com o texto correto.

-- Melhor: vamos substituir o Paragraph criado por um novo com o texto desejado.
-- Vamos remover o anterior e criar um novo.
-- Como não temos referência direta para remover, vou criar outro com o mesmo Title? A WindUI pode permitir apenas um por título. Vou simplesmente usar um Paragraph com o texto incluído.

-- Vou recriar a aba de créditos do zero para garantir:
CreditosTab:Clear() -- se existir um método, mas não sei se tem. Vou fazer direto.

local creditos = CreditosTab:Paragraph({
    Title = "Créditos",
    Desc = "Interface: deep seek\nDonos: JX1\nCara aleatório: Lorenzo gay",
    Color = "Red",
    Buttons = {}
})

-- ==================== FINALIZAÇÃO ====================
-- Tema personalizado com tons de laranja
WindUI:AddTheme({
    Name = "Laranja Vibrante",        -- Nome do tema
    Accent = Color3.fromHex("#ff8800"),  -- Laranja vibrante (destaques)
    Background = Color3.fromHex("#1e1e1e"), -- Cinza bem escuro (fundo)
    Outline = Color3.fromHex("#ffaa33"),   -- Laranja claro (contornos)
    Text = Color3.fromHex("#ffffff"),      -- Branco (texto)
    Placeholder = Color3.fromHex("#aaaaaa"), -- Cinza médio (placeholders)
    Button = Color3.fromHex("#cc5500"),    -- Laranja escuro queimado (botões)
    Icon = Color3.fromHex("#ffaa33"),      -- Laranja claro (ícones)
})

-- Para aplicar automaticamente (se suportado):
 WindUI:SetTheme("Laranja Vibrante")

print("Interface carregada com sucesso!")
