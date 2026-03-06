--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    BLOX FRUITS HUB - FLUENT INTERFACE (ATUALIZADO)
    by Lorenzo, JX1 & DeepSeek
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
_G.AutoChest = false
_G.Noclip = false
_G.AutoStatus = false
_G.SpinFruit = false
_G.SelectedWeapon = "punch"
_G.StatusType = "Melee"
_G.StatusAmount = 1
_G.CurrentQuest = {}
_G.LastQuestLevel = 0

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

--// LISTA DE ITENS PARA COMPRAR (1º MAR)
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
    Title = "XFIREX HUB (BLOXFRUITS) 1 sea",
    SubTitle = "by Lorenzo, JX1 & DeepSeek",
    TabWidth = 160,
    Size = UDim2.fromOffset(460, 480),
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
--// FUNÇÕES DO JOGO
--------------------------------------------------

-- Função para detectar nível
local function CheckLevel()
    local success, level = pcall(function()
        return player.Data.Level.Value
    end)
    return success and level or nil
end

-- Função para pegar quest por nível
local function GetQuestByLevel(level)
    local questData = {}
    
    if level >= 1 and level <= 9 then
        questData = {
            Mon = "Bandit",
            LevelQuest = 1,
            NameQuest = "BanditQuest1",
            NameMon = "Bandit"
        }
    elseif level >= 10 and level <= 14 then
        questData = {
            Mon = "Monkey",
            LevelQuest = 1,
            NameQuest = "JungleQuest",
            NameMon = "Monkey"
        }
    elseif level >= 15 and level <= 29 then
        questData = {
            Mon = "Gorilla",
            LevelQuest = 2,
            NameQuest = "JungleQuest",
            NameMon = "Gorilla"
        }
    elseif level >= 30 and level <= 39 then
        questData = {
            Mon = "Pirate",
            LevelQuest = 1,
            NameQuest = "BuggyQuest1",
            NameMon = "Pirate"
        }
    elseif level >= 40 and level <= 59 then
        questData = {
            Mon = "Brute",
            LevelQuest = 2,
            NameQuest = "BuggyQuest1",
            NameMon = "Brute"
        }
    elseif level >= 60 and level <= 74 then
        questData = {
            Mon = "Desert Bandit",
            LevelQuest = 1,
            NameQuest = "DesertQuest",
            NameMon = "Desert Bandit"
        }
    elseif level >= 75 and level <= 89 then
        questData = {
            Mon = "Desert Officer",
            LevelQuest = 2,
            NameQuest = "DesertQuest",
            NameMon = "Desert Officer"
        }
    elseif level >= 90 and level <= 99 then
        questData = {
            Mon = "Snow Bandit",
            LevelQuest = 1,
            NameQuest = "SnowQuest",
            NameMon = "Snow Bandit"
        }
    elseif level >= 100 and level <= 119 then
        questData = {
            Mon = "Snowman",
            LevelQuest = 2,
            NameQuest = "SnowQuest",
            NameMon = "Snowman"
        }
    elseif level >= 120 and level <= 149 then
        questData = {
            Mon = "Chief Petty Officer",
            LevelQuest = 1,
            NameQuest = "MarineQuest2",
            NameMon = "Chief Petty Officer"
        }
    elseif level >= 150 and level <= 174 then
        questData = {
            Mon = "Sky Bandit",
            LevelQuest = 1,
            NameQuest = "SkyQuest",
            NameMon = "Sky Bandit"
        }
    elseif level >= 175 and level <= 189 then
        questData = {
            Mon = "Dark Master",
            LevelQuest = 2,
            NameQuest = "SkyQuest",
            NameMon = "Dark Master"
        }
    elseif level >= 190 and level <= 209 then
        questData = {
            Mon = "Prisoner",
            LevelQuest = 1,
            NameQuest = "PrisonerQuest",
            NameMon = "Prisoner"
        }
    elseif level >= 210 and level <= 249 then
        questData = {
            Mon = "Dangerous Prisoner",
            LevelQuest = 2,
            NameQuest = "PrisonerQuest",
            NameMon = "Dangerous Prisoner"
        }
    elseif level >= 250 and level <= 274 then
        questData = {
            Mon = "Toga Warrior",
            LevelQuest = 1,
            NameQuest = "ColosseumQuest",
            NameMon = "Toga Warrior"
        }
    elseif level >= 275 and level <= 299 then
        questData = {
            Mon = "Gladiator",
            LevelQuest = 2,
            NameQuest = "ColosseumQuest",
            NameMon = "Gladiator"
        }
    elseif level >= 300 and level <= 324 then
        questData = {
            Mon = "Military Soldier",
            LevelQuest = 1,
            NameQuest = "MagmaQuest",
            NameMon = "Military Soldier"
        }
    elseif level >= 325 and level <= 374 then
        questData = {
            Mon = "Military Spy",
            LevelQuest = 2,
            NameQuest = "MagmaQuest",
            NameMon = "Military Spy"
        }
    elseif level >= 375 and level <= 399 then
        questData = {
            Mon = "Fishman Warrior",
            LevelQuest = 1,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Warrior"
        }
    elseif level >= 400 and level <= 449 then
        questData = {
            Mon = "Fishman Commando",
            LevelQuest = 2,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Commando"
        }
    elseif level >= 450 and level <= 474 then
        questData = {
            Mon = "God's Guard",
            LevelQuest = 1,
            NameQuest = "SkyExp1Quest",
            NameMon = "God's Guard"
        }
    elseif level >= 475 and level <= 524 then
        questData = {
            Mon = "Shanda",
            LevelQuest = 2,
            NameQuest = "SkyExp1Quest",
            NameMon = "Shanda"
        }
    elseif level >= 525 and level <= 549 then
        questData = {
            Mon = "Royal Squad",
            LevelQuest = 1,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Squad"
        }
    elseif level >= 550 and level <= 624 then
        questData = {
            Mon = "Royal Soldier",
            LevelQuest = 2,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Soldier"
        }
    elseif level >= 625 and level <= 649 then
        questData = {
            Mon = "Galley Pirate",
            LevelQuest = 1,
            NameQuest = "FountainQuest",
            NameMon = "Galley Pirate"
        }
    elseif level >= 650 then
        questData = {
            Mon = "Galley Captain",
            LevelQuest = 2,
            NameQuest = "FountainQuest",
            NameMon = "Galley Captain"
        }
    end
    
    return questData
