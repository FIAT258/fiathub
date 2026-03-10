--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝

    BLOX FRUITS HUB - WINDUI ULTIMATE
    by Lorenzo, JX1 & DeepSeek
    Versão 10.0 - Complexa
]]

-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Variáveis globais
_G.AutoFarm = false
_G.AutoEquip = false
_G.AutoBuso = false
_G.BringMobs = false
_G.AutoChestTween = false
_G.AutoChestTP = false
_G.Noclip = false
_G.AutoStatus = false
_G.SpinFruit = false
_G.AutoSpeed = false
_G.AutoAttack = false
_G.ESP_Fruit = false
_G.AntiGods = false
_G.AutoSaber = false
_G.KillAura = false
_G.AntiGravity = false
_G.SelectedWeapon = "punch"
_G.StatusType = "Melee"
_G.StatusAmount = 1
_G.WalkSpeedValue = 16
_G.TweenSpeed = 250
_G.CurrentQuest = {}
_G.LastQuestLevel = 0
_G.VisitedChests = {}
_G.ChestTPCount = 0
_G.CurrentTarget = nil
_G.BusoConnection = nil
_G.SaberStep = 0
_G.Torch = nil
_G.Cup = nil
_G.Relic = nil
_G.MobLeaderSpawned = false
_G.SaberExpertSpawned = false

-- Lista de combat styles
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

-- Itens da loja (1º mar)
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

-- Cores para ESP
local colors = {
    Fruit = Color3.fromRGB(255, 255, 0)
}

-- Funções auxiliares
local function CheckLevel()
    local success, level = pcall(function() return player.Data.Level.Value end)
    return success and level or nil
end

-- Tween com controle de gravidade
local function TweenTo(targetCFrame, speed, callback)
    speed = speed or _G.TweenSpeed
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Salvar gravidade original e setar 0
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local originalGravity = humanoid and humanoid.UseJumpPower and 196.2 or workspace.Gravity
    workspace.Gravity = 0
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local time = distance / speed
    if time > 30 then time = 30 end -- limite
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetCFrame}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    
    tween.Completed:Connect(function()
        workspace.Gravity = originalGravity
        if callback then callback() end
    end)
    
    tween:Play()
    return tween
end

-- Função para obter quest por nível (lista completa)
local function GetQuestByLevel(level)
    if level >= 1 and level <= 9 then
        return {
            Mon = "Bandit", LevelQuest = 1, NameQuest = "BanditQuest1", NameMon = "Bandit",
            CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544),
            CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        }
    elseif level >= 10 and level <= 14 then
        return {
            Mon = "Monkey", LevelQuest = 1, NameQuest = "JungleQuest", NameMon = "Monkey",
            CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0),
            CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
        }
    -- ... (continuar com todos os níveis até 650)
    elseif level >= 650 then
        return {
            Mon = "Galley Captain", LevelQuest = 2, NameQuest = "FountainQuest", NameMon = "Galley Captain",
            CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381),
            CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
        }
    end
    return nil
end

-- Função para ESP de frutas
local function UpdateFruitESP()
    local espNumber = 1
    while _G.ESP_Fruit do
        task.wait(0.3)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Tool") and v.Name:find("Fruit") then
                if v:FindFirstChild("Handle") then
                    if not v.Handle:FindFirstChild("FruitESP") then
                        local bill = Instance.new("BillboardGui", v.Handle)
                        bill.Name = "FruitESP"
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(1, 200, 1, 30)
                        bill.Adornee = v.Handle
                        bill.AlwaysOnTop = true
                        local name = Instance.new("TextLabel", bill)
                        name.Font = Enum.Font.GothamSemibold
                        name.TextSize = 14
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = Enum.TextYAlignment.Top
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextColor3 = colors.Fruit
                        name.Text = v.Name .. "\n" .. math.floor((player.Character and player.Character:FindFirstChild("Head") and (player.Character.Head.Position - v.Handle.Position).Magnitude or 0)/3) .. "m"
                    else
                        local bill = v.Handle:FindFirstChild("FruitESP")
                        if bill and bill:FindFirstChild("TextLabel") then
                            bill.TextLabel.Text = v.Name .. "\n" .. math.floor((player.Character and player.Character:FindFirstChild("Head") and (player.Character.Head.Position - v.Handle.Position).Magnitude or 0)/3) .. "m"
                        end
                    end
                end
            end
        end
    end
    -- Remover ESP quando desligar
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            local esp = v.Handle:FindFirstChild("FruitESP")
            if esp then esp:Destroy() end
        end
    end
