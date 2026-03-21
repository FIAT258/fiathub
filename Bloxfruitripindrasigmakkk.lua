-- =============================================
-- Carregar WindUI
-- =============================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- =============================================
-- Criar janela principal
-- =============================================
local Window = WindUI:CreateWindow({
    Title = "Lorenzo Hub LOL | Painel de Adm Blox Fruits",
    Icon = "crown",
    Author = "by Lorenzo",
    Folder = "LorenzoHubLOL",
    Size = UDim2.fromOffset(620, 540),
    MinSize = Vector2.new(560, 450),
    MaxSize = Vector2.new(900, 700),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.3,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    Background = "rbxassetid://127678642039561", -- ID fornecido
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("Perfil clicado")
        end,
    },
    KeySystem = {
        Key = {"lorenzo123", "admin2025"},
        Note = "Digite a chave para acessar o painel",
        URL = "",
        SaveKey = true,
    }
})

-- Tag de versão
Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#ff6a30"),
    Radius = 6
})

-- Notificação inicial
WindUI:Notify({
    Title = "Hub Carregado",
    Content = "Bem-vindo ao Lorenzo Hub LOL!",
    Duration = 4,
    Icon = "check"
})

-- =============================================
-- Serviços e variáveis globais
-- =============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Lista de banidos temporários (1 hora)
local bannedPlayers = {} -- [UserId] = timestamp do fim do ban

-- Função para obter o idioma do jogador
local function getPlayerLanguage()
    local locale = LocalPlayer:GetLocale()
    if locale:match("pt") then return "pt"
    elseif locale:match("es") then return "es"
    else return "en" end
end

-- =============================================
-- Funções de ação básicas
-- =============================================
local function kickPlayer(player)
    if player and player ~= LocalPlayer then
        player:Kick("Expulso pelo administrador (Lorenzo Hub)")
    end
end

local function banPlayer(player)
    if player and player ~= LocalPlayer then
        local userId = player.UserId
        local banEnd = os.time() + 3600
        bannedPlayers[userId] = banEnd
        player:Kick("Banido por 1 hora (Lorenzo Hub)")
        local conn
        conn = Players.PlayerAdded:Connect(function(newPlayer)
            if newPlayer.UserId == userId then
                if os.time() < banEnd then
                    newPlayer:Kick("Você ainda está banido por " .. math.floor((banEnd - os.time()) / 60) .. " minutos.")
                else
                    bannedPlayers[userId] = nil
                    conn:Disconnect()
                end
            end
        end)
    end
end

