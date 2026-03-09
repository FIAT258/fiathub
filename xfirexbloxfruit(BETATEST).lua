--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝

    BLOX FRUITS HUB - WINDUI (VERSÃO FUNCIONAL)
    by Lorenzo, JX1 & DeepSeek
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
_G.AutoStore = false
_G.AutoBuso = false
_G.BringMobs = false
_G.AutoChestTween = false
_G.AutoChestTP = false
_G.Noclip = false
_G.AutoStatus = false
_G.SpinFruit = false
_G.AutoSpeed = false
_G.AutoAttack = false
_G.SelectedWeapon = "punch"
_G.StatusType = "Melee"
_G.StatusAmount = 1
_G.WalkSpeedValue = 16
_G.TweenSpeed = 250
_G.CurrentQuest = {}
_G.LastQuestLevel = 0
_G.VisitedChests = {}
_G.ChestTPCount = 0

-- Lista de frutas para store
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

-- Criar janela principal (igual ao exemplo)
local Window = WindUI:CreateWindow({
    Title = "NIGHT SHADOW HUB BLOX FRUITS",
    Icon = "sword",
    Author = "by night shadow club",
    Folder = "BloxFruitsHub",
    Size = UDim2.fromOffset(650, 520),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 220,
    Background = "rbxassetid://132282775793854" -- opcional
})

-- Notificação inicial
WindUI:Notify({
    Title = "BLOX FRUITS HUB",
    Content = "Interface WindUI carregada!",
    Duration = 4
})

-- Criar abas (igual ao exemplo)
local FarmTab = Window:Tab({ Title = "Farm", Icon = "sword" })
local FruitTab = Window:Tab({ Title = "Frutas", Icon = "apple" })
local ChestTab = Window:Tab({ Title = "Baús", Icon = "gift" })
local StatusTab = Window:Tab({ Title = "Status", Icon = "bar-chart" })
local ShopTab = Window:Tab({ Title = "Loja", Icon = "shopping-cart" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })
local ExtrasTab = Window:Tab({ Title = "Extras", Icon = "star" })

----------------------------------------------------------
-- FUNÇÕES AUXILIARES (mesmas do Fluent)
----------------------------------------------------------

local function CheckLevel()
    local success, level = pcall(function()
        return player.Data.Level.Value
    end)
    return success and level or nil
end

local function TweenToTarget(targetPart, offsetY)
    local character = player.Character
    if not character or not targetPart then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetPart.CFrame * CFrame.new(0, offsetY or 20, 0)}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    return tween
end