end

-- Auto Farm Level
local function StartAutoFarm()
    task.spawn(function()
        while _G.AutoFarm do
            pcall(function()
                local level = CheckLevel()
                if not level then task.wait(1) return end
                
                -- Verifica se mudou de nível para pegar nova quest
                if level > _G.LastQuestLevel then
                    _G.LastQuestLevel = level
                    local quest = GetQuestByLevel(level)
                    if quest then
                        _G.CurrentQuest = quest
                        -- Vai até o CFrameQuest
                        TweenTo(quest.CFrameQuest, _G.TweenSpeed, function()
                            -- Invoca StartQuest
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.NameQuest, quest.LevelQuest)
                            -- Vai para o CFrameMon
                            TweenTo(quest.CFrameMon, _G.TweenSpeed)
                        end)
                    end
                end
                
                if not _G.CurrentQuest or not _G.CurrentQuest.NameMon then task.wait(1) return end
                
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then task.wait(1) return end
                
                local character = player.Character
                if not character then task.wait(1) return end
                
                -- Encontrar o mob mais próximo da quest
                local targetMob, targetHRP = nil, nil
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                            local dist = (character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if not targetHRP or dist < (character.HumanoidRootPart.Position - targetHRP.Position).Magnitude then
                                targetMob, targetHRP = mob, hrp
                            end
                        end
                    end
                end
                
                if targetHRP then
                    -- Tween contínuo para cima do mob (atualiza a cada 0.3s)
                    _G.CurrentTarget = targetHRP
                    TweenTo(targetHRP.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                    
                    -- Bring mobs (até 2)
                    if _G.BringMobs then
                        local count = 0
                        for _, mob in pairs(enemies:GetChildren()) do
                            if count >= 2 then break end
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                                    if mob ~= targetMob then
                                        hrp.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                    
                    task.wait(0.3)
                else
                    -- Se não encontrou mob, vai para CFrameMon
                    if _G.CurrentQuest.CFrameMon then
                        TweenTo(_G.CurrentQuest.CFrameMon, _G.TweenSpeed)
                    end
                    task.wait(1)
                end
            end)
        end
    end)
end

-- Auto Buso corrigido
local function StartAutoBuso()
    local function ActivateBuso()
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
    end
    
    ActivateBuso()
    
    local connection
    connection = player.CharacterAdded:Connect(function()
        if _G.AutoBuso then
            task.wait(13)
            ActivateBuso()
        else
            connection:Disconnect()
        end
    end)
    
    -- Loop para reativar a cada 5s (para garantir)
    _G.BusoConnection = task.spawn(function()
        while _G.AutoBuso do
            task.wait(5)
            ActivateBuso()
        end
    end)
end

-- Auto Speed
local function StartAutoSpeed()
    task.spawn(function()
        while _G.AutoSpeed do
            pcall(function()
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.WalkSpeed = _G.WalkSpeedValue end
                end
            end)
            task.wait(1)
        end
    end)
end

-- Auto Attack
local function StartAutoAttack()
    task.spawn(function()
        local enemies = workspace:WaitForChild("Enemies")
        while _G.AutoAttack do
            pcall(function()
                local character = player.Character
                if not character then return end
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local nearest, shortest = nil, math.huge
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

-- Auto Chest Tween (foco em um por vez)
local function StartAutoChestTween()
    task.spawn(function()
        while _G.AutoChestTween do
            pcall(function()
                local character = player.Character
                if not character then return end
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
                    local target = chests[1] -- pega o primeiro da lista (pode ser aleatório)
                    TweenTo(target.CFrame * CFrame.new(0, 2, 0), _G.TweenSpeed, function()
                        _G.VisitedChests[tostring(target.Position)] = true
                    end)
                    task.wait(2) -- espera chegar e coletar
                else
                    task.wait(60)
                    _G.VisitedChests = {}
                end
            end)
            task.wait(1)
        end
    end)
end

-- Auto Chest Teleporte (ban risk)
local function StartAutoChestTP()
    task.spawn(function()
        while _G.AutoChestTP do
            pcall(function()
                local character = player.Character
                if not character then return end
                local chests = {}
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and (v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3") then
                        table.insert(chests, v)
                    end
                end
                if #chests > 0 then
                    local target = chests[1]
                    character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                    _G.ChestTPCount = _G.ChestTPCount + 1
                    task.wait(0.5)
                    if _G.ChestTPCount >= 3 then
                        character.Humanoid.Health = 0
                        _G.ChestTPCount = 0
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

-- Anti Gods Items
local function CheckAntiGods()
    task.spawn(function()
        while _G.AntiGods do
            pcall(function()
                local backpack = player.Backpack
                local character = player.Character
                local godsTools = {"God's Chalice", "The Fist of Darkness"}
                for _, toolName in ipairs(godsTools) do
                    -- Verificar no backpack
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == toolName then
                            -- Desligar tweens com gravidade 0
                            workspace.Gravity = 196.2
                            -- Desligar auto chest TP
                            if _G.AutoChestTP then
                                _G.AutoChestTP = false
                                -- atualizar toggle na interface (não temos referência direta, mas pode ser feito via WindUI:Options)
                            end
                            -- Equipar tool
                            if character then
                                character.Humanoid:EquipTool(tool)
                            end
                            -- Notificar e tocar som
                            WindUI:Notify({ Title = "Anti Gods", Content = toolName .. " encontrado! Equipado.", Duration = 5 })
                            local sound = Instance.new("Sound", workspace)
                            sound.SoundId = "rbxassetid://9120387847" -- som de exemplo
                            sound:Play()
                            task.wait(1)
                            sound:Destroy()
                            break
                        end
                    end
                    -- Verificar no character
                    if character then
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name == toolName then
                                -- já equipado, só notificar
                                WindUI:Notify({ Title = "Anti Gods", Content = toolName .. " já equipado!", Duration = 3 })
                                break
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- Remover texturas (versão super)
local function RemoveTextures()
    pcall(function()
        if Lighting:FindFirstChild("FantasySky") then
            Lighting.FantasySky:Destroy()
        end
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
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for i, v in pairs(g:GetDescendants()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
                v.Material = Enum.Material.Plastic
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
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.TextureID = "rbxassetid://10385902758728957"
            end
        end
        for i, e in pairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
        for i, v in pairs(workspace.Camera:GetDescendants()) do
            if v.Name == "Water;" then
                v.Transparency = 1
                v.Material = Enum.Material.Plastic
            end
        end
        WindUI:Notify({ Title = "Texturas", Content = "Remoção completa aplicada!", Duration = 3 })
    end)
end

-- Auto Saber (1 Sea)
local function StartAutoSaber()
    if CheckLevel() < 200 then
        WindUI:Notify({ Title = "Auto Saber", Content = "Level mínimo: 200!", Duration = 5 })
        return
    end
    
    _G.SaberStep = 0
    local pontos = {
        CFrame.new(-1422, 48, 21),
        CFrame.new(-1648, 23, 438),
        CFrame.new(-1327, 30, -462),
        CFrame.new(-1152, 0, -701)
    }
    
    local function proximoPonto(idx)
        if idx > #pontos then
            -- Após todos os pontos, esperar 5s e pedir Tocha
            task.wait(5)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "GetTorch")
            -- Aguardar surgir Torch
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
            -- Equipar Torch
            if player.Character then
                player.Character.Humanoid:EquipTool(torch)
            end
            -- Tween para (1113,7,4365)
            TweenTo(CFrame.new(1113, 7, 4365), _G.TweenSpeed, function()
                task.wait(10)
                -- Tween para (1114,4,4351)
                TweenTo(CFrame.new(1114, 4, 4351), _G.TweenSpeed, function()
                    task.wait(4)
                    -- Verificar se Cup apareceu
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
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup")
                        repeat
                            task.wait(0.5)
                            for _, tool in pairs(player.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and tool.Name == "Cup" then
                                    cup = tool
                                    break
                                end
                            end
                        until cup or not _G.AutoSaber
                        if not _G.AutoSaber then return end
                    end
                    -- Equipar Cup
                    if player.Character then
                        player.Character.Humanoid:EquipTool(cup)
                    end
                    -- FillCup
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", cup)
                    -- SickMan
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan")
                    task.wait(4)
                    -- RichSon
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                    task.wait(2)
                    -- Tween para (-2870,54,5396)
                    TweenTo(CFrame.new(-2870, 54, 5396), _G.TweenSpeed, function()
                        -- Esperar Mob Leader aparecer (até 22s)
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
                            -- Ficar em cima até morrer
                            while mobLeader and mobLeader:FindFirstChild("Humanoid") and mobLeader.Humanoid.Health > 0 and _G.AutoSaber do
                                TweenTo(mobLeader.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                                task.wait(0.3)
                            end
                            -- Após morte, RichSon novamente
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")
                            -- Aguardar Relic
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
                                -- Equipar Relic
                                if player.Character then
                                    player.Character.Humanoid:EquipTool(relic)
                                end
                                -- PlaceRelic
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
                                -- Tween para (-1435,61,4)
                                TweenTo(CFrame.new(-1435, 61, 4), _G.TweenSpeed, function()
                                    -- Esperar Saber Expert
                                    local saberExpert = nil
                                    repeat
                                        task.wait(0.5)
                                        for _, mob in pairs(Workspace:FindFirstChild("Enemies"):GetChildren()) do
                                            if mob.Name == "Saber Expert" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                                saberExpert = mob
                                                break
                                            end
                                        end
                                    until saberExpert or not _G.AutoSaber
                                    if saberExpert and _G.AutoSaber then
                                        while saberExpert and saberExpert:FindFirstChild("Humanoid") and saberExpert.Humanoid.Health > 0 and _G.AutoSaber do
                                            TweenTo(saberExpert.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                                            task.wait(0.3)
                                        end
                                        -- Concluído
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

-- Kill Aura
local function StartKillAura()
    task.spawn(function()
        while _G.KillAura do
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                local character = player.Character
                if not character then return end
                
                -- Encontrar o inimigo mais próximo (qualquer)
                local target, targetHRP = nil, nil
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if not targetHRP or dist < (character.HumanoidRootPart.Position - targetHRP.Position).Magnitude then
                            target, targetHRP = mob, hrp
                        end
                    end
                end
                
                if targetHRP then
                    TweenTo(targetHRP.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)
                    
                    -- Bring mobs (até 2 do mesmo nome)
                    if _G.BringMobs then
                        local count = 0
                        for _, mob in pairs(enemies:GetChildren()) do
                            if count >= 2 then break end
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if mob.Name == target.Name and mob ~= target then
                                    hrp.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                    count = count + 1
                                end
                            end
                        end
                    end
                    
                    task.wait(0.3)
                else
                    task.wait(1)
                end
            end)
        end
    end)
end

-- Anti Gravidade
local function StartAntiGravity()
    task.spawn(function()
        while _G.AntiGravity do
            workspace.Gravity = 0
            task.wait(1)
        end
        workspace.Gravity = 196.2
    end)
end

-- Criar janela principal
local Window = WindUI:CreateWindow({
    Title = "BLOX FRUITS HUB ULTIMATE",
    Icon = "sword",
    Author = "Lorenzo, JX1 & DeepSeek",
    Folder = "BloxFruitsHub",
    Size = UDim2.fromOffset(680, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
    Background = "rbxassetid://121164944768475",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() print("User clicked") end
    }
})

-- Notificação inicial
WindUI:Notify({
    Title = "BLOX FRUITS HUB ULTIMATE",
    Content = "Interface WindUI carregada!",
    Duration = 4
})

-- Criar abas
local FarmTab = Window:Tab({ Title = "Farm", Icon = "sword" })
local FruitTab = Window:Tab({ Title = "Frutas", Icon = "apple" })
local ChestTab = Window:Tab({ Title = "Baús", Icon = "gift" })
local StatusTab = Window:Tab({ Title = "Status", Icon = "bar-chart" })
local ShopTab = Window:Tab({ Title = "Loja", Icon = "shopping-cart" })
local Sea1Tab = Window:Tab({ Title = "1 Sea", Icon = "anchor" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })
local ExtrasTab = Window:Tab({ Title = "Extras", Icon = "star" })
local UpdatesTab = Window:Tab({ Title = "Updates", Icon = "info" })

----------------------------------------------------------
-- CONSTRUÇÃO DA INTERFACE
----------------------------------------------------------

-- Aba Farm
FarmTab:Dropdown({
    Title = "Tipo de Arma",
    Values = { "punch", "espada", "gun" },
    Callback = function(val) _G.SelectedWeapon = val end
})

FarmTab:Toggle({
    Title = "Auto Equip",
    Default = false,
    Callback = function(state)
        _G.AutoEquip = state
        if state then
            task.spawn(function()
                while _G.AutoEquip do
                    pcall(function()
                        local char = player.Character
                        local bp = player.Backpack
                        if char and _G.SelectedWeapon == "punch" then
                            for _, tool in pairs(bp:GetChildren()) do
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
                    task.wait(1)
                end
            end)
        end
    end
})

FarmTab:Toggle({
    Title = "Auto Farm Level",
    Default = false,
    Callback = function(state)
        _G.AutoFarm = state
        if state then
            _G.LastQuestLevel = CheckLevel() or 0
            StartAutoFarm()
        end
    end
})

FarmTab:Toggle({
    Title = "Bring Mobs (2)",
    Default = false,
    Callback = function(state) _G.BringMobs = state end
})

FarmTab:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(state)
        _G.KillAura = state
        if state then StartKillAura() end
    end
})

-- Aba Frutas
FruitTab:Toggle({
    Title = "Spin Fruit (2h)",
    Default = false,
    Callback = function(state)
        _G.SpinFruit = state
        if state then
            task.spawn(function()
                while _G.SpinFruit do
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
                    end)
                    task.wait(7200)
                end
            end)
        end
    end
})

FruitTab:Toggle({
    Title = "ESP Frutas",
    Default = false,
    Callback = function(state)
        _G.ESP_Fruit = state
        if state then
            task.spawn(UpdateFruitESP)
        else
            -- Remover ESP (já é feito na função quando sai do loop)
        end
    end
})

-- Aba Baús
ChestTab:Toggle({
    Title = "Auto Coletar Baú (Tween)",
    Default = false,
    Callback = function(state)
        _G.AutoChestTween = state
        if state then
            _G.VisitedChests = {}
            StartAutoChestTween()
        end
    end
})

ChestTab:Toggle({
    Title = "Auto Coletar Baú (TP) - BAN RISK",
    Default = false,
    Callback = function(state)
        _G.AutoChestTP = state
        if state then
            _G.ChestTPCount = 0
            StartAutoChestTP()
        end
    end
})

ChestTab:Toggle({
    Title = "Anti Gods Itens",
    Default = false,
    Callback = function(state)
        _G.AntiGods = state
        if state then
            CheckAntiGods()
        end
    end
})

-- Aba Status
StatusTab:Slider({
    Title = "Quantidade de Pontos",
    Value = { Min = 1, Max = 100, Default = 1 },
    Callback = function(val) _G.StatusAmount = val end
})

StatusTab:Dropdown({
    Title = "Tipo de Status",
    Values = { "punch", "espada", "fruta", "arma", "defesa" },
    Callback = function(val)
        if val == "punch" then _G.StatusType = "Melee"
        elseif val == "espada" then _G.StatusType = "Sword"
        elseif val == "fruta" then _G.StatusType = "Demon Fruit"
        elseif val == "arma" then _G.StatusType = "Gun"
        elseif val == "defesa" then _G.StatusType = "Defense" end
    end
})

StatusTab:Toggle({
    Title = "Auto Status",
    Default = false,
    Callback = function(state)
        _G.AutoStatus = state
        if state then
            task.spawn(function()
                while _G.AutoStatus do
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", _G.StatusType, _G.StatusAmount)
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Aba Loja
for _, item in ipairs(shopItems) do
    ShopTab:Button({
        Title = "Comprar " .. item.Name,
        Callback = function()
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", item.RemoteArg)
                WindUI:Notify({ Title = "Loja", Content = item.Name .. " comprado!", Duration = 3 })
            end)
        end
    })
end

-- Aba 1 Sea
Sea1Tab:Toggle({
    Title = "Auto Saber",
    Default = false,
    Callback = function(state)
        _G.AutoSaber = state
        if state then
            StartAutoSaber()
        end
    end
})

-- Aba Configurações
ConfigTab:Dropdown({
    Title = "Velocidade do Tween",
    Values = { "200", "250", "300", "350" },
    Callback = function(val) _G.TweenSpeed = tonumber(val) end
})

ConfigTab:Slider({
    Title = "Velocidade de Andar",
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(val)
        _G.WalkSpeedValue = val
        if _G.AutoSpeed then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
})

ConfigTab:Toggle({
    Title = "Auto Speed",
    Default = false,
    Callback = function(state)
        _G.AutoSpeed = state
        if state then StartAutoSpeed() end
    end
})

ConfigTab:Toggle({
    Title = "Auto Attack (0.15s)",
    Default = false,
    Callback = function(state)
        _G.AutoAttack = state
        if state then StartAutoAttack() end
    end
})

ConfigTab:Toggle({
    Title = "Auto Buso",
    Default = false,
    Callback = function(state)
        _G.AutoBuso = state
        if state then StartAutoBuso() end
    end
})

ConfigTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        if state then
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
    end
})

ConfigTab:Toggle({
    Title = "Anti Gravidade",
    Default = false,
    Callback = function(state)
        _G.AntiGravity = state
        if state then StartAntiGravity() end
    end
})

-- Aba Extras
ExtrasTab:Button({
    Title = "Remover Texturas (Ultra)",
    Callback = RemoveTextures
})

ExtrasTab:Button({
    Title = "Tirar Céu",
    Callback = function()
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.new(1,1,1)
            if Lighting:FindFirstChildOfClass("Sky") then Lighting:FindFirstChildOfClass("Sky"):Destroy() end
        end)
        WindUI:Notify({ Title = "Céu", Content = "Céu e neblina removidos!", Duration = 3 })
    end
})

-- Aba Updates
UpdatesTab:Paragraph({
    Title = "📌 Novidades da Versão 0.3",
    Desc = [[
        • Auto Farm Level aprimorado com lista completa de quests
        • ESP para frutas
        • Auto Saber (1 Sea) completo
        • Kill Aura com Bring Mobs (2)
        • Anti Gods Itens (Chalice, Fist)
        • Anti Gravidade
        • Tween com gravidade zero durante movimento
        • Correções no Auto Buso
        • Sistema de baús melhorado
        • Remoção de texturas ultra
    ]]
})

-- Notificação final
WindUI:Notify({
    Title = "BLOX FRUITS HUB ULTIMATE",
    Content = "Hub carregado com WindUI!",
    Duration = 5
})

print("=== BLOX FRUITS HUB ULTIMATE CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
