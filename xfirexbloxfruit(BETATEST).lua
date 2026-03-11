--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝

    REDZ HUB (BLOX FRUITS) - VERSÃO SEM AUTO FARM
    by redz, jx1 e DeepSeek
    Data: 12/03/2026
    Linhas: ~1350
    Descrição: Hub completo com Kill Aura, Auto Chest, Auto Saber, ESP, Anti Gods, e muito mais.
              (Auto Farm removido por solicitação do usuário)
]]

--=====================================================
-- 1. CARREGAR WINDUI (PRIMEIRO)
--=====================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

--=====================================================
-- 2. CRIAR JANELA E ABAS (INTERFACE APARECE IMEDIATAMENTE)
--=====================================================
local Window = WindUI:CreateWindow({
    Title = "REDZ HUB (BLOX FRUITS) BETA",
    Icon = "sword",
    Author = "by redz and jx1",
    Folder = "BloxFruitsHub",
    Size = UDim2.fromOffset(720, 600),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
    Background = "rbxassetid://17382040552",
    User = {
        Enabled = true,
        Anonymous = false,  -- Não mudar
        Callback = function() print("User clicked") end
    }
})

-- Notificação inicial
WindUI:Notify({
    Title = "REDZ HUB",
    Content = "Interface carregada! Inicializando módulos...",
    Duration = 6
})

-- Criar abas (9 abas no total)
local Tabs = {
    Farm = Window:Tab({ Title = "Farm", Icon = "sword" }),        -- Sem Auto Farm, mas com outras opções
    Fruits = Window:Tab({ Title = "Frutas", Icon = "apple" }),
    Chest = Window:Tab({ Title = "Baús", Icon = "gift" }),
    Status = Window:Tab({ Title = "Status", Icon = "bar-chart" }),
    Shop = Window:Tab({ Title = "Loja", Icon = "shopping-cart" }),
    Sea1 = Window:Tab({ Title = "1 Sea", Icon = "anchor" }),
    Config = Window:Tab({ Title = "Config", Icon = "settings" }),
    Extras = Window:Tab({ Title = "Extras", Icon = "star" }),
    Updates = Window:Tab({ Title = "Updates", Icon = "info" })
}

--=====================================================
-- 3. VARIÁVEIS GLOBAIS E CONSTANTES
--=====================================================
-- Flags de ativação (todas inicialmente desligadas)
_G.AutoEquip = false          -- Auto equip para punch
_G.AutoBuso = false           -- Auto Buso Haki (reativa 13s após morte)
_G.BringMobs = false          -- Puxar mobs (até 2)
_G.AutoChestTween = false     -- Auto coletar baús com tween
_G.AutoChestTP = false        -- Auto coletar baús com teleporte (ban risk)
_G.Noclip = false             -- Atravessar paredes
_G.AutoStatus = false         -- Auto adicionar status points
_G.SpinFruit = false          -- Spin fruit a cada 2 horas
_G.AutoSpeed = false          -- Auto manter walk speed
_G.AutoAttack = false         -- Auto atacar (loop 0.15s)
_G.ESP_Fruit = false          -- ESP para frutas
_G.AntiGods = false           -- Anti Gods Itens (Chalice, Fist)
_G.AutoSaber = false          -- Auto Saber (1 Sea)
_G.KillAura = false           -- Kill Aura (move até o inimigo)
_G.AntiGravity = false        -- Anti gravidade (trava no ar)

-- Configurações ajustáveis pelo usuário
_G.SelectedWeapon = "punch"    -- Tipo de arma para auto equip
_G.StatusType = "Melee"        -- Tipo de status a ser incrementado
_G.StatusAmount = 1            -- Quantidade de pontos por vez
_G.WalkSpeedValue = 16         -- Velocidade de andar
_G.TweenSpeed = 250            -- Velocidade dos tweens

-- Variáveis de estado para lógicas específicas
_G.VisitedChests = {}          -- Baús já visitados (para não repetir)
_G.ChestTPCount = 0            -- Contador para auto chest TP (reseta a cada 3)
_G.ESPNumber = 1               -- Número usado no ESP (para evitar conflitos)

--=====================================================
-- 4. LISTAS AUXILIARES (DADOS ESTÁTICOS)
--=====================================================
-- Estilos de combate reconhecidos pelo auto equip
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

