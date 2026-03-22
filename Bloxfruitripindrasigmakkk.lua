-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela principal
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
    ScrollBarEnabled = true
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

-- Lista de banidos temporários
local bannedPlayers = {}

-- Função para idioma
local function getPlayerLanguage()
    local locale = LocalPlayer:GetLocale()
    if locale:match("pt") then return "pt"
    elseif locale:match("es") then return "es"
    else return "en" end
end

-- =============================================
-- Ações básicas
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

-- Magnetismo
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
                local model = part:FindFirstAncestorOfClass("Model")
                local isPlayer = model and model:FindFirstChild("Humanoid")
                if not isPlayer and part.Parent ~= targetChar then
                    local direction = (targetRoot.Position - part.Position).Unit
                    local velocity = direction * 100
                    local bv = part:FindFirstChild("MagnetVelocity") or Instance.new("BodyVelocity")
                    bv.Name = "MagnetVelocity"
                    bv.Velocity = velocity
                    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bv.Parent = part
                    game:GetService("Debris"):AddItem(bv, 0.2)

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

-- Ação especial
local function executeSpecialAction(targetPlayer)
    if not targetPlayer then return end
    local originalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not originalPos then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local tween = tweenToPosition(targetRoot.Position, 290)
    if tween then tween.Completed:Wait() end

    startMagnet(targetPlayer, 30)
    task.wait(30)

    tweenToPosition(originalPos, 290):Wait()
    jump()
end

-- Kill complexo
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

        local tween = tweenToPosition(targetRoot.Position, 250)
        if tween then tween.Completed:Wait() end

        local startTime = tick()
        repeat
            task.wait(0.1)
            local sitting = targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Sit
            if sitting or tick() - startTime >= 6 then
                local downPos = targetRoot.Position - Vector3.new(0, 20, 0)
                tweenToPosition(downPos, 500):Wait()
                break
            end
        until not killingActive

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

-- Bring player
local function bringPlayer(targetPlayer)
    if not targetPlayer then return end
    local originalPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not originalPos then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    local tween = tweenToPosition(targetRoot.Position, 250)
    if tween then tween.Completed:Wait() end

    local startTime = tick()
    repeat
        task.wait(0.1)
        local sitting = targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Sit
        if sitting or tick() - startTime >= 7 then
            break
        end
    until false

    tweenToPosition(originalPos, 250):Wait()
end

-- =============================================
-- Criação das abas
-- =============================================

-- ========== ABA 1: Visual Enderman Hub ==========
local Tab1 = Window:Tab({
    Title = "Visual Enderman Hub",
    Icon = "shield"
})

-- Criar os botões primeiro (travados)
local ButtonKick = Tab1:Button({
    Title = "Kick Player Visual",
    Desc = "Expulsa o jogador do servidor",
    Locked = true,
    Callback = function()
        if selectedPlayer then kickPlayer(selectedPlayer) end
    end
})

local ButtonBan = Tab1:Button({
    Title = "Ban Player Off Script 1 Hour",
    Desc = "Banimento local por 1 hora",
    Locked = true,
    Callback = function()
        if selectedPlayer then banPlayer(selectedPlayer) end
    end
})

local ButtonKill = Tab1:Button({
    Title = "Kill Player",
    Desc = "Mata o jogador instantaneamente",
    Locked = true,
    Callback = function()
        if selectedPlayer then killPlayer(selectedPlayer) end
    end
})

local ButtonFling = Tab1:Button({
    Title = "Fling Player",
    Desc = "Arremessa o jogador",
    Locked = true,
    Callback = function()
        if selectedPlayer then flingPlayer(selectedPlayer) end
    end
})

-- Dropdown (agora os botões já existem)
local selectedPlayer = nil

local function updatePlayerList()
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(players, plr.Name)
        end
    end
    return players
end

local Dropdown1 = Tab1:Dropdown({
    Title = "Selecionar Jogador",
    Desc = "Escolha um jogador do servidor",
    Values = updatePlayerList(),
    Value = "",
    Callback = function(option)
        if option and option ~= "" then
            selectedPlayer = Players:FindFirstChild(option)
            if selectedPlayer then
                ButtonKick:Unlock()
                ButtonBan:Unlock()
                ButtonKill:Unlock()
                ButtonFling:Unlock()
            end
        else
            selectedPlayer = nil
            ButtonKick:Lock()
            ButtonBan:Lock()
            ButtonKill:Lock()
            ButtonFling:Lock()
        end
    end
})

-- Atualizar dropdown dinamicamente
local function refreshDropdown1()
    local newList = updatePlayerList()
    Dropdown1:SetValues(newList)
    if selectedPlayer and not Players:FindFirstChild(selectedPlayer.Name) then
        selectedPlayer = nil
        Dropdown1:SetValue("")
        ButtonKick:Lock()
        ButtonBan:Lock()
        ButtonKill:Lock()
        ButtonFling:Lock()
    end
end
Players.PlayerAdded:Connect(refreshDropdown1)
Players.PlayerRemoving:Connect(refreshDropdown1)

-- Texto informativo
local lang1 = getPlayerLanguage()
local msg1 = ""
if lang1 == "pt" then
    msg1 = "Isso é para pessoas que usam o Enderman Hub, não vai afetar pessoas normais. É preciso do chat de texto, recomendo falar no privado com uma pessoa aleatória."
elseif lang1 == "es" then
    msg1 = "Esto es para personas que usan Enderman Hub, no afectará a personas normales. Se necesita el chat de texto, recomiendo hablar en privado con una persona aleatoria."