local function GetQuestByLevel(level)
    if level >= 1 and level <= 9 then
        return { Mon = "Bandit", LevelQuest = 1, NameQuest = "BanditQuest1", NameMon = "Bandit" }
    elseif level >= 10 and level <= 14 then
        return { Mon = "Monkey", LevelQuest = 1, NameQuest = "JungleQuest", NameMon = "Monkey" }
    elseif level >= 15 and level <= 29 then
        return { Mon = "Gorilla", LevelQuest = 2, NameQuest = "JungleQuest", NameMon = "Gorilla" }
    elseif level >= 30 and level <= 39 then
        return { Mon = "Pirate", LevelQuest = 1, NameQuest = "BuggyQuest1", NameMon = "Pirate" }
    elseif level >= 40 and level <= 59 then
        return { Mon = "Brute", LevelQuest = 2, NameQuest = "BuggyQuest1", NameMon = "Brute" }
    elseif level >= 60 and level <= 74 then
        return { Mon = "Desert Bandit", LevelQuest = 1, NameQuest = "DesertQuest", NameMon = "Desert Bandit" }
    elseif level >= 75 and level <= 89 then
        return { Mon = "Desert Officer", LevelQuest = 2, NameQuest = "DesertQuest", NameMon = "Desert Officer" }
    elseif level >= 90 and level <= 99 then
        return { Mon = "Snow Bandit", LevelQuest = 1, NameQuest = "SnowQuest", NameMon = "Snow Bandit" }
    elseif level >= 100 and level <= 119 then
        return { Mon = "Snowman", LevelQuest = 2, NameQuest = "SnowQuest", NameMon = "Snowman" }
    elseif level >= 120 and level <= 149 then
        return { Mon = "Chief Petty Officer", LevelQuest = 1, NameQuest = "MarineQuest2", NameMon = "Chief Petty Officer" }
    elseif level >= 150 and level <= 174 then
        return { Mon = "Sky Bandit", LevelQuest = 1, NameQuest = "SkyQuest", NameMon = "Sky Bandit" }
    elseif level >= 175 and level <= 189 then
        return { Mon = "Dark Master", LevelQuest = 2, NameQuest = "SkyQuest", NameMon = "Dark Master" }
    elseif level >= 190 and level <= 209 then
        return { Mon = "Prisoner", LevelQuest = 1, NameQuest = "PrisonerQuest", NameMon = "Prisoner" }
    elseif level >= 210 and level <= 249 then
        return { Mon = "Dangerous Prisoner", LevelQuest = 2, NameQuest = "PrisonerQuest", NameMon = "Dangerous Prisoner" }
    elseif level >= 250 and level <= 274 then
        return { Mon = "Toga Warrior", LevelQuest = 1, NameQuest = "ColosseumQuest", NameMon = "Toga Warrior" }
    elseif level >= 275 and level <= 299 then
        return { Mon = "Gladiator", LevelQuest = 2, NameQuest = "ColosseumQuest", NameMon = "Gladiator" }
    elseif level >= 300 and level <= 324 then
        return { Mon = "Military Soldier", LevelQuest = 1, NameQuest = "MagmaQuest", NameMon = "Military Soldier" }
    elseif level >= 325 and level <= 374 then
        return { Mon = "Military Spy", LevelQuest = 2, NameQuest = "MagmaQuest", NameMon = "Military Spy" }
    elseif level >= 375 and level <= 399 then
        return { Mon = "Fishman Warrior", LevelQuest = 1, NameQuest = "FishmanQuest", NameMon = "Fishman Warrior" }
    elseif level >= 400 and level <= 449 then
        return { Mon = "Fishman Commando", LevelQuest = 2, NameQuest = "FishmanQuest", NameMon = "Fishman Commando" }
    elseif level >= 450 and level <= 474 then
        return { Mon = "God's Guard", LevelQuest = 1, NameQuest = "SkyExp1Quest", NameMon = "God's Guard" }
    elseif level >= 475 and level <= 524 then
        return { Mon = "Shanda", LevelQuest = 2, NameQuest = "SkyExp1Quest", NameMon = "Shanda" }
    elseif level >= 525 and level <= 549 then
        return { Mon = "Royal Squad", LevelQuest = 1, NameQuest = "SkyExp2Quest", NameMon = "Royal Squad" }
    elseif level >= 550 and level <= 624 then
        return { Mon = "Royal Soldier", LevelQuest = 2, NameQuest = "SkyExp2Quest", NameMon = "Royal Soldier" }
    elseif level >= 625 and level <= 649 then
        return { Mon = "Galley Pirate", LevelQuest = 1, NameQuest = "FountainQuest", NameMon = "Galley Pirate" }
    elseif level >= 650 then
        return { Mon = "Galley Captain", LevelQuest = 2, NameQuest = "FountainQuest", NameMon = "Galley Captain" }
    end
    return nil
end

-- Auto Attack (loop 0.15s)
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

-- Auto Buso (uma vez e reativa 6s após morte)
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
            connection:Disconnect()
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
                    if humanoid then
                        humanoid.WalkSpeed = _G.WalkSpeedValue
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

