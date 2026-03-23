-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela
local Window = WindUI:CreateWindow({
    Title = "Enderman Hub",
    Icon = "crown",
    Author = "by Enderman",
    Subtitle = "blox fruts troll",
    Folder = "EndermanHub",
    Size = UDim2.fromOffset(500, 400),
    MinSize = Vector2.new(450, 350),
    MaxSize = Vector2.new(700, 500),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = true,
    KeySystem = {
        Key = {"Endermanhub-key-130-KEY/LUA"},
        Note = "A key salva para toda vida",
        URL = "https://linkvertise.com/1460648/0qx6liYVnx53?o=sharing",
        SaveKey = true,
    }
})

Window:Tag({ Title = "v1.0", Icon = "github", Color = Color3.fromHex("#ff6a30"), Radius = 6 })
WindUI:Notify({ Title = "Enderman Hub", Content = "Carregado!", Duration = 3, Icon = "check" })

-- =============================================
-- Aba OP
-- =============================================
local Tab = Window:Tab({ Title = "OP", Icon = "bolt" })

-- Variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies") -- Nome da pasta de inimigos no Blox Fruits

local selectedFruit = "Blade"
local loopActive = false
local currentCoroutine = nil
local charAddedConnection = nil -- conexão global para CharacterAdded

-- =============================================
-- Função para desativar completamente o loop
-- =============================================
local function stopLoop()
    loopActive = false
    if charAddedConnection then
        charAddedConnection:Disconnect()
        charAddedConnection = nil
    end
    currentCoroutine = nil
end

-- =============================================
-- Script da Blade (com cleanup)
-- =============================================
local function startBlade()
    local player = LocalPlayer
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local bladeRemote = character:FindFirstChild("Blade-Blade")
    if not bladeRemote then
        WindUI:Notify({ Title = "Erro", Content = "Fruta Blade não encontrada!", Duration = 3, Icon = "exclamation" })
        return
    end
    local remote = bladeRemote:FindFirstChild("LeftClickRemote")
    if not remote then
        WindUI:Notify({ Title = "Erro", Content = "Remote da Blade não encontrado!", Duration = 3, Icon = "exclamation" })
        return
    end

    local combo = 1
    local connection = nil

    -- Atualiza referências quando o personagem renascer
    connection = player.CharacterAdded:Connect(function(newChar)
        character = newChar
        root = character:WaitForChild("HumanoidRootPart")
        local newBlade = character:FindFirstChild("Blade-Blade")
        if newBlade then
            remote = newBlade:FindFirstChild("LeftClickRemote")
        else
            remote = nil
        end
    end)
    charAddedConnection = connection

    while loopActive and selectedFruit == "Blade" do
        if character and root and remote then
            local nearest = nil
            local shortest = math.huge

            for _, mob in ipairs(enemiesFolder:GetChildren()) do
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < shortest and dist <= 80 then
                        shortest = dist
                        nearest = hrp
                    end
                end
            end

            if nearest then
                local direction = (nearest.Position - root.Position).Unit
                pcall(function()
                    remote:FireServer(direction, combo)
                end)
                combo = combo % 2 + 1
            end
        end
        task.wait()
    end

    -- Ao sair, desconecta o evento de renascimento
    if connection then connection:Disconnect() end
end

-- =============================================
-- Script da Dough Beta (com cleanup)
-- =============================================
local function startDough()
    local player = LocalPlayer
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    local remote = nil

    local function findRemote()
        if not hum then return nil end
        for _, v in ipairs(hum:GetChildren()) do
            if v:IsA("RemoteFunction") then
                return v
            end
        end
        return nil
    end

    remote = findRemote()
    if not remote then
        WindUI:Notify({ Title = "Erro", Content = "Remote da Dough não encontrado!", Duration = 3, Icon = "exclamation" })
        return
    end

    local connection = nil
    connection = player.CharacterAdded:Connect(function(newChar)
        character = newChar
        root = character:WaitForChild("HumanoidRootPart")
        hum = character:FindFirstChild("Humanoid")
        remote = findRemote()
    end)
    charAddedConnection = connection

    local RANGE = 80

    while loopActive and selectedFruit == "dough Beta" do
        if character and root and remote then
            local nearest = nil
            local shortest = math.huge

            for _, mob in ipairs(enemiesFolder:GetChildren()) do
                local humMob = mob:FindFirstChildOfClass("Humanoid")
                local hrp = mob:FindFirstChild("HumanoidRootPart")
                if humMob and hrp and humMob.Health > 0 then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < shortest and dist <= RANGE then
                        shortest = dist
                        nearest = hrp
                    end
                end
            end

            if nearest then
                pcall(function()
                    root.CFrame = CFrame.lookAt(root.Position, nearest.Position)
                    remote:InvokeServer("TAP")
                end)
            end
        end
        task.wait(0.04)
    end

    if connection then connection:Disconnect() end
end

-- =============================================
-- Função para iniciar o loop atual
-- =============================================
local function startLoop()
    if currentCoroutine then
        -- Força a parada do loop anterior (se estiver rodando)
        loopActive = false
        task.wait(0.1) -- dá tempo para a corrotina antiga sair
    end
    if not loopActive then return end

    if selectedFruit == "Blade" then
        currentCoroutine = coroutine.wrap(startBlade)
        currentCoroutine()
    elseif selectedFruit == "dough Beta" then
        currentCoroutine = coroutine.wrap(startDough)
        currentCoroutine()
    end
end

-- =============================================
-- Componentes da interface
-- =============================================

-- Dropdown
local Dropdown = Tab:Dropdown({
    Title = "Selecionar Fruta",
    Desc = "Escolha Blade ou Dough Beta",
    Values = { "Blade", "dough Beta" },
    Value = "Blade",
    Callback = function(option)
        selectedFruit = option
        if loopActive then
            -- Reinicia o loop com a nova fruta
            startLoop()
        end
    end
})

-- Toggle
local Toggle = Tab:Toggle({
    Title = "Fast Attack Fruits",
    Desc = "Ativa o ataque automático com a fruta selecionada",
    Icon = "bolt",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            loopActive = true
            startLoop()
        else
            stopLoop()
        end
    end
})

-- Parágrafo informativo
Tab:Paragraph({
    Title = "Aviso",
    Desc = "Tudo isso está em beta script vai forçar em quebrar jogo completamente invés de só auto farm etc use com outros scripts tipo banana hub recomendo são hoho hub\nAtive bring mobs para ficar 100% forte.",
    Color = "Orange"
})

-- Notificação final
WindUI:Notify({
    Title = "Pronto!",
    Content = "Selecione a fruta e ative o toggle.",
    Duration = 3,
    Icon = "info"
})