local function killPlayer(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

local function flingPlayer(player)
    if player and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local velocity = Instance.new("BodyVelocity")
            velocity.Velocity = Vector3.new(math.random(-500, 500), math.random(200, 500), math.random(-500, 500))
            velocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            velocity.Parent = root
            game:GetService("Debris"):AddItem(velocity, 2)
        end
    end
end

-- =============================================
-- Funções de movimento (tween)
-- =============================================
local function tweenToPosition(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local distance = (root.Position - targetPos).Magnitude
    local duration = distance / speed
    if duration <= 0 then return nil end
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(targetPos)}
    local tween = TweenService:Create(root, tweenInfo, goal)
    tween:Play()
    return tween
end

local function jump()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Jump = true end
    end
end

-- =============================================
-- Magnetismo (puxa objetos não ancorados e os gira)
-- =============================================
local function startMagnet(targetPlayer, duration)
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local active = true
    local magnetConnection

    local function applyEffects()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                -- Ignorar partes que pertencem a jogadores (evita puxar outros players)
                local model = part:FindFirstAncestorOfClass("Model")
                local isPlayer = model and model:FindFirstChild("Humanoid")
                if not isPlayer and part.Parent ~= targetChar then
                    -- Força em direção ao alvo
                    local direction = (targetRoot.Position - part.Position).Unit
                    local velocity = direction * 100
                    local bv = part:FindFirstChild("MagnetVelocity") or Instance.new("BodyVelocity")
                    bv.Name = "MagnetVelocity"
                    bv.Velocity = velocity
                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bv.Parent = part
                    game:GetService("Debris"):AddItem(bv, 0.2)

                    -- Rotação rápida em torno do próprio eixo
                    local angVel = part:FindFirstChild("MagnetAngular") or Instance.new("BodyAngularVelocity")
                    angVel.Name = "MagnetAngular"
                    angVel.AngularVelocity = Vector3.new(0, 50, 0)
                    angVel.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                    angVel.Parent = part
                    game:GetService("Debris"):AddItem(angVel, 0.2)
                end
            end
        end
    end

    magnetConnection = RunService.Heartbeat:Connect(function()
        if not active then
            magnetConnection:Disconnect()
            return
        end
        applyEffects()
    end)

    task.wait(duration)
    active = false
end

-- =============================================
-- Ação especial "fling/ban/kick player no visual"
-- =============================================
local function executeSpecialAction(targetPlayer)
    if not targetPlayer then return end
    local originalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not originalPos then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Tween até o alvo (290 velocidade)
    local tween = tweenToPosition(targetRoot.Position, 290)
    if tween then tween.Completed:Wait() end

    -- Ativar magnetismo por 30 segundos
    startMagnet(targetPlayer, 30)

    -- Aguardar 30 segundos
    task.wait(30)

    -- Voltar à posição original
    tweenToPosition(originalPos, 290):Wait()
    jump()
end

-- =============================================
-- Kill player ☢️/☑️ (complexo)
-- =============================================
local killingActive = false
local function complexKill(targetPlayer)
    if killingActive then return end
    killingActive = true

    local originalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not originalPos then killingActive = false; return end

    local function checkUserHealth()
        local userChar = LocalPlayer.Character
        if userChar then
            local hum = userChar:FindFirstChild("Humanoid")
            if hum and hum.Health <= 160 then
                jump()
                tweenToPosition(originalPos, 250)
                return true
            end
        end
        return false
    end

    while killingActive do
        local targetChar = targetPlayer.Character
        if not targetChar then break end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then break end

        -- Tween até o alvo (250 velocidade)
        local tween = tweenToPosition(targetRoot.Position, 250)
        if tween then tween.Completed:Wait() end

        -- Aguarda até sentar ou 6 segundos
        local startTime = tick()
        repeat
            task.wait(0.1)
            local sitting = targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Sit
            if sitting or tick() - startTime >= 6 then
                -- Tween para baixo rapidamente
                local downPos = targetRoot.Position - Vector3.new(0, 20, 0)
                tweenToPosition(downPos, 500):Wait()
                break
            end
        until not killingActive

        -- Verifica se alvo morreu
        local humanoid = targetChar:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            if humanoid then humanoid.Sit = true end
            break
        end

        if checkUserHealth() then break end

        task.wait(0.5)
    end

    killingActive = false
end

-- =============================================
-- Bring player
-- =============================================
local function bringPlayer(targetPlayer)
    if not targetPlayer then return end
    local originalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not originalPos then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    -- Tween até o alvo (250 velocidade)
    local tween = tweenToPosition(targetRoot.Position, 250)
    if tween then tween.Completed:Wait() end

    -- Aguarda sentar ou 7 segundos
    local startTime = tick()
    repeat
        task.wait(0.1)
        local sitting = targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Sit
        if sitting or tick() - startTime >= 7 then
            break
        end
    until false

    -- Volta à posição original
    tweenToPosition(originalPos, 250):Wait()
end

-- =============================================
-- Função auxiliar para criar uma aba com dropdown e botões
-- =============================================
local function createPlayerTab(tab, titlePrefix, extraButtons)
    local dropdownObj = nil
    local selectedPlayer = nil
    local buttons = {} -- armazena todos os botões (incluindo os extras)

    -- Atualiza a lista de jogadores no dropdown
    local function updatePlayerList()
        local players = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(players, plr.Name)
            end
        end
        if dropdownObj then
            dropdownObj:SetValues(players)
            -- Se o jogador selecionado não estiver mais na lista, limpa seleção
            if selectedPlayer and not table.find(players, selectedPlayer.Name) then
                selectedPlayer = nil
                dropdownObj:SetValue({})
                -- Bloqueia todos os botões
                for _, btn in ipairs(buttons) do
                    if btn then btn:Lock() end
                end
            end
        end
    end

    -- Cria dropdown
    dropdownObj = tab:Dropdown({
        Title = "Selecionar Jogador",
        Desc = "Escolha um jogador do servidor",
        Values = {}, -- será preenchido depois
        Value = {},
        Multi = false,
        AllowNone = true,
        Callback = function(selected)
            if selected and #selected > 0 then
                local name = selected[1]
                selectedPlayer = Players:FindFirstChild(name)
                if selectedPlayer then
                    -- Desbloqueia todos os botões
                    for _, btn in ipairs(buttons) do
                        if btn then btn:Unlock() end
                    end
                else
                    for _, btn in ipairs(buttons) do
                        if btn then btn:Lock() end
                    end
                end
            else
                selectedPlayer = nil
                for _, btn in ipairs(buttons) do
                    if btn then btn:Lock() end
                end
            end
        end
    })

    -- Atualiza lista inicial e conecta eventos
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)

    -- Função para obter o jogador selecionado
    local function getSelected()
        return selectedPlayer
    end

    -- Adiciona botões passados via parâmetro
    for _, btnDef in ipairs(extraButtons) do
        local btn = tab:Button(btnDef)
        table.insert(buttons, btn)
    end

    return {
        dropdown = dropdownObj,
        getSelected = getSelected,
        buttons = buttons
    }
end

-- =============================================
-- Aba 1: Visual Enderman Hub (ícone escudo)
-- =============================================
local tabVisual = Window:Tab({
    Title = "Visual Enderman Hub",
    Icon = "shield"
})