else
    msg1 = "This is for people who use Enderman Hub, it won't affect normal people. You need text chat, I recommend talking privately with a random person."
end
Tab1:Paragraph({
    Title = "Aviso",
    Desc = msg1,
    Color = "Orange"
})

-- ========== ABA 2: Not Visual ==========
local Tab2 = Window:Tab({
    Title = "Not Visual",
    Icon = "check-circle"
})

-- Botões da segunda aba (travados)
local ButtonSpecial = Tab2:Button({
    Title = "Fling/Ban/Kick Player No Visual ⚠️/☑️",
    Desc = "Tween até o jogador, magnetismo por 30s, retorno e pulo",
    Locked = true,
    Callback = function()
        if selectedPlayer2 then executeSpecialAction(selectedPlayer2) end
    end
})

local ButtonKillComplex = Tab2:Button({
    Title = "Kill Player ☢️/☑️",
    Desc = "Mata o jogador com tween repetido e verificação de saúde",
    Locked = true,
    Callback = function()
        if selectedPlayer2 then complexKill(selectedPlayer2) end
    end
})

local ButtonBring = Tab2:Button({
    Title = "Bring Player",
    Desc = "Tween até o jogador, espera sentar ou 7s, retorna",
    Locked = true,
    Callback = function()
        if selectedPlayer2 then bringPlayer(selectedPlayer2) end
    end
})

-- Dropdown segunda aba
local selectedPlayer2 = nil

local Dropdown2 = Tab2:Dropdown({
    Title = "Selecionar Jogador",
    Desc = "Escolha um jogador do servidor",
    Values = updatePlayerList(),
    Value = "",
    Callback = function(option)
        if option and option ~= "" then
            selectedPlayer2 = Players:FindFirstChild(option)
            if selectedPlayer2 then
                ButtonSpecial:Unlock()
                ButtonKillComplex:Unlock()
                ButtonBring:Unlock()
            end
        else
            selectedPlayer2 = nil
            ButtonSpecial:Lock()
            ButtonKillComplex:Lock()
            ButtonBring:Lock()
        end
    end
})

-- Atualizar dropdown segunda aba
local function refreshDropdown2()
    local newList = updatePlayerList()
    Dropdown2:SetValues(newList)
    if selectedPlayer2 and not Players:FindFirstChild(selectedPlayer2.Name) then
        selectedPlayer2 = nil
        Dropdown2:SetValue("")
        ButtonSpecial:Lock()
        ButtonKillComplex:Lock()
        ButtonBring:Lock()
    end
end
Players.PlayerAdded:Connect(refreshDropdown2)
Players.PlayerRemoving:Connect(refreshDropdown2)

-- Toggle view player
local viewing = false
local viewConnection = nil
local ToggleView = Tab2:Toggle({
    Title = "View Player",
    Desc = "Câmera segue o jogador selecionado (orbita)",
    Icon = "camera",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        viewing = state
        if viewConnection then viewConnection:Disconnect() end
        if state then
            if selectedPlayer2 and selectedPlayer2.Character then
                local hum = selectedPlayer2.Character:FindFirstChild("Humanoid")
                if hum then
                    Camera.CameraSubject = hum
                    viewConnection = RunService.RenderStepped:Connect(function()
                        if not viewing or not selectedPlayer2 or not selectedPlayer2.Character or not selectedPlayer2.Character:FindFirstChild("Humanoid") then
                            viewing = false
                            ToggleView:SetValue(false)
                            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                            if viewConnection then viewConnection:Disconnect() end
                        end
                    end)
                end
            else
                ToggleView:SetValue(false)
            end
        else
            if LocalPlayer.Character then
                Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        end
    end
})

-- Texto beta
local lang2 = getPlayerLanguage()
local msg2 = ""
if lang2 == "pt" then
    msg2 = "⚠️ Isto é beta e tem chance de dar ban. É necessário estar sentado em um barco. Então compre."
elseif lang2 == "es" then
    msg2 = "⚠️ Esto es beta y tiene posibilidad de baneo. Es necesario estar sentado en un bote. Así que compra."
else
    msg2 = "⚠️ This is beta and there is a chance of ban. You need to be sitting in a boat. So buy."
end
Tab2:Paragraph({
    Title = "Aviso Beta",
    Desc = msg2,
    Color = "Orange"
})

-- ========== ABA 3: Leia Me ==========
local Tab3 = Window:Tab({
    Title = "Leia Me",
    Icon = "book"
})

local lang3 = getPlayerLanguage()
local msg3 = ""
if lang3 == "pt" then
    msg3 = "⚠️ Risco de banimento\n☢️ Super chance de ban\n☑️ Beta\n✅ Tudo certo\n❌ Bugado"
elseif lang3 == "es" then
    msg3 = "⚠️ Riesgo de baneo\n☢️ Super chance de baneo\n☑️ Beta\n✅ Todo correcto\n❌ Bugueado"
else
    msg3 = "⚠️ Risk of ban\n☢️ Super chance of ban\n☑️ Beta\n✅ All good\n❌ Buggy"
end
Tab3:Paragraph({
    Title = "Status do Hub",
    Desc = msg3,
    Color = "White"
})

-- =============================================
-- Finalização
-- =============================================
WindUI:Notify({
    Title = "Hub Pronto",
    Content = "Lorenzo Hub LOL carregado com sucesso!",
    Duration = 4,
    Icon = "rocket"
})