end

--// Função para fazer Tween suave e contínuo até o alvo
local function tweenToTarget(targetPart, offsetY)
    local character = player.Character
    if not character or not targetPart then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local tweenInfo = TweenInfo.new(
        0.5, -- duração curta para atualização constante
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local goal = {CFrame = targetPart.CFrame * CFrame.new(0, offsetY or 20, 0)}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    return tween
end

--------------------------------------------------
--// ABA FARM
--------------------------------------------------

-- Dropdown para tipo de arma
Tabs.Farm:AddDropdown("WeaponType", {
    Title = "Tipo de Arma",
    Values = { "punch", "espada", "gun" },
    Multi = false,
    Default = 1,
    Callback = function(Value)
        _G.SelectedWeapon = Value
    end
})

-- Toggle Auto Equip
Tabs.Farm:AddToggle("AutoEquip", {
    Title = "Auto Equip",
    Description = "Equipa automaticamente a melhor arma",
    Default = false,
    Callback = function(Value)
        _G.AutoEquip = Value
        if Value then
            spawn(function()
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
                    wait(1)
                end
            end)
        end
    end
})

-- Toggle Auto Farm (CORRIGIDO)
Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Faz farm automático de níveis (tween contínuo, bring mobs funcional)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            _G.LastQuestLevel = CheckLevel() or 0
            spawn(function()
                while _G.AutoFarm do
                    pcall(function()
                        local level = CheckLevel()
                        if not level then wait(1) return end
                        
                        -- Verifica se subiu de nível para trocar quest
                        if level > _G.LastQuestLevel then
                            _G.LastQuestLevel = level
                        end
                        
                        local quest = GetQuestByLevel(_G.LastQuestLevel)
                        if not quest then wait(1) return end
                        
                        -- Inicia quest (se não tiver ativa, o remote lida com isso)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.NameQuest, quest.LevelQuest)
                        
                        local enemies = Workspace:FindFirstChild("Enemies")
                        if not enemies or not player.Character then wait(0.5) return end
                        
                        -- Procura o mob mais próximo da quest
                        local targetMob = nil
                        local targetHRP = nil
                        for _, mob in pairs(enemies:GetChildren()) do
                            local hum = mob:FindFirstChild("Humanoid")
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and hum.Health > 0 then
                                if mob.Name:find(quest.NameMon) or mob.Name == quest.NameMon then
                                    targetMob = mob
                                    targetHRP = hrp
                                    break
                                end
                            end
                        end
                        
                        if targetHRP then
                            -- Tween contínuo para cima do mob
                            tweenToTarget(targetHRP, 20)
                            
                            -- Bring Mobs (puxa até 5 mobs para baixo do player)
                            if _G.BringMobs then
                                local count = 0
                                for _, mob in pairs(enemies:GetChildren()) do
                                    if count >= 5 then break end
                                    local hum = mob:FindFirstChild("Humanoid")
                                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                                    if hum and hrp and hum.Health > 0 then
                                        if mob.Name:find(quest.NameMon) or mob.Name == quest.NameMon then
                                            hrp.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                            count = count + 1
                                        end
                                    end
                                end
                            end
                            
                            -- Aguarda um pouco antes de reavaliar alvo
                            wait(0.3)
                        else
                            -- Se não encontrar mob, espera spawnar
                            wait(1)
                        end
                    end)
                end
            end)
        end
    end
})