-- Auto Farm
local function StartAutoFarm()
    task.spawn(function()
        while _G.AutoFarm do
            pcall(function()
                local level = CheckLevel()
                if not level then task.wait(1) return end
                if level > _G.LastQuestLevel then
                    _G.LastQuestLevel = level
                    local quest = GetQuestByLevel(level)
                    if quest then
                        _G.CurrentQuest = quest
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.NameQuest, quest.LevelQuest)
                    end
                end
                if not _G.CurrentQuest or not _G.CurrentQuest.NameMon then task.wait(1) return end
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then task.wait(1) return end
                local character = player.Character
                if not character then task.wait(1) return end
                local targetMob, targetHRP
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                            targetMob, targetHRP = mob, hrp
                            break
                        end
                    end
                end
                if targetHRP then
                    TweenToTarget(targetHRP, 20)
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
                    task.wait(0.3)
                else
                    task.wait(1)
                end
            end)
        end
    end)
end

-- Auto Chest Tween (não repete baús)
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
                    local closest, closestDist = nil, math.huge
                    for _, chest in pairs(chests) do
                        local dist = (character.HumanoidRootPart.Position - chest.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = chest
                        end
                    end
                    if closest then
                        TweenToTarget(closest, 2)
                        _G.VisitedChests[tostring(closest.Position)] = true
                        task.wait(1)
                    end
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

-- Spin Fruit (2h)
local function StartSpinFruit()
    task.spawn(function()
        while _G.SpinFruit do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
            end)
            task.wait(7200)
        end
    end)
end

-- Remover texturas
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
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Texture = ""
                v.Material = Enum.Material.Plastic
            end
        end
        WindUI:Notify({ Title = "Texturas", Content = "Todas as texturas foram removidas!", Duration = 3 })
    end)
end

-- Redeem all codes
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
        for i, code in ipairs(codes) do
            pcall(function() redeemRemote:InvokeServer(code) end)
            if i < #codes then task.wait(0.3) end
        end
        WindUI:Notify({ Title = "Códigos", Content = "Resgate concluído!", Duration = 4 })
    end)
end

----------------------------------------------------------
-- CONSTRUÇÃO DA INTERFACE (WINDUI)
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
    Title = "Auto Farm",
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
    Title = "Bring Mobs",
    Default = false,
    Callback = function(state) _G.BringMobs = state end
})

-- Aba Frutas
FruitTab:Toggle({
    Title = "Auto Store Frutas (0.3s)",
    Default = false,
    Callback = function(state)
        _G.AutoStore = state
        if state then
            task.spawn(function()
                while _G.AutoStore do
                    pcall(function()
                        local bp = player.Backpack
                        local char = player.Character
                        for _, tool in pairs(bp:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruit in pairs(frutas) do
                                    if tool.Name:find(fruit) or tool.Name == fruit then
                                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruit, tool)
                                        break
                                    end
                                end
                            end
                        end
                        for _, tool in pairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, fruit in pairs(frutas) do
                                    if tool.Name:find(fruit) or tool.Name == fruit then
                                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruit, tool)
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

FruitTab:Toggle({
    Title = "Spin Fruit (2h)",
    Default = false,
    Callback = function(state)
        _G.SpinFruit = state
        if state then StartSpinFruit() end
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

-- Aba Extras
ExtrasTab:Button({
    Title = "Remover Texturas",
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

ExtrasTab:Button({
    Title = "Redeem All Codes",
    Callback = RedeemAllCodes
})

ExtrasTab:Paragraph({
    Title = "📌 CRÉDITOS",
    Desc = "👤 Lorenzo\n👤 JX1\n🤖 DeepSeek Interface\n\nVersão: WindUI 2.0\nObrigado por usar nosso hub"
})

-- Notificação final
WindUI:Notify({
    Title = "BLOX FRUITS HUB",
    Content = "Hub carregado com WindUI!",
    Duration = 5
})

print("=== BLOX FRUITS HUB (WindUI) CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