-- Botões da primeira aba
local visualButtons = {
    {
        Title = "Kick Player Visual",
        Desc = "Expulsa o jogador do servidor",
        Locked = true,
        Callback = function() 
            local target = visualControls.getSelected()
            if target then kickPlayer(target) end
        end
    },
    {
        Title = "Ban Player Off Script 1 Hour",
        Desc = "Banimento local por 1 hora",
        Locked = true,
        Callback = function()
            local target = visualControls.getSelected()
            if target then banPlayer(target) end
        end
    },
    {
        Title = "Kill Player",
        Desc = "Mata o jogador instantaneamente",
        Locked = true,
        Callback = function()
            local target = visualControls.getSelected()
            if target then killPlayer(target) end
        end
    },
    {
        Title = "Fling Player",
        Desc = "Arremessa o jogador",
        Locked = true,
        Callback = function()
            local target = visualControls.getSelected()
            if target then flingPlayer(target) end
        end
    }
}

local visualControls = createPlayerTab(tabVisual, "Visual ", visualButtons)

-- Texto informativo com idioma
local lang1 = getPlayerLanguage()
local msg1 = ""
if lang1 == "pt" then
    msg1 = "Isso é para pessoas que usam o Enderman Hub, não vai afetar pessoas normais. É preciso do chat de texto, recomendo falar no privado com uma pessoa aleatória."
elseif lang1 == "es" then
    msg1 = "Esto es para personas que usan Enderman Hub, no afectará a personas normales. Se necesita el chat de texto, recomiendo hablar en privado con una persona aleatoria."
else
    msg1 = "This is for people who use Enderman Hub, it won't affect normal people. You need text chat, I recommend talking privately with a random person."
end
tabVisual:Paragraph({
    Title = "Aviso",
    Desc = msg1,
    Color = "Orange"
})

-- =============================================
-- Aba 2: Not Visual (ícone verificado)
-- =============================================
local tabNotVisual = Window:Tab({
    Title = "Not Visual",
    Icon = "check-circle"
})

-- Botões da segunda aba (incluindo os especiais)
local notVisualButtons = {
    -- Botão especial "fling/ban/kick player no visual"
    {
        Title = "Fling/Ban/Kick Player No Visual ⚠️/☑️",
        Desc = "Tween até o jogador, magnetismo por 30s, retorno e pulo",
        Locked = true,
        Callback = function()
            local target = notVisualControls.getSelected()
            if target then executeSpecialAction(target) end
        end
    },
    -- Botão "kill player ☢️/☑️"
    {
        Title = "Kill Player ☢️/☑️",
        Desc = "Mata o jogador com tween repetido e verificação de saúde",
        Locked = true,
        Callback = function()
            local target = notVisualControls.getSelected()
            if target then complexKill(target) end
        end
    },
    -- Botão "bring player"
    {
        Title = "Bring Player",
        Desc = "Tween até o jogador, espera sentar ou 7s, retorna",
        Locked = true,
        Callback = function()
            local target = notVisualControls.getSelected()
            if target then bringPlayer(target) end
        end
    }
}

local notVisualControls = createPlayerTab(tabNotVisual, "Not Visual ", notVisualButtons)

-- Toggle "view player" (não pode ser bloqueado pelo dropdown, então adicionamos separadamente)
local viewing = false
local viewConnection = nil
local viewToggle = tabNotVisual:Toggle({
    Title = "View Player",
    Desc = "Câmera segue o jogador selecionado (orbita)",
    Icon = "camera",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        viewing = state
        if viewConnection then viewConnection:Disconnect() end
        if state then
            local target = notVisualControls.getSelected()
            if target and target.Character then
                local hum = target.Character:FindFirstChild("Humanoid")
                if hum then
                    Camera.CameraSubject = hum
                    viewConnection = RunService.RenderStepped:Connect(function()
                        if not viewing or not target or not target.Character or not target.Character:FindFirstChild("Humanoid") then
                            viewing = false
                            viewToggle:SetValue(false)
                            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                            if viewConnection then viewConnection:Disconnect() end
                        end
                    end)
                end
            else
                viewToggle:SetValue(false)
            end
        else
            if LocalPlayer.Character then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        end
    end
})

-- Texto informativo (beta) com idioma
local lang2 = getPlayerLanguage()
local msg2 = ""
if lang2 == "pt" then
    msg2 = "⚠️ Isto é beta e tem chance de dar ban. É necessário estar sentado em um barco. Então compre."
elseif lang2 == "es" then
    msg2 = "⚠️ Esto es beta y tiene posibilidad de baneo. Es necesario estar sentado en un bote. Así que compra."
else
    msg2 = "⚠️ This is beta and there is a chance of ban. You need to be sitting in a boat. So buy."
end
tabNotVisual:Paragraph({
    Title = "Aviso Beta",
    Desc = msg2,
    Color = "Orange"
})

-- =============================================
-- Aba 3: Leia Me (ícone livro)
-- =============================================