-- Toggle Bring Mob
Tabs.Farm:AddToggle("BringMobs", {
    Title = "Bring Mobs",
    Description = "Puxa os mobs para perto de você (funciona com Auto Farm)",
    Default = false,
    Callback = function(Value)
        _G.BringMobs = Value
    end
})

--------------------------------------------------
--// ABA FRUTAS
--------------------------------------------------

-- Toggle Auto Store (MALICIOSO)
Tabs.Fruits:AddToggle("AutoStore", {
    Title = "Auto Store Frutas",
    Description = "Armazena frutas automaticamente (0.3s - MALICIOSO)",
    Default = false,
    Callback = function(Value)
        _G.AutoStore = Value
        if Value then
            spawn(function()
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
                    wait(0.3)
                end
            end)
        end
    end
})

-- Toggle Spin Fruit (a cada 2 horas)
Tabs.Fruits:AddToggle("SpinFruit", {
    Title = "Spin Fruit Automático",
    Description = "Executa spin a cada 2 horas (uso consciente)",
    Default = false,
    Callback = function(Value)
        _G.SpinFruit = Value
        if Value then
            spawn(function()
                while _G.SpinFruit do
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
                        print("🍎 Spin Fruit executado")
                    end)
                    wait(7200) -- 2 horas = 7200 segundos
                end
            end)
        end
    end
})

--------------------------------------------------
--// ABA BAÚS
--------------------------------------------------

-- Toggle Auto Coletar Baús
Tabs.Chest:AddToggle("AutoChest", {
    Title = "Auto Coletar Baús",
    Description = "Teleporta para baús automaticamente",
    Default = false,
    Callback = function(Value)
        _G.AutoChest = Value
        if Value then
            spawn(function()
                while _G.AutoChest do
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
                                character.HumanoidRootPart.CFrame = closest.CFrame * CFrame.new(0, 5, 0)
                                wait(1)
                            end
                        end
                    end)
                    wait(2)
                end
            end)
        end
    end
})

--------------------------------------------------
--// ABA STATUS
--------------------------------------------------

-- Slider para quantidade de pontos
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

-- Dropdown para tipo de status
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

