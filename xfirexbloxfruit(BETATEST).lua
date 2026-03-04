--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    BLOX FRUITS HUB - by Lorenzo, JX1 & DeepSeek Interface
    Versão: 4.0 COMPLETA COM WINDUI
]]

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
_G.AutoAttack = false
_G.AutoBuso = false
_G.BringMobs = false
_G.AutoChest = false
_G.Noclip = false
_G.SelectedWeapon = "punch"
_G.StatusType = "Melee"
_G.StatusAmount = 1
_G.AutoStatus = false
_G.CurrentQuest = {}

--// LISTA DE FRUTAS PARA STORE
local frutas = {
    -- COMMON
    "Bomb-Bomb", "Spike-Spike", "Chop-Chop", "Spring-Spring", "Rocket-Rocket",
    "Kilo-Kilo", "Spin-Spin", "Love-Love", "Rubber-Rubber", "Smoke-Smoke",
    
    -- UNCOMMON  
    "Flame-Flame", "Ice-Ice", "Sand-Sand", "Dark-Dark", "Light-Light",
    "Magma-Magma", "Rumble-Rumble", "Blade-Blade",
    
    -- RARE
    "Stone-Stone", "Barrier-Barrier", "Diamond-Diamond", "String-String",
    "Spider-Spider", "Falcon-Falcon", "Saber-Saber",
    
    -- LEGENDARY
    "Portal-Portal", "Buddha-Buddha", "Gravity-Gravity", "Mammoth-Mammoth",
    "Sound-Sound", "Control-Control", "Spirit-Spirit", "Shadow-Shadow",
    
    -- MYTHICAL
    "Venom-Venom", "Dough-Dough", "Dragon-Dragon", "Leopard-Leopard",
    "Kitsune-Kitsune", "Pain-Pain", "Ghost-Ghost", "Revive-Revive",
    "Oni-Oni", "Celestial-Celestial", "Blizzard-Blizzard", "Storm-Storm"
}

--// LISTA DE COMBATES PARA AUTO EQUIP
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

--// LISTA DE ESPADAS
local swords = {
    "Katana", "Cutlass", "Saber", "Pipe", "Dual Katana", "Iron Mace",
    "Shark Saw", "Rengoku", "Pole", "Jitte", "Longsword", "Bisento",
    "Cursed Dual Katana", "Yama", "Tushita", "Buddy Sword", "Canvander"
}

--// LISTA DE GUNS
local guns = {
    "Slingshot", "Flintlock", "Musket", "Refined Flintlock", "Cannon",
    "Kabucha", "Bazooka", "Soul Guitar", "Venom Bow", "Serpent Bow"
}

--------------------------------------------------
--// CARREGAR WIND UI
--------------------------------------------------
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// CRIAR JANELA PRINCIPAL
local Window = WindUI:CreateWindow({
    Title = "XFIREX HUB BLOXFRUITS test",
    Icon = "sword",
    Author = "by Lorenzo, JX1 & DeepSeek",
    Folder = "BloxFruitsHub",

    Size = UDim2.fromOffset(650, 520),
    MinSize = Vector2.new(580, 400),
    MaxSize = Vector2.new(950, 650),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
    BackgroundImageTransparency = 0.35,
    HideSearchBar = false,
    ScrollBarEnabled = true,

    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("👤 Perfil do usuário clicado")
        end,
    },

    KeySystem = {
        Key = { "#fire#hubx130key18722--KEYwalfy", "#fire#hubx130key18722--KEYwalfy", },
        Note = "Digite uma das keys para acessar",
        Thumbnail = {
            Image = "rbxassetid://84973708912590",
            Title = "",
        },
        URL = "#fire#hubx130key18722--KEYwalfy",
        SaveKey = false,
    },
})

--// TAG DE VERSÃO
Window:Tag({
    Title = "v4.0 COMPLETA",
    Icon = "sparkles",
    Color = Color3.fromHex("#FF6B6B"),
    Radius = 8,
})

--// NOTIFICAÇÃO INICIAL
WindUI:Notify({
    Title = "⚔️ Blox Fruits Hub",
    Content = "Hub carregado com sucesso! Todas as funções prontas.",
    Duration = 5,
    Icon = "check-circle",
})

--------------------------------------------------
--// FUNÇÕES DO JOGO
--------------------------------------------------