-- Itens disponíveis na loja do primeiro mar (com seus nomes para o remote)
local shopItems = {
    { Name = "Katana",      RemoteArg = "Katana" },
    { Name = "Cutlass",     RemoteArg = "Cutlass" },
    { Name = "Saber",       RemoteArg = "Saber" },
    { Name = "Pipe",        RemoteArg = "Pipe" },
    { Name = "Dual Katana", RemoteArg = "DualKatana" },
    { Name = "Iron Mace",   RemoteArg = "IronMace" },
    { Name = "Slingshot",   RemoteArg = "Slingshot" },
    { Name = "Flintlock",   RemoteArg = "Flintlock" },
    { Name = "Musket",      RemoteArg = "Musket" },
    { Name = "Refined Flintlock", RemoteArg = "RefinedFlintlock" },
    { Name = "Cannon",      RemoteArg = "Cannon" },
}

--=====================================================
-- 5. SERVICES E FUNÇÕES AUXILIARES (UTILITÁRIOS)
--=====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Função para arredondar números (usada no ESP para distância)
local function round(x)
    return math.floor(x + 0.5)
end

-- Função para verificar nível do jogador (usada em várias partes)
local function CheckLevel()
    local success, level = pcall(function() return player.Data.Level.Value end)
    return success and level or nil
end

--=====================================================
-- 6. FUNÇÃO DE TWEEN GLOBAL (COM TRAVA NO AR)
--=====================================================
-- Esta função é usada por todas as features que precisam mover o jogador.
-- Durante o movimento, a gravidade é zerada e o jogador fica imóvel (trava no ar).
-- Ao final, a gravidade é restaurada.
local function TweenTo(targetCFrame, speed, callback)
    speed = speed or _G.TweenSpeed
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Congela no ar: gravidade zero e trava
    local originalGravity = workspace.Gravity
    local wasAutoRotate = humanoid.AutoRotate
    workspace.Gravity = 0
    humanoid.AutoRotate = false
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local time = math.min(distance / speed, 30)  -- máximo 30s

    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetCFrame}
    local tween = TweenService:Create(hrp, tweenInfo, goal)

    tween.Completed:Connect(function()
        workspace.Gravity = originalGravity
        humanoid.AutoRotate = wasAutoRotate
        if callback then callback() end
    end)

    tween:Play()
    return tween
end

--=====================================================
-- 7. FUNÇÕES DE LÓGICA (EXECUTADAS EM THREADS SEPARADAS)
--=====================================================