-- Toggle Auto Status
Tabs.Status:AddToggle("AutoStatus", {
    Title = "Auto Status",
    Description = "Adiciona pontos automaticamente",
    Default = false,
    Callback = function(Value)
        _G.AutoStatus = Value
        if Value then
            spawn(function()
                while _G.AutoStatus do
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", _G.StatusType, _G.StatusAmount)
                    end)
                    wait(0.5)
                end
            end)
        end
    end
})

--------------------------------------------------
--// ABA LOJA (COMPRAR ITENS)
--------------------------------------------------

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

--------------------------------------------------
--// ABA CONFIGURAÇÕES
--------------------------------------------------

-- Toggle Auto Buso
Tabs.Config:AddToggle("AutoBuso", {
    Title = "Auto Buso",
    Description = "Ativa Buso Haki automaticamente",
    Default = false,
    Callback = function(Value)
        _G.AutoBuso = Value
        if Value then
            spawn(function()
                while _G.AutoBuso do
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                    end)
                    wait(5)
                end
            end)
            
            player.CharacterAdded:Connect(function()
                if _G.AutoBuso then
                    wait(5)
                    spawn(function()
                        while _G.AutoBuso do
                            pcall(function()
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
                            end)
                            wait(5)
                        end
                    end)
                end
            end)
        end
    end
})

-- Toggle Noclip
Tabs.Config:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Atravessa paredes",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        if Value then
            spawn(function()
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
                    wait(0.1)
                end
            end)
        end
    end
})

--------------------------------------------------
--// ABA EXTRAS
--------------------------------------------------

-- Botão Remover Texturas
Tabs.Extras:AddButton({
    Title = "Remover Texturas",
    Description = "Remove todas as texturas do jogo",
    Callback = function()
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
            end
            Fluent:Notify({
                Title = "Texturas",
                Content = "Todas as texturas foram removidas!",
                Duration = 3
            })
        end)
    end
})

-- Botão Tirar Céu
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

-- Botão Redeem All Codes
Tabs.Extras:AddButton({
    Title = "Redeem All Codes",
    Description = "Resgata todos os códigos disponíveis",
    Callback = function()
        spawn(function()
            local codes = {
                "fruitconcepts", "krazydares", "TRIPLEABUSE", "SEATROLLING",
                "ADMINFIGHT", "BANEXPLOIT", "GetPranked", "BossBuild",
                "1LOSTADMIN", "GIFTING_HOURS", "NOMOREHACK", "EARN_FRUITS",
                "FIGHT4FRUIT", "SUB2OFFICIALNOOBIE", "STRAWHATMAINE",
                "SUB2NOOBMASTER123", "JCWK", "KITTGAMING", "MagicBus",
                "BLUXXY", "LIGHTNINGABUSE", "KITT_RESET", "SUB2CAPTAINMAUI",
                "SUB2FER999", "ENYU_IS_PRO", "STARCODEHEO", "FUDD10_V2",
                "SUB2GAMERROBOT_EXP1", "SUB2GAMERROBOT_RESET1", "SUB2UNCLEKIZARU",
                "SUB2DAIGROCK", "AXIORE", "TANTAIGAMING", "NOEXPLOITER",
                "NOOB2ADMIN", "CODESLIDE", "ADMINHACKED", "ADMINDARES",
                "NEWTROLL", "REWARDFUN", "24NOADMIN", "GAMER_ROBOT_1M",
                "SUBGAMERROBOT_RESET", "GAMERROBOT_YT", "TY_FOR_WATCHING",
                "EXP_5B", "RESET_5B", "UPD16", "3BVISITS", "2BILLION",
                "UPD15", "BIGNEWS"
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
})

-- Parágrafo com créditos
Tabs.Extras:AddParagraph({
    Title = "📌 CRÉDITOS",
    Content = "👤 Lorenzo\n👤 JX1\n🤖 DeepSeek Interface\n\nVersão: 6.0 Fluent Atualizada\nObrigado por usar nosso hub!"
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