-- Função para detectar nível
local function CheckLevel()
    local success, level = pcall(function()
        return player.Data.Level.Value
    end)
    
    if success and level then
        return level
    end
    return nil
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

--------------------------------------------------
--// TAB 1 - FARM
--------------------------------------------------
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "zap",
})

-- Dropdown para tipo de arma
FarmTab:Dropdown({
    Title = "Tipo de Arma",
    Desc = "Selecione o tipo para auto equip",
    Values = { "punch", "espada", "gun" },
    Value = { "punch" },
    Multi = false,
    Callback = function(options)
        _G.SelectedWeapon = options[1]
        print("🔫 Arma selecionada:", _G.SelectedWeapon)
    end
})

-- Toggle Auto Equip
FarmTab:Toggle({
    Title = "Auto Equip",
    Desc = "Equipa automaticamente a melhor arma do tipo selecionado",
    Icon = "refresh-cw",
    Value = false,
    Callback = function(state)
        _G.AutoEquip = state
        print("⚔️ Auto Equip:", state)
        
        if state then
            spawn(function()
                while _G.AutoEquip do
                    pcall(function()
                        local character = player.Character
                        local backpack = player.Backpack
                        if not character then return end
                        
                        if _G.SelectedWeapon == "punch" then
                            -- Procurar combat styles
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

-- Toggle Auto Farm
FarmTab:Toggle({
    Title = "Auto Farm",
    Desc = "Faz farm automático de níveis",
    Icon = "play",
    Value = false,
    Callback = function(state)
        _G.AutoFarm = state
        print("🌾 Auto Farm:", state)
        
        if state then
            spawn(function()
                while _G.AutoFarm do
                    pcall(function()
                        local level = CheckLevel()
                        if not level then wait(1) return end
                        
                        local quest = GetQuestByLevel(level)
                        if quest then
                            local args = {"StartQuest", quest.NameQuest, quest.LevelQuest}
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                            print("📋 Quest iniciada:", quest.NameQuest)
                            
                            -- Procurar mobs
                            local enemies = Workspace:FindFirstChild("Enemies")
                            if enemies then
                                for _, mob in pairs(enemies:GetChildren()) do
                                    local hum = mob:FindFirstChild("Humanoid")
                                    if hum and hum.Health > 0 then
                                        if mob.Name:find(quest.NameMon) or mob.Name == quest.NameMon then
                                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                                            if hrp and player.Character then
                                                player.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 20, 0)
                                                wait(2)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    wait(3)
                end
            end)
        end
    end
})

-- Toggle Bring Mob
FarmTab:Toggle({
    Title = "Bring Mob",
    Desc = "Puxa os mobs para perto de você",
    Icon = "arrow-down",
    Value = false,
    Callback = function(state)
        _G.BringMobs = state
        print("🔄 Bring Mob:", state)
    end
})

--------------------------------------------------
--// TAB 2 - FRUTAS
--------------------------------------------------
local FruitTab = Window:Tab({
    Title = "Frutas",
    Icon = "apple",
})

-- Toggle Auto Store (MALICIOSO)
FruitTab:Toggle({
    Title = "Auto Store Frutas",
    Desc = "Armazena frutas automaticamente (0.3s - MALICIOSO)",
    Icon = "package",
    Value = false,
    Callback = function(state)
        _G.AutoStore = state
        print("🍎 Auto Store:", state)
        
        if state then
            spawn(function()
                while _G.AutoStore do
                    pcall(function()
                        local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
                        local backpack = player.Backpack
                        local character = player.Character
                        
                        -- Backpack
                        for _, tool in pairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruitName in pairs(frutas) do
                                    if tool.Name:find(fruitName) or tool.Name == fruitName then
                                        local args = {"StoreFruit", fruitName, tool}
                                        CommF:InvokeServer(unpack(args))
                                        print("🟢 Fruta armazenada: " .. fruitName)
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Character
                        for _, tool in pairs(character:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruitName in pairs(frutas) do
                                    if tool.Name:find(fruitName) or tool.Name == fruitName then
                                        local args = {"StoreFruit", fruitName, tool}
                                        CommF:InvokeServer(unpack(args))
                                        print("🟢 Fruta armazenada: " .. fruitName)
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    wait(0.3) -- MALICIOSO
                end
            end)
        end
    end
})

-- Botão Perder Todo Dinheiro (NUNCA USE)
FruitTab:Button({
    Title = "💸 PERDER TODO DINHEIRO (NUNCA USE)",
    Desc = "Compra 900 barcos - VAI GASTAR TODO SEU DINHEIRO",
    Callback = function()
        WindUI:Notify({
            Title = "⚠️ AVISO",
            Content = "Isso vai gastar TODO seu dinheiro! Tem certeza?",
            Duration = 5,
            Icon = "alert-triangle",
        })
        
        spawn(function()
            for i = 1, 900 do
                pcall(function()
                    local args = {"BuyBoat", "PirateSloop"}
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                    print("💸 Comprando barco #" .. i)
                    
                    if i % 50 == 0 then
                        WindUI:Notify({
                            Title = "💸 Gastando dinheiro",
                            Content = i .. "/900 barcos comprados",
                            Duration = 2,
                        })
                    end
                end)
                wait(0.3)
            end
            WindUI:Notify({
                Title = "💀 FINALIZADO",
                Content = "900 barcos comprados! Todo dinheiro foi gasto!",
                Duration = 5,
                Icon = "skull",
            })
        end)
    end
})

--------------------------------------------------
--// TAB 3 - BAÚS
--------------------------------------------------
local ChestTab = Window:Tab({
    Title = "Baús",
    Icon = "gift",
})

-- Toggle Auto Coletar Baús
ChestTab:Toggle({
    Title = "Auto Coletar Baús",
    Desc = "Procura e teleporta para baús automaticamente (Chest1, Chest2, Chest3)",
    Icon = "map-pin",
    Value = false,
    Callback = function(state)
        _G.AutoChest = state
        print("🎁 Auto Chest:", state)
        
        if state then
            spawn(function()
                while _G.AutoChest do
                    pcall(function()
                        local character = player.Character
                        if not character then return end
                        
                        -- Procurar baús
                        local chests = {}
                        for _, v in pairs(Workspace:GetDescendants()) do
                            if v:IsA("BasePart") and (v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3") then
                                table.insert(chests, v)
                            end
                        end
                        
                        if #chests > 0 then
                            -- Encontrar baú mais próximo
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
                                -- Teleportar para o baú
                                character.HumanoidRootPart.CFrame = closest.CFrame * CFrame.new(0, 5, 0)
                                print("🎁 Teleportado para baú:", closest.Name)
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
--// TAB 4 - STATUS
--------------------------------------------------
local StatusTab = Window:Tab({
    Title = "Status",
    Icon = "bar-chart",
})

-- Slider para quantidade de pontos
StatusTab:Slider({
    Title = "Quantidade de Pontos",
    Desc = "Quantos pontos adicionar por vez",
    Step = 1,
    Value = {
        Min = 1,
        Max = 100,
        Default = 1,
    },
    Callback = function(value)
        _G.StatusAmount = value
        print("📊 Quantidade de pontos:", value)
    end
})

-- Dropdown para tipo de status
StatusTab:Dropdown({
    Title = "Tipo de Status",
    Desc = "Selecione onde adicionar os pontos",
    Values = { "punch", "espada", "fruta", "arma", "defesa" },
    Value = { "punch" },
    Multi = false,
    Callback = function(options)
        local tipo = options[1]
        if tipo == "punch" then
            _G.StatusType = "Melee"
        elseif tipo == "espada" then
            _G.StatusType = "Sword"
        elseif tipo == "fruta" then
            _G.StatusType = "Demon Fruit"
        elseif tipo == "arma" then
            _G.StatusType = "Gun"
        elseif tipo == "defesa" then
            _G.StatusType = "Defense"
        end
        print("📊 Tipo selecionado:", _G.StatusType)
    end
})

-- Toggle Auto Status
StatusTab:Toggle({
    Title = "Auto Status",
    Desc = "Adiciona pontos automaticamente",
    Icon = "trending-up",
    Value = false,
    Callback = function(state)
        _G.AutoStatus = state
        print("📈 Auto Status:", state)
        
        if state then
            spawn(function()
                while _G.AutoStatus do
                    pcall(function()
                        local args = {"AddPoint", _G.StatusType, _G.StatusAmount}
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                        print("📊 +" .. _G.StatusAmount .. " pontos em " .. _G.StatusType)
                    end)
                    wait(0.5)
                end
            end)
        end
    end
})

--------------------------------------------------
--// TAB 5 - CONFIGURAÇÕES
--------------------------------------------------
local ConfigTab = Window:Tab({
    Title = "Configurações",
    Icon = "settings",
})

-- Toggle Auto Attack
ConfigTab:Toggle({
    Title = "Auto Attack",
    Desc = "Ataca automaticamente mobs próximos",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        _G.AutoAttack = state
        print("⚔️ Auto Attack:", state)
        
        if state then
            spawn(function()
                while _G.AutoAttack do
                    pcall(function()
                        local character = player.Character
                        if not character then return end
                        
                        local enemies = Workspace:FindFirstChild("Enemies")
                        if not enemies then return end
                        
                        local nearest = nil
                        for _, mob in pairs(enemies:GetChildren()) do
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                local dist = (character.HumanoidRootPart.Position - hrp.Position).Magnitude
                                if dist <= 60 then
                                    nearest = hrp
                                    break
                                end
                            end
                        end
                        
                        if nearest then
                            local attackId = tostring(math.random(100000, 999999))
                            local argsAttack = {0.1}
                            ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(unpack(argsAttack))
                            
                            local argsHit = {nearest, {}, [4] = attackId}
                            ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(unpack(argsHit))
                        end
                    end)
                    wait()
                end
            end)
        end
    end
})

-- Toggle Auto Buso
ConfigTab:Toggle({
    Title = "Auto Buso",
    Desc = "Ativa Buso Haki automaticamente",
    Icon = "shield",
    Value = false,
    Callback = function(state)
        _G.AutoBuso = state
        print("🛡️ Auto Buso:", state)
        
        if state then
            spawn(function()
                while _G.AutoBuso do
                    pcall(function()
                        local args = {"Buso"}
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                        print("🛡️ Buso Haki ativado")
                    end)
                    wait(5)
                end
            end)
            
            -- Reconectar após morte
            player.CharacterAdded:Connect(function()
                if _G.AutoBuso then
                    wait(5)
                    spawn(function()
                        while _G.AutoBuso do
                            pcall(function()
                                local args = {"Buso"}
                                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
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
ConfigTab:Toggle({
    Title = "Noclip",
    Desc = "Atravessa paredes (só funciona com tween)",
    Icon = "ghost",
    Value = false,
    Callback = function(state)
        _G.Noclip = state
        print("👻 Noclip:", state)
        
        if state then
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
--// TAB 6 - EXTRAS
--------------------------------------------------
local ExtrasTab = Window:Tab({
    Title = "Extras",
    Icon = "star",
})

-- Botão Remover Texturas
ExtrasTab:Button({
    Title = "Remover Texturas",
    Desc = "Remove todas as texturas do jogo",
    Callback = function()
        pcall(function()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
            end
            WindUI:Notify({
                Title = "🎨 Texturas",
                Content = "Todas as texturas foram removidas!",
                Duration = 3,
            })
        end)
    end
})

-- Botão Tirar Céu
ExtrasTab:Button({
    Title = "Tirar Céu",
    Desc = "Remove céu e neblina",
    Callback = function()
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.new(1, 1, 1)
            
            if Lighting:FindFirstChildOfClass("Sky") then
                Lighting:FindFirstChildOfClass("Sky"):Destroy()
            end
            WindUI:Notify({
                Title = "☀️ Céu",
                Content = "Céu e neblina removidos!",
                Duration = 3,
            })
        end)
    end
})

-- Parágrafo com créditos
ExtrasTab:Paragraph({
    Title = "📌 CRÉDITOS",
    Desc = [[
        👤 Lorenzo
        👤 JX1
        🤖 DeepSeek Interface
        
        Versão: 4.0 Completa
        Data: 2024
        
        Obrigado por usar nosso hub!
    ]],
    Color = "Purple",
})

--------------------------------------------------
--// NOTIFICAÇÃO FINAL
--------------------------------------------------
WindUI:Notify({
    Title = "✅ Hub pronto!",
    Content = "Todas as 6 abas carregadas com sucesso!",
    Duration = 4,
    Icon = "check",
})

print("=== BLOX FRUITS HUB CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
print("⚔️ Hub pronto para uso!")
