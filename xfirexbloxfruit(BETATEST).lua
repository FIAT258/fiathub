--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    BLOX FRUITS HUB - FLUENT INTERFACE (CORRIGIDO)
    by Lorenzo, JX1 & DeepSeek
    Versão 8.0 - Farm, Baús, Status, Loja e mais
]]

--// CARREGAR FLUENT
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Fluent, SaveManager, InterfaceManager = loadstring(Game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

--// VARIÁVEIS GLOBAIS
_G.AutoFarm = false
_G.AutoEquip = false
_G.AutoStore = false
_G.AutoBuso = false
_G.BringMobs = false
_G.AutoChestTween = false
_G.AutoChestTP = false
_G.Noclip = false
_G.AutoStatus = false
_G.SpinFruit = false
_G.AutoSpeed = false
_G.SelectedWeapon = "punch"
_G.StatusType = "Melee"
_G.StatusAmount = 1
_G.WalkSpeedValue = 16
_G.TweenSpeed = 250
_G.CurrentQuest = {}
_G.LastQuestLevel = 0
_G.VisitedChests = {}
_G.ChestTPCount = 0

--// LISTA DE FRUTAS PARA STORE
local frutas = {
    "Bomb-Bomb", "Spike-Spike", "Chop-Chop", "Spring-Spring", "Rocket-Rocket",
    "Kilo-Kilo", "Spin-Spin", "Love-Love", "Rubber-Rubber", "Smoke-Smoke",
    "Flame-Flame", "Ice-Ice", "Sand-Sand", "Dark-Dark", "Light-Light",
    "Magma-Magma", "Rumble-Rumble", "Blade-Blade", "Stone-Stone", "Barrier-Barrier",
    "Diamond-Diamond", "String-String", "Spider-Spider", "Falcon-Falcon", "Saber-Saber",
    "Portal-Portal", "Buddha-Buddha", "Gravity-Gravity", "Mammoth-Mammoth", "Sound-Sound",
    "Control-Control", "Spirit-Spirit", "Shadow-Shadow", "Venom-Venom", "Dough-Dough",
    "Dragon-Dragon", "Leopard-Leopard", "Kitsune-Kitsune", "Pain-Pain", "Ghost-Ghost",
    "Revive-Revive", "Oni-Oni", "Celestial-Celestial", "Blizzard-Blizzard", "Storm-Storm"
}

--// LISTA DE COMBATES
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

--// LISTA DE ITENS PARA COMPRA (1º MAR)
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

--// CRIAR JANELA
local Window = Fluent:CreateWindow({
    Title = "XFIREX HUB blox fruits sea 1 ",
    SubTitle = "by Lorenzo, JX1 & DeepSeek",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// NOTIFICAÇÃO INICIAL
Fluent:Notify({
    Title = "BLOX FRUITS HUB",
    Content = "Interface carregada com sucesso!",
    Duration = 5
})

--// CRIAR ABAS
local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Fruits = Window:AddTab({ Title = "Frutas", Icon = "apple" }),
    Chest = Window:AddTab({ Title = "Baús", Icon = "gift" }),
    Status = Window:AddTab({ Title = "Status", Icon = "bar-chart" }),
    Shop = Window:AddTab({ Title = "Loja", Icon = "shopping-cart" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" }),
    Extras = Window:AddTab({ Title = "Extras", Icon = "star" })
}

local Options = Fluent.Options

--------------------------------------------------
--// FUNÇÕES AUXILIARES
--------------------------------------------------

-- Função para detectar nível
local function CheckLevel()
    local success, level = pcall(function()
        return player.Data.Level.Value
    end)
    return success and level or nil
end

-- Função para criar tween contínuo (atualiza a cada 0.3s para manter suavidade)
local function TweenToTarget(targetPart, offsetY)
    local character = player.Character
    if not character or not targetPart then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local tweenInfo = TweenInfo.new(
        0.3, -- tempo curto para atualização constante
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    local goal = {CFrame = targetPart.CFrame * CFrame.new(0, offsetY or 20, 0)}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    return tween
end

-- Função para pegar quest por nível (completa com todos os níveis)
local function GetQuestByLevel(level)
    if level >= 1 and level <= 9 then
        return {
            Mon = "Bandit",
            LevelQuest = 1,
            NameQuest = "BanditQuest1",
            NameMon = "Bandit"
        }
    elseif level >= 10 and level <= 14 then
        return {
            Mon = "Monkey",
            LevelQuest = 1,
            NameQuest = "JungleQuest",
            NameMon = "Monkey"
        }
    elseif level >= 15 and level <= 29 then
        return {
            Mon = "Gorilla",
            LevelQuest = 2,
            NameQuest = "JungleQuest",
            NameMon = "Gorilla"
        }
    elseif level >= 30 and level <= 39 then
        return {
            Mon = "Pirate",
            LevelQuest = 1,
            NameQuest = "BuggyQuest1",
            NameMon = "Pirate"
        }
    elseif level >= 40 and level <= 59 then
        return {
            Mon = "Brute",
            LevelQuest = 2,
            NameQuest = "BuggyQuest1",
            NameMon = "Brute"
        }
    elseif level >= 60 and level <= 74 then
        return {
            Mon = "Desert Bandit",
            LevelQuest = 1,
            NameQuest = "DesertQuest",
            NameMon = "Desert Bandit"
        }
    elseif level >= 75 and level <= 89 then
        return {
            Mon = "Desert Officer",
            LevelQuest = 2,
            NameQuest = "DesertQuest",
            NameMon = "Desert Officer"
        }
    elseif level >= 90 and level <= 99 then
        return {
            Mon = "Snow Bandit",
            LevelQuest = 1,
            NameQuest = "SnowQuest",
            NameMon = "Snow Bandit"
        }
    elseif level >= 100 and level <= 119 then
        return {
            Mon = "Snowman",
            LevelQuest = 2,
            NameQuest = "SnowQuest",
            NameMon = "Snowman"
        }
    elseif level >= 120 and level <= 149 then
        return {
            Mon = "Chief Petty Officer",
            LevelQuest = 1,
            NameQuest = "MarineQuest2",
            NameMon = "Chief Petty Officer"
        }
    elseif level >= 150 and level <= 174 then
        return {
            Mon = "Sky Bandit",
            LevelQuest = 1,
            NameQuest = "SkyQuest",
            NameMon = "Sky Bandit"
        }
    elseif level >= 175 and level <= 189 then
        return {
            Mon = "Dark Master",
            LevelQuest = 2,
            NameQuest = "SkyQuest",
            NameMon = "Dark Master"
        }
    elseif level >= 190 and level <= 209 then
        return {
            Mon = "Prisoner",
            LevelQuest = 1,
            NameQuest = "PrisonerQuest",
            NameMon = "Prisoner"
        }
    elseif level >= 210 and level <= 249 then
        return {
            Mon = "Dangerous Prisoner",
            LevelQuest = 2,
            NameQuest = "PrisonerQuest",
            NameMon = "Dangerous Prisoner"
        }
    elseif level >= 250 and level <= 274 then
        return {
            Mon = "Toga Warrior",
            LevelQuest = 1,
            NameQuest = "ColosseumQuest",
            NameMon = "Toga Warrior"
        }
    elseif level >= 275 and level <= 299 then
        return {
            Mon = "Gladiator",
            LevelQuest = 2,
            NameQuest = "ColosseumQuest",
            NameMon = "Gladiator"
        }
    elseif level >= 300 and level <= 324 then
        return {
            Mon = "Military Soldier",
            LevelQuest = 1,
            NameQuest = "MagmaQuest",
            NameMon = "Military Soldier"
        }
    elseif level >= 325 and level <= 374 then
        return {
            Mon = "Military Spy",
            LevelQuest = 2,
            NameQuest = "MagmaQuest",
            NameMon = "Military Spy"
        }
    elseif level >= 375 and level <= 399 then
        return {
            Mon = "Fishman Warrior",
            LevelQuest = 1,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Warrior"
        }
    elseif level >= 400 and level <= 449 then
        return {
            Mon = "Fishman Commando",
            LevelQuest = 2,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Commando"
        }
    elseif level >= 450 and level <= 474 then
        return {
            Mon = "God's Guard",
            LevelQuest = 1,
            NameQuest = "SkyExp1Quest",
            NameMon = "God's Guard"
        }
    elseif level >= 475 and level <= 524 then
        return {
            Mon = "Shanda",
            LevelQuest = 2,
            NameQuest = "SkyExp1Quest",
            NameMon = "Shanda"
        }
    elseif level >= 525 and level <= 549 then
        return {
            Mon = "Royal Squad",
            LevelQuest = 1,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Squad"
        }
    elseif level >= 550 and level <= 624 then
        return {
            Mon = "Royal Soldier",
            LevelQuest = 2,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Soldier"
        }
    elseif level >= 625 and level <= 649 then
        return {
            Mon = "Galley Pirate",
            LevelQuest = 1,
            NameQuest = "FountainQuest",
            NameMon = "Galley Pirate"
        }
    elseif level >= 650 then
        return {
            Mon = "Galley Captain",
            LevelQuest = 2,
            NameQuest = "FountainQuest",
            NameMon = "Galley Captain"
        }
    end
    return nil
end

-- Função de auto attack (exata, com loop 0.15s)
local function StartAutoAttack()
    task.spawn(function()
        local enemies = workspace:WaitForChild("Enemies")
        while _G.AutoAttack do
            pcall(function()
                local character = player.Character
                if not character then return end
                local root = character:FindFirstChild("HumanoidRootPart")
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

-- Função de auto buso (corrigida: ativa uma vez e reativa 6s após morte)
local function StartAutoBuso()
    local function ActivateBuso()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end)
    end
    
    ActivateBuso()
    
    local connection
    connection = player.CharacterAdded:Connect(function()
        if _G.AutoBuso then
            task.wait(6)
            ActivateBuso()
        else
            if connection then
                connection:Disconnect()
            end
        end
    end)
end

-- Função de auto speed
local function StartAutoSpeed()
    task.spawn(function()
        while _G.AutoSpeed do
            pcall(function()
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = _G.WalkSpeedValue
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- Função de auto farm (baseada na versão que funcionava, com melhorias)
local function StartAutoFarm()
    task.spawn(function()
        while _G.AutoFarm do
            pcall(function()
                local level = CheckLevel()
                if not level then
                    task.wait(1)
                    return
                end

                -- Se subiu de nível, atualiza a quest
                if level > _G.LastQuestLevel then
                    _G.LastQuestLevel = level
                    local quest = GetQuestByLevel(level)
                    if quest then
                        _G.CurrentQuest = quest
                        -- Inicia a nova quest (o remote lida com repetição)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.NameQuest, quest.LevelQuest)
                        print("📋 Nova quest iniciada:", quest.NameQuest)
                    end
                end

                if not _G.CurrentQuest or not _G.CurrentQuest.NameMon then
                    task.wait(1)
                    return
                end

                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then
                    task.wait(1)
                    return
                end

                local character = player.Character
                if not character then
                    task.wait(1)
                    return
                end

                -- Procurar o mob mais próximo da quest
                local targetMob = nil
                local targetHRP = nil
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                            targetMob = mob
                            targetHRP = hrp
                            break
                        end
                    end
                end

                if targetHRP then
                    -- Tween contínuo para cima do mob
                    TweenToTarget(targetHRP, 20)

                    -- Bring mobs (puxa até 5 mobs para baixo do player)
                    if _G.BringMobs then
                        local count = 0
                        for _, mob in pairs(enemies:GetChildren()) do
                            if count >= 5 then break end
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                                    hrp.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                    count = count + 1
                                end
                            end
                        end
                    end

                    -- Aguarda um pouco antes de reavaliar alvo
                    task.wait(0.3)
                else
                    -- Se não encontrou mob, espera spawnar
                    task.wait(1)
                end
            end)
        end
    end)
end

-- Função de auto chest tween (não repete baús no mesmo ciclo)
local function StartAutoChestTween()
    task.spawn(function()
        while _G.AutoChestTween do
            pcall(function()
                local character = player.Character
                if not character then return end

                -- Coletar baús ainda não visitados neste ciclo
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
                    -- Escolher o mais próximo
                    local closest = nil
                    local closestDist = math.huge
                    for _, chest in pairs(chests) do
                        local dist = (character.HumanoidRootPart.Position - chest.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = chest
                        end
                    end

                    if closest then
                        TweenToTarget(closest, 2) -- tween para o baú
                        _G.VisitedChests[tostring(closest.Position)] = true
                        task.wait(1) -- tempo para coletar
                    end
                else
                    -- Todos os baús foram visitados, aguarda 1 minuto e reseta
                    task.wait(60)
                    _G.VisitedChests = {}
                end
            end)
            task.wait(1)
        end
    end)
end

-- Função de auto chest teleporte (ban risk: 3 teleportes e reseta)
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
                    -- Pega o primeiro baú da lista (ou pode ser aleatório)
                    local target = chests[1]
                    character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)
                    _G.ChestTPCount = _G.ChestTPCount + 1
                    task.wait(0.5)

                    if _G.ChestTPCount >= 3 then
                        -- Reseta o player (mata para respawn)
                        character.Humanoid.Health = 0
                        _G.ChestTPCount = 0
                        task.wait(5) -- aguarda respawn
                    end
                else
                    task.wait(5)
                end
            end)
            task.wait(1)
        end
    end)
end

-- Função de spin fruit (a cada 2 horas)
local function StartSpinFruit()
    task.spawn(function()
        while _G.SpinFruit do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
                print("🍎 Spin Fruit executado")
            end)
            task.wait(7200) -- 2 horas
        end
    end)
end

-- Função melhorada para remover texturas
local function RemoveTextures()
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
        -- Opcional: remover texturas de partes específicas
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Texture = ""
                v.Material = Enum.Material.Plastic
            end
        end
        Fluent:Notify({
            Title = "Texturas",
            Content = "Todas as texturas foram removidas!",
            Duration = 3
        })
    end)
end

-- Função para resgatar todos os códigos
local function RedeemAllCodes()
    task.spawn(function()
        local codes = {
            "fruitconcepts", "krazydares", "TRIPLEABUSE", "SEATROLLING", "ADMINFIGHT",
            "BANEXPLOIT", "GetPranked", "BossBuild", "1LOSTADMIN", "GIFTING_HOURS",
            "NOMOREHACK", "EARN_FRUITS", "FIGHT4FRUIT", "SUB2OFFICIALNOOBIE",
            "STRAWHATMAINE", "SUB2NOOBMASTER123", "JCWK", "KITTGAMING", "MagicBus",
            "BLUXXY", "LIGHTNINGABUSE", "KITT_RESET", "SUB2CAPTAINMAUI", "SUB2FER999",
            "ENYU_IS_PRO", "STARCODEHEO", "FUDD10_V2", "SUB2GAMERROBOT_EXP1",
            "SUB2GAMERROBOT_RESET1", "SUB2UNCLEKIZARU", "SUB2DAIGROCK", "AXIORE",
            "TANTAIGAMING", "NOEXPLOITER", "NOOB2ADMIN", "CODESLIDE", "ADMINHACKED",
            "ADMINDARES", "NEWTROLL", "REWARDFUN", "24NOADMIN", "GAMER_ROBOT_1M",
            "SUBGAMERROBOT_RESET", "GAMERROBOT_YT", "TY_FOR_WATCHING", "EXP_5B",
            "RESET_5B", "UPD16", "3BVISITS", "2BILLION", "UPD15", "BIGNEWS"
        }
        local redeemRemote = ReplicatedStorage.Remotes.Redeem
        Fluent:Notify({
            Title = "Códigos",
            Content = "Iniciando resgate de " .. #codes .. " códigos...",
            Duration = 4
        })
        for i, code in ipairs(codes) do
            pcall(function()
                redeemRemote:InvokeServer(code)
            end)
            if i < #codes then
                task.wait(0.3)
            end
        end
        Fluent:Notify({
            Title = "Códigos",
            Content = "Processo concluído!",
            Duration = 4
        })
    end)
end

--------------------------------------------------
--// CONSTRUÇÃO DA INTERFACE
--------------------------------------------------

-- Aba Farm
Tabs.Farm:AddDropdown("WeaponType", {
    Title = "Tipo de Arma",
    Values = { "punch", "espada", "gun" },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        _G.SelectedWeapon = Value
    end
})

Tabs.Farm:AddToggle("AutoEquip", {
    Title = "Auto Equip",
    Description = "Equipa automaticamente a melhor arma",
    Default = false,
    Callback = function(Value)
        _G.AutoEquip = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquip do
                    pcall(function()
                        local character = player.Character
                        local backpack = player.Backpack
                        if not character then return end
                        
                        if _G.SelectedWeapon == "punch" then
                            for _, tool in pairs(backpack:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, style in pairs(combatStyles) do
                                        if tool.Name:find(style) or tool.Name == style then
                                            character.Humanoid:EquipTool(tool)
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

Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Faz farm automático de níveis (tween contínuo, bring mobs funcional)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            _G.LastQuestLevel = CheckLevel() or 0
            StartAutoFarm()
        end
    end
})

Tabs.Farm:AddToggle("BringMobs", {
    Title = "Bring Mobs",
    Description = "Puxa os mobs para perto de você (funciona com Auto Farm)",
    Default = false,
    Callback = function(Value)
        _G.BringMobs = Value
    end
})

-- Aba Frutas
Tabs.Fruits:AddToggle("AutoStore", {
    Title = "Auto Store Frutas",
    Description = "Armazena frutas automaticamente (0.3s - MALICIOSO)",
    Default = false,
    Callback = function(Value)
        _G.AutoStore = Value
        if Value then
            task.spawn(function()
                while _G.AutoStore do
                    pcall(function()
                        local CommF = ReplicatedStorage.Remotes.CommF_
                        local backpack = player.Backpack
                        local character = player.Character
                        
                        for _, tool in pairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruitName in pairs(frutas) do
                                    if tool.Name:find(fruitName) or tool.Name == fruitName then
                                        CommF:InvokeServer("StoreFruit", fruitName, tool)
                                        break
                                    end
                                end
                            end
                        end
                        
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruitName in pairs(frutas) do
                                    if tool.Name:find(fruitName) or tool.Name == fruitName then
                                        CommF:InvokeServer("StoreFruit", fruitName, tool)
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

Tabs.Fruits:AddToggle("SpinFruit", {
    Title = "Spin Fruit Automático",
    Description = "Executa spin a cada 2 horas (uso consciente)",
    Default = false,
    Callback = function(Value)
        _G.SpinFruit = Value
        if Value then
            StartSpinFruit()
        end
    end
})

-- Aba Baús
Tabs.Chest:AddToggle("AutoChestTween", {
    Title = "Auto Coletar Baú (Tween)",
    Description = "Vai até os baús usando tween, sem repetir no mesmo ciclo",
    Default = false,
    Callback = function(Value)
        _G.AutoChestTween = Value
        if Value then
            _G.VisitedChests = {}
            StartAutoChestTween()
        end
    end
})

Tabs.Chest:AddToggle("AutoChestTP", {
    Title = "Auto Coletar Baú (Teleporte) - BAN RISK",
    Description = "Teleporta 3 vezes para baús e depois reseta o player",
    Default = false,
    Callback = function(Value)
        _G.AutoChestTP = Value
        if Value then
            _G.ChestTPCount = 0
            StartAutoChestTP()
        end
    end
})

-- Aba Status
Tabs.Status:AddSlider("StatusAmount", {
    Title = "Quantidade de Pontos",
    Description = "Quantos pontos adicionar por vez",
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        _G.StatusAmount = Value
    end
})

Tabs.Status:AddDropdown("StatusType", {
    Title = "Tipo de Status",
    Values = { "punch", "espada", "fruta", "arma", "defesa" },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        if Value == "punch" then
            _G.StatusType = "Melee"
        elseif Value == "espada" then
            _G.StatusType = "Sword"
        elseif Value == "fruta" then
            _G.StatusType = "Demon Fruit"
        elseif Value == "arma" then
            _G.StatusType = "Gun"
        elseif Value == "defesa" then
            _G.StatusType = "Defense"
        end
    end
})

Tabs.Status:AddToggle("AutoStatus", {
    Title = "Auto Status",
    Description = "Adiciona pontos automaticamente",
    Default = false,
    Callback = function(Value)
        _G.AutoStatus = Value
        if Value then
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
    Tabs.Shop:AddButton({
        Title = "Comprar " .. item.Name,
        Description = "Compra " .. item.Name .. " (se disponível)",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", item.RemoteArg)
                Fluent:Notify({
                    Title = "Loja",
                    Content = item.Name .. " comprado!",
                    Duration = 3
                })
            end)
        end
    })
end

-- Aba Configurações
Tabs.Config:AddDropdown("TweenSpeed", {
    Title = "Velocidade do Tween",
    Description = "Velocidade de movimento dos tweens (200-350)",
    Values = { "200", "250", "300", "350" },
    Multi = false,
    Default = "250",
    Callback = function(Value)
        _G.TweenSpeed = tonumber(Value)
    end
})

Tabs.Config:AddSlider("WalkSpeedSlider", {
    Title = "Velocidade de Andar",
    Description = "Ajusta a WalkSpeed (16-300)",
    Default = 16,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        _G.WalkSpeedValue = Value
        if _G.AutoSpeed then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = Value
                end
            end
        end
    end
})

Tabs.Config:AddToggle("AutoSpeed", {
    Title = "Auto Speed",
    Description = "Mantém a velocidade configurada",
    Default = false,
    Callback = function(Value)
        _G.AutoSpeed = Value
        if Value then
            StartAutoSpeed()
        end
    end
})

Tabs.Config:AddToggle("AutoAttack", {
    Title = "Auto Attack",
    Description = "Ataca mobs próximos automaticamente (loop 0.15s)",
    Default = false,
    Callback = function(Value)
        _G.AutoAttack = Value
        if Value then
            StartAutoAttack()
        end
    end
})

Tabs.Config:AddToggle("AutoBuso", {
    Title = "Auto Buso",
    Description = "Ativa Buso Haki uma vez e reativa 6s após morte",
    Default = false,
    Callback = function(Value)
        _G.AutoBuso = Value
        if Value then
            StartAutoBuso()
        end
    end
})

Tabs.Config:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Atravessa paredes",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        if Value then
            task.spawn(function()
                while _G.Noclip do
                    pcall(function()
                        local character = player.Character
                        if character then
                            for _, v in pairs(character:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    v.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Aba Extras
Tabs.Extras:AddButton({
    Title = "Remover Texturas",
    Description = "Remove todas as texturas do jogo",
    Callback = RemoveTextures
})

Tabs.Extras:AddButton({
    Title = "Tirar Céu",
    Description = "Remove céu e neblina",
    Callback = function()
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.new(1, 1, 1)
            if Lighting:FindFirstChildOfClass("Sky") then
                Lighting:FindFirstChildOfClass("Sky"):Destroy()
            end
            Fluent:Notify({
                Title = "Céu",
                Content = "Céu e neblina removidos!",
                Duration = 3
            })
        end)
    end
})

Tabs.Extras:AddButton({
    Title = "Redeem All Codes",
    Description = "Resgata todos os códigos disponíveis",
    Callback = RedeemAllCodes
})

Tabs.Extras:AddParagraph({
    Title = "📌 CRÉDITOS",
    Content = "👤 Lorenzo\n👤 JX1\n🤖 DeepSeek Interface\n\nVersão: 8.0 Fluent Corrigida\nObrigado por usar nosso hub!"
})

--------------------------------------------------
--// SAVE MANAGER
--------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloxFruitsHub")
SaveManager:SetFolder("BloxFruitsHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Config)
SaveManager:BuildConfigSection(Tabs.Config)

Window:SelectTab(1)

Fluent:Notify({
    Title = "BLOX FRUITS HUB",
    Content = "Hub carregado com sucesso!",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()

print("=== BLOX FRUITS HUB CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