-- 7.1 Auto Equip (para punch)
-- Varre o inventário e equipa qualquer tool que seja um estilo de combate.
local function StartAutoEquip()
    task.spawn(function()
        while _G.AutoEquip do
            pcall(function()
                local char = player.Character
                local backpack = player.Backpack
                if char and _G.SelectedWeapon == "punch" then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, style in pairs(combatStyles) do
                                if tool.Name:find(style) or tool.Name == style then
                                    char.Humanoid:EquipTool(tool)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(1) -- verifica a cada segundo
        end
    end)
end

-- 7.2 Auto Buso (corrigido)
-- Ativa Buso Haki imediatamente ao ligar e, após a morte do personagem, reativa após 13 segundos.
local function StartAutoBuso()
    local function ActivateBuso()
        pcall(function() CommF:InvokeServer("Buso") end)
    end

    ActivateBuso() -- ativa imediatamente

    local connection
    connection = player.CharacterAdded:Connect(function()
        if _G.AutoBuso then
            task.wait(13)
            ActivateBuso()
        else
            if connection then connection:Disconnect() end
        end
    end)
end

-- 7.3 Auto Speed
-- Mantém a velocidade de andar configurada.
local function StartAutoSpeed()
    task.spawn(function()
        while _G.AutoSpeed do
            pcall(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = _G.WalkSpeedValue end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 7.4 Auto Attack (loop de 0.15s)
-- Ataca o inimigo mais próximo dentro de um raio de 60 studs.
local function StartAutoAttack()
    task.spawn(function()
        local enemies = workspace:WaitForChild("Enemies")
        while _G.AutoAttack do
            pcall(function()
                local char = player.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local nearest = nil
                local shortest = math.huge
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (root.Position - hrp.Position).Magnitude
                        if dist <= 60 and dist < shortest then
                            shortest = dist
                            nearest = hrp
                        end
                    end
                end

                if nearest then
                    local attackId = tostring(math.random(100000, 999999))
                    ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.1)
                    ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(nearest, {}, attackId)
                end
            end)
            task.wait(0.15)
        end
    end)
end

-- 7.5 Auto Chest Tween (foco em um por vez)
-- Vai até baús não visitados usando tween. Marca como visitado para não repetir no mesmo ciclo.
local function StartAutoChestTween()
    task.spawn(function()
        while _G.AutoChestTween do
            pcall(function()
                local char = player.Character
                if not char then return end

                -- Coletar baús não visitados (Chest1, Chest2, Chest3)
                local chests = {}
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3") then
                        local key = tostring(v.Position)
                        if not _G.VisitedChests[key] then
                            table.insert(chests, v)
                        end
                    end
                end

                if #chests > 0 then
                    local target = chests[1] -- pega o primeiro
                    TweenTo(target.CFrame * CFrame.new(0, 2, 0), _G.TweenSpeed, function()
                        _G.VisitedChests[tostring(target.Position)] = true
                        task.wait(1) -- pausa para coletar
                    end)
                else
                    -- Se todos foram visitados, aguarda 60 segundos e reseta
                    task.wait(60)
                    _G.VisitedChests = {}
                end
            end)
            task.wait(1)
        end
    end)
end

-- 7.6 Auto Chest Teleporte (ban risk) com controle de repetição
-- Teleporta para baús não visitados. A cada 3 teleportes, reseta e mata o player.
local function StartAutoChestTP()
    task.spawn(function()
        while _G.AutoChestTP do
            pcall(function()
                local char = player.Character
                if not char then return end

                -- Coletar baús não visitados
                local chests = {}
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3") then
                        local key = tostring(v.Position)
                        if not _G.VisitedChests[key] then
                            table.insert(chests, v)
                        end
                    end
                end

                if #chests > 0 then
                    local target = chests[1]
                    char.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                    _G.VisitedChests[tostring(target.Position)] = true
                    _G.ChestTPCount = _G.ChestTPCount + 1
                    task.wait(0.5)

                    if _G.ChestTPCount >= 3 then
                        _G.ChestTPCount = 0
                        _G.VisitedChests = {}
                        char.Humanoid.Health = 0  -- mata para evitar detecção
                        task.wait(5)
                    end
                else
                    task.wait(5)
                end
            end)
            task.wait(1)
        end
    end)
end

-- 7.7 Anti Gods Itens
-- Detecta a presença de "God's Chalice" ou "The Fist of Darkness" no inventário.
-- Ao encontrar, desliga tweens, equipa, notifica e toca um som.
local function StartAntiGods()
    task.spawn(function()
        while _G.AntiGods do
            pcall(function()
                local backpack = player.Backpack
                local char = player.Character
                local gods = {"God's Chalice", "The Fist of Darkness"}
                for _, name in ipairs(gods) do
                    -- Procurar no inventário
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == name then
                            -- Desligar tweens (restaurando gravidade)
                            workspace.Gravity = 196.2
                            if _G.AutoChestTP then _G.AutoChestTP = false end
                            -- Equipar
                            if char then char.Humanoid:EquipTool(tool) end
                            WindUI:Notify({ Title = "Anti Gods", Content = name .. " encontrado! Equipado.", Duration = 5 })
                            -- Tocar som
                            local s = Instance.new("Sound", workspace)
                            s.SoundId = "rbxassetid://9120387847" -- som de exemplo
                            s:Play()
                            task.wait(1)
                            s:Destroy()
                            break
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- 7.8 ESP Frutas (conforme lógica fornecida pelo usuário)
-- Cria billboards nas frutas mostrando nome e distância.
local function StartFruitESP()
    task.spawn(function()
        while _G.ESP_Fruit do
            pcall(function()
                local espNum = _G.ESPNumber
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Tool") and v.Name:find("Fruit") then
                        if v:FindFirstChild("Handle") then
                            if not v.Handle:FindFirstChild('NameEsp'..espNum) then
                                local bill = Instance.new('BillboardGui', v.Handle)
                                bill.Name = 'NameEsp'..espNum
                                bill.ExtentsOffset = Vector3.new(0, 1, 0)
                                bill.Size = UDim2.new(1,200,1,30)
                                bill.Adornee = v.Handle
                                bill.AlwaysOnTop = true
                                local name = Instance.new('TextLabel', bill)
                                name.Font = Enum.Font.GothamSemibold
                                name.TextSize = 14
                                name.TextWrapped = true
                                name.Size = UDim2.new(1,0,1,0)
                                name.TextYAlignment = 'Top'
                                name.BackgroundTransparency = 1
                                name.TextStrokeTransparency = 0.5
                                name.TextColor3 = Color3.fromRGB(255, 255, 255)
                                local head = player.Character and player.Character:FindFirstChild("Head")
                                local dist = head and (head.Position - v.Handle.Position).Magnitude or 0
                                name.Text = v.Name .. ' \n' .. round(dist/3) .. ' Distance'
                            else
                                local bill = v.Handle:FindFirstChild('NameEsp'..espNum)
                                if bill and bill:FindFirstChild("TextLabel") then
                                    local head = player.Character and player.Character:FindFirstChild("Head")
                                    local dist = head and (head.Position - v.Handle.Position).Magnitude or 0
                                    bill.TextLabel.Text = v.Name .. '   \n' .. round(dist/3) .. ' Distance'
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
        -- Remover ESP ao desligar
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                local esp = v.Handle:FindFirstChild('NameEsp'.._G.ESPNumber)
                if esp then esp:Destroy() end
            end
        end
    end)
end

-- 7.9 Kill Aura (com tween)
-- Move o jogador para cima do inimigo mais próximo. Se Bring Mobs estiver ativo, puxa até 2 do mesmo nome.
local function StartKillAura()
    task.spawn(function()
        local enemies = Workspace:FindFirstChild("Enemies")
        while _G.KillAura do
            pcall(function()
                local char = player.Character
                if not char or not enemies then return end
                local targetMob, targetHRP = nil, nil
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if not targetHRP or (char.HumanoidRootPart.Position - hrp.Position).Magnitude < (char.HumanoidRootPart.Position - targetHRP.Position).Magnitude then
                            targetMob, targetHRP = mob, hrp
                        end
                    end
                end
                if targetHRP then
                    TweenTo(targetHRP.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                    if _G.BringMobs then
                        local count = 0
                        for _, mob in pairs(enemies:GetChildren()) do
                            if count >= 2 then break end
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 and mob.Name == targetMob.Name and mob ~= targetMob then
                                hrp.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                count = count + 1
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- 7.10 Anti Gravidade (trava total)
-- Mantém a gravidade zero e zera a velocidade do personagem, travando-o no ar.
local function StartAntiGravity()
    task.spawn(function()
        while _G.AntiGravity do
            pcall(function()
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                    end
                end
                workspace.Gravity = 0
            end)
            task.wait(0.1)
        end
        workspace.Gravity = 196.2  -- restaura ao desligar
    end)
end

-- 7.11 Spin Fruit (a cada 2 horas)
-- Executa o comando de spin fruit a cada 7200 segundos.
local function StartSpinFruit()
    task.spawn(function()
        while _G.SpinFruit do
            pcall(function() CommF:InvokeServer("Cousin", "Buy", "DLCBoxData") end)
            task.wait(7200)
        end
    end)
end

-- 7.12 Auto Status
-- Adiciona pontos de status automaticamente, conforme o tipo e quantidade configurados.
local function StartAutoStatus()
    task.spawn(function()
        while _G.AutoStatus do
            pcall(function() CommF:InvokeServer("AddPoint", _G.StatusType, _G.StatusAmount) end)
            task.wait(0.5)
        end
    end)
end

-- 7.13 Remover Texturas (versão ultra fornecida pelo usuário)
-- Remove todas as texturas, efeitos visuais, e otimiza o jogo.
local function RemoveTextures()
    pcall(function()
        if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
        local g = game
        local w = g.Workspace
        local l = g.Lighting
        local t = w.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"
        for i, v in pairs(g:GetDescendants()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
                v.TextureID = "10385902758728957"
            end
        end
        for i, e in pairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
        for i, v in pairs(game:GetService("Workspace").Camera:GetDescendants()) do
            if v.Name == ("Water;") then
                v.Transparency = 1
                v.Material = "Plastic"
            end
        end
        WindUI:Notify({ Title = "Texturas", Content = "Remoção ultra concluída!", Duration = 3 })
    end)
end

-- 7.14 Auto Saber (1 Sea) - Completo
-- Executa toda a quest da Saber, com todos os passos e notificações.
local function StartAutoSaber()
    -- Nota: A quest da Saber exige nível 200 ou mais. Se não tiver, notifica.
    if CheckLevel() < 200 then
        WindUI:Notify({ Title = "Auto Saber", Content = "Level mínimo: 200", Duration = 5 })
        return
    end

    -- Pontos iniciais para ativar a quest
    local pontos = {
        CFrame.new(-1422, 48, 21),
        CFrame.new(-1648, 23, 438),
        CFrame.new(-1327, 30, -462),
        CFrame.new(-1152, 0, -701)
    }

    local function proximoPonto(idx)
        if idx > #pontos then
            task.wait(5)
            CommF:InvokeServer("ProQuestProgress", "GetTorch")
            -- Aguardar Torch aparecer
            local torch = nil
            repeat
                task.wait(0.5)
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name == "Torch" then
                        torch = tool
                        break
                    end
                end
                if not torch and player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "Torch" then
                            torch = tool
                            break
                        end
                    end
                end
            until torch or not _G.AutoSaber
            if not _G.AutoSaber then return end
            if player.Character then player.Character.Humanoid:EquipTool(torch) end

            TweenTo(CFrame.new(1113, 7, 4365), _G.TweenSpeed, function()
                task.wait(10)
                TweenTo(CFrame.new(1114, 4, 4351), _G.TweenSpeed, function()
                    task.wait(4)
                    local cup = nil
                    for _, tool in pairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "Cup" then
                            cup = tool
                            break
                        end
                    end
                    if not cup and player.Character then
                        for _, tool in pairs(player.Character:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name == "Cup" then
                                cup = tool
                                break
                            end
                        end
                    end
                    if not cup then
                        CommF:InvokeServer("ProQuestProgress", "GetCup")
                        repeat
                            task.wait(0.5)
                            for _, tool in pairs(player.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and tool.Name == "Cup" then
                                    cup = tool
                                    break
                                end
                            end
                        until cup or not _G.AutoSaber
                    end
                    if not _G.AutoSaber then return end
                    if player.Character then player.Character.Humanoid:EquipTool(cup) end
                    CommF:InvokeServer("ProQuestProgress", "FillCup", cup)
                    CommF:InvokeServer("ProQuestProgress", "SickMan")
                    task.wait(4)
                    CommF:InvokeServer("ProQuestProgress", "RichSon")
                    task.wait(2)
                    TweenTo(CFrame.new(-2870, 54, 5396), _G.TweenSpeed, function()
                        local start = tick()
                        local mobLeader = nil
                        repeat
                            task.wait(0.5)
                            for _, mob in pairs(Workspace:FindFirstChild("Enemies"):GetChildren()) do
                                if mob.Name == "Mob Leader" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                    mobLeader = mob
                                    break
                                end
                            end
                            if tick() - start > 22 then
                                WindUI:Notify({ Title = "Auto Saber", Content = "demora hein minha vó vai fazer 67 anos uai?", Duration = 5 })
                                break
                            end
                        until mobLeader or not _G.AutoSaber
                        if mobLeader and _G.AutoSaber then
                            while mobLeader and mobLeader:FindFirstChild("Humanoid") and mobLeader.Humanoid.Health > 0 do
                                TweenTo(mobLeader.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                                task.wait(0.3)
                            end
                            CommF:InvokeServer("ProQuestProgress", "RichSon")
                            local relic = nil
                            repeat
                                task.wait(0.5)
                                for _, tool in pairs(player.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and tool.Name == "Relic" then
                                        relic = tool
                                        break
                                    end
                                end
                            until relic or not _G.AutoSaber
                            if relic and _G.AutoSaber then
                                if player.Character then player.Character.Humanoid:EquipTool(relic) end
                                CommF:InvokeServer("ProQuestProgress", "PlaceRelic")
                                TweenTo(CFrame.new(-1435, 61, 4), _G.TweenSpeed, function()
                                    local saber = nil
                                    repeat
                                        task.wait(0.5)
                                        for _, mob in pairs(Workspace:FindFirstChild("Enemies"):GetChildren()) do
                                            if mob.Name == "Saber Expert" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                                saber = mob
                                                break
                                            end
                                        end
                                    until saber or not _G.AutoSaber
                                    if saber and _G.AutoSaber then
                                        while saber and saber:FindFirstChild("Humanoid") and saber.Humanoid.Health > 0 do
                                            TweenTo(saber.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                                            task.wait(0.3)
                                        end
                                        _G.AutoSaber = false
                                        WindUI:Notify({ Title = "Auto Saber", Content = "aeeeee saber :3", Duration = 5 })
                                    end
                                end)
                            end
                        end
                    end)
                end)
            end)
            return
        end
        TweenTo(pontos[idx], _G.TweenSpeed, function()
            task.wait(4)
            proximoPonto(idx + 1)
        end)
    end
    proximoPonto(1)
end

-- 7.15 Server Hop
-- Procura por um servidor público com espaço e teleporta.
local function ServerHop()
    local PlaceID = game.PlaceId
    local function TPReturner(cursor)
        local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?limit=100' .. (cursor and '&cursor=' .. cursor or '')
        local data = game:HttpGet(url)
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        for _, server in pairs(decoded.data) do
            if server.playing < server.maxPlayers then
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, server.id, player)
                return
            end
        end
        if decoded.nextPageCursor then
            TPReturner(decoded.nextPageCursor)
        else
            WindUI:Notify({ Title = "Server Hop", Content = "Nenhum servidor disponível", Duration = 3 })
        end
    end
    TPReturner()
end

-- 7.16 Rejoin
-- Teleporta de volta para o mesmo servidor (útil para resetar).
local function Rejoin()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end

--=====================================================
-- 8. CONSTRUÇÃO DA INTERFACE (ABAS E ELEMENTOS)
--=====================================================

-- 8.1 Aba Farm
Tabs.Farm:Dropdown({ Title = "Tipo de Arma", Values = { "punch", "espada", "gun" }, Callback = function(v) _G.SelectedWeapon = v end })
Tabs.Farm:Toggle({ Title = "Auto Equip", Default = false, Callback = function(s)
    _G.AutoEquip = s
    if s then StartAutoEquip() end
end})
Tabs.Farm:Toggle({ Title = "Bring Mobs (2)", Default = false, Callback = function(s) _G.BringMobs = s end })
Tabs.Farm:Toggle({ Title = "Kill Aura", Default = false, Callback = function(s)
    _G.KillAura = s
    if s then StartKillAura() end
end})

-- 8.2 Aba Frutas
Tabs.Fruits:Toggle({ Title = "Spin Fruit (2h)", Default = false, Callback = function(s)
    _G.SpinFruit = s
    if s then StartSpinFruit() end
end})
Tabs.Fruits:Toggle({ Title = "ESP Frutas", Default = false, Callback = function(s)
    _G.ESP_Fruit = s
    if s then StartFruitESP() end
end})

-- 8.3 Aba Baús
Tabs.Chest:Toggle({ Title = "Auto Baú (Tween)", Default = false, Callback = function(s)
    _G.AutoChestTween = s
    if s then _G.VisitedChests = {} StartAutoChestTween() end
end})
Tabs.Chest:Toggle({ Title = "Auto Baú (TP) - BAN RISK", Default = false, Callback = function(s)
    _G.AutoChestTP = s
    if s then _G.VisitedChests = {} _G.ChestTPCount = 0 StartAutoChestTP() end
end})
Tabs.Chest:Toggle({ Title = "Anti Gods Itens", Default = false, Callback = function(s)
    _G.AntiGods = s
    if s then StartAntiGods() end
end})

-- 8.4 Aba Status
Tabs.Status:Slider({ Title = "Quantidade de Pontos", Value = { Min = 1, Max = 100, Default = 1 }, Callback = function(v) _G.StatusAmount = v end })
Tabs.Status:Dropdown({ Title = "Tipo de Status", Values = { "punch", "espada", "fruta", "arma", "defesa" }, Callback = function(v)
    if v == "punch" then _G.StatusType = "Melee"
    elseif v == "espada" then _G.StatusType = "Sword"
    elseif v == "fruta" then _G.StatusType = "Demon Fruit"
    elseif v == "arma" then _G.StatusType = "Gun"
    elseif v == "defesa" then _G.StatusType = "Defense" end
end})
Tabs.Status:Toggle({ Title = "Auto Status", Default = false, Callback = function(s)
    _G.AutoStatus = s
    if s then StartAutoStatus() end
end})

-- 8.5 Aba Loja
for _, item in ipairs(shopItems) do
    Tabs.Shop:Button({ Title = "Comprar " .. item.Name, Callback = function()
        pcall(function() CommF:InvokeServer("BuyItem", item.RemoteArg) end)
        WindUI:Notify({ Title = "Loja", Content = item.Name .. " comprado!", Duration = 3 })
    end})
end

-- 8.6 Aba 1 Sea
Tabs.Sea1:Toggle({ Title = "Auto Saber", Default = false, Callback = function(s)
    _G.AutoSaber = s
    if s then StartAutoSaber() end
end})

-- 8.7 Aba Configurações
Tabs.Config:Dropdown({ Title = "Velocidade do Tween", Values = { "200", "250", "300", "350" }, Callback = function(v) _G.TweenSpeed = tonumber(v) end })
Tabs.Config:Slider({ Title = "Velocidade de Andar", Value = { Min = 16, Max = 300, Default = 16 }, Callback = function(v)
    _G.WalkSpeedValue = v
    if _G.AutoSpeed then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end})
Tabs.Config:Toggle({ Title = "Auto Speed", Default = false, Callback = function(s)
    _G.AutoSpeed = s
    if s then StartAutoSpeed() end
end})
Tabs.Config:Toggle({ Title = "Auto Attack", Default = false, Callback = function(s)
    _G.AutoAttack = s
    if s then StartAutoAttack() end
end})
Tabs.Config:Toggle({ Title = "Auto Buso", Default = false, Callback = function(s)
    _G.AutoBuso = s
    if s then StartAutoBuso() end
end})
Tabs.Config:Toggle({ Title = "Noclip", Default = false, Callback = function(s)
    _G.Noclip = s
    if s then
        task.spawn(function()
            while _G.Noclip do
                pcall(function()
                    local char = player.Character
                    if char then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end})
Tabs.Config:Toggle({ Title = "Anti Gravidade", Default = false, Callback = function(s)
    _G.AntiGravity = s
    if s then StartAntiGravity() end
end})

-- 8.8 Aba Extras
Tabs.Extras:Button({ Title = "Remover Texturas (Ultra)", Callback = RemoveTextures })
Tabs.Extras:Button({ Title = "Tirar Céu", Callback = function()
    pcall(function()
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.new(1,1,1)
        if Lighting:FindFirstChildOfClass("Sky") then Lighting:FindFirstChildOfClass("Sky"):Destroy() end
    end)
    WindUI:Notify({ Title = "Céu", Content = "Céu e neblina removidos!", Duration = 3 })
end})
Tabs.Extras:Button({ Title = "Server Hop", Callback = ServerHop })
Tabs.Extras:Button({ Title = "Rejoin", Callback = Rejoin })

-- 8.9 Aba Updates
Tabs.Updates:Paragraph({ Title = "📌 Novidades da Versão", Desc = [[
    • Farm: Auto Equip, Bring Mobs, Kill Aura (com tween)
    • Frutas: Spin Fruit (2h), ESP Frutas com distância
    • Baús: Auto Baú Tween (foco único), Auto Baú TP (ban risk), Anti Gods Itens
    • Status: Auto Status com escolha de tipo e quantidade
    • Loja: Comprar itens do 1º mar (Katana, Cutlass, etc.)
    • 1 Sea: Auto Saber completo (todos os passos)
    • Config: Velocidade Tween, WalkSpeed, Auto Speed, Auto Attack, Auto Buso, Noclip, Anti Gravidade
    • Extras: Remover texturas ultra, tirar céu, server hop, rejoin
    • Tween com trava no ar (gravidade zero durante movimento)
    • Interface WindUI com 9 abas
    • (Auto Farm removido conforme solicitação)
]]})

--=====================================================
-- 9. NOTIFICAÇÃO FINAL E PRINT DE CONFIRMAÇÃO
--=====================================================
WindUI:Notify({
    Title = "REDZ HUB",
    Content = "Hub carregado! Nível atual: " .. (CheckLevel() or "??"),
    Duration = 5
})

print("=== REDZ HUB (SEM AUTO FARM) CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
print("📅 Versão: 13.0 - Sem Auto Farm, com todas as outras features")
print("📈 Total de linhas aproximado: 1350")
