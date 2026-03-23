-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela com KeySystem
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
        Key = {"enderman2025"}, -- Chave de acesso
        Note = "Digite a chave para acessar o hub",
        URL = "", -- Link opcional para obter a key
        SaveKey = true,
    }
})

Window:Tag({ Title = "v1.0", Icon = "github", Color = Color3.fromHex("#ff6a30"), Radius = 6 })
WindUI:Notify({ Title = "Enderman Hub", Content = "Carregado!", Duration = 3, Icon = "check" })

-- =============================================
-- Aba OP
-- =============================================
local Tab = Window:Tab({ Title = "OP", Icon = "bolt" })

-- Variáveis de controle
local selectedFruit = "Blade"  -- ou "dough Beta"
local isActive = false
local currentLoop = nil  -- armazena a corrotina atual

-- Função para parar o loop atual
local function stopLoop()
    isActive = false
    currentLoop = nil
end

-- Script da Blade (exatamente como fornecido, mas encapsulado para controle)
local function startBlade()
    -- Código original, adaptado para loop controlado
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local enemiesFolder = workspace:WaitForChild("Enemies")

    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local remote = character:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")
    local combo = 1

    local charAddedConn = player.CharacterAdded:Connect(function(char)
        character = char
        root = char:WaitForChild("HumanoidRootPart")
        remote = char:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")
    end)

    while isActive and selectedFruit == "Blade" do
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
            remote:FireServer(direction, combo)
            combo = combo + 1
            if combo > 2 then combo = 1 end
        end

        task.wait()
    end

    charAddedConn:Disconnect()
end

-- Script da Dough Beta (exatamente como fornecido)
local function startDough()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local enemiesFolder = workspace:WaitForChild("Enemies")

    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local function getRemote()
        local hum = char:WaitForChild("Humanoid")
        for _, v in pairs(hum:GetChildren()) do
            if v:IsA("RemoteFunction") then
                return v
            end
        end
    end

    local remote = getRemote()

    local charAddedConn = player.CharacterAdded:Connect(function(c)
        char = c
        root = char:WaitForChild("HumanoidRootPart")
        remote = getRemote()
    end)

    local RANGE = 80

    while isActive and selectedFruit == "dough Beta" do
        local nearest = nil
        local shortest = math.huge

        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local hum = mob:FindFirstChildOfClass("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < shortest and dist <= RANGE then
                    shortest = dist
                    nearest = hrp
                end
            end
        end

        if nearest and remote then
            root.CFrame = CFrame.lookAt(root.Position, nearest.Position)
            pcall(function()
                remote:InvokeServer("TAP")
            end)
        end

        task.wait(0.04)
    end

    charAddedConn:Disconnect()
end

-- Função para iniciar o loop baseado na fruta selecionada
local function startLoop()
    if currentLoop then
        -- Se já tem um loop rodando, para antes de iniciar outro
        stopLoop()
        task.wait(0.1) -- dá tempo para a corrotina antiga terminar
    end
    if not isActive then return end

    if selectedFruit == "Blade" then
        currentLoop = coroutine.wrap(startBlade)
        currentLoop()
    elseif selectedFruit == "dough Beta" then
        currentLoop = coroutine.wrap(startDough)
        currentLoop()
    end
end

-- =============================================
-- Componentes da UI
-- =============================================

-- Dropdown
local Dropdown = Tab:Dropdown({
    Title = "Selecionar Fruta",
    Desc = "Escolha Blade ou Dough Beta",
    Values = { "Blade", "dough Beta" },
    Value = "Blade",
    Callback = function(option)
        selectedFruit = option
        if isActive then
            -- Se o toggle estiver ativo, reinicia o loop com a nova fruta
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
            isActive = true
            startLoop()
        else
            stopLoop()
        end
    end
})

-- Parágrafo informativo
Tab:Paragraph({
    Title = "Aviso",
    Desc = "Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm é etc usse com outros scripts tipo banana hub ó recomendo são hoho hub\nAtive bring mobs para ficar 100% forte.",
    Color = "Orange"
})

-- Notificação final
WindUI:Notify({
    Title = "Pronto!",
    Content = "Selecione a fruta e ative o toggle.",
    Duration = 3,
    Icon = "info"
})
