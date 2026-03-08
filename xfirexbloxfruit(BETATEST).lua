--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    BLOX FRUITS HUB - FLUENT INTERFACE
    by Lorenzo, JX1 & DeepSeek
    Versão 7.0 - Completa e Corrigida
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
_G.AutoAttack = false
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
_G.TweenSpeed = 250
_G.WalkSpeedValue = 16
_G.CurrentQuest = {}
_G.LastLevel = 0
_G.VisitedChests = {}
_G.ChestTPCount = 0

--// LISTA DE COMBATES
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

--// LISTA DE ITENS PARA COMPRA (1º MAR)
local shopItems = {
    "Katana", "Cutlass", "Iron Mace", "Pipe", "Dual Katana",
    "Slingshot", "Flintlock", "Musket", "Refined Flintlock", "Cannon"
}

--// CRIAR JANELA
local Window = Fluent:CreateWindow({
    Title = "XFIREX HUB (BLOX FRUITS) 1 SEA",
    SubTitle = "by Lorenzo, JX1 & DeepSeek",
    TabWidth = 140,
    Size = UDim2.fromOffset(470, 480),
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
    Shop = Window:AddTab({ Title = "Loja", Icon = "shopping-cart" }),
    Chest = Window:AddTab({ Title = "Baús", Icon = "gift" }),
    Status = Window:AddTab({ Title = "Status", Icon = "bar-chart" }),
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

-- Função para criar tween suave
local function TweenTo(goalCFrame, speed)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local distance = (hrp.Position - goalCFrame.Position).Magnitude
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = goalCFrame}
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    return tween
end

-- Função de auto attack (exata)
local function StartAutoAttack()
    task.spawn(function()
        local enemies = workspace:WaitForChild("Enemies")
        local function GetCharacter()
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            return char, hrp
        end

        local function Attack()
            local character, root = GetCharacter()
            if not character or not root then return end

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

            if not nearest then return end

            local attackId = tostring(math.random(100000, 999999))
            pcall(function()
                ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.1)
                ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(nearest, {}, attackId)
            end)
        end

        while _G.AutoAttack do
            Attack()
            task.wait(0.15)
        end
    end)
end

-- Função de auto buso (corrigida)
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

-- Função de auto farm (com lista completa de quests)
local function GetQuestByLevel(level)
    if level >= 1 and level <= 9 then
        return {
            Mon = "Bandit",
            LevelQuest = 1,
            NameQuest = "BanditQuest1",
            NameMon = "Bandit",
            CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544),
            CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        }
    elseif level >= 10 and level <= 14 then
        return {
            Mon = "Monkey",
            LevelQuest = 1,
            NameQuest = "JungleQuest",
            NameMon = "Monkey",
            CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0),
            CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
        }
    elseif level >= 15 and level <= 29 then
        return {
            Mon = "Gorilla",
            LevelQuest = 2,
            NameQuest = "JungleQuest",
            NameMon = "Gorilla",
            CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0),
            CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
        }
    elseif level >= 30 and level <= 39 then
        return {
            Mon = "Pirate",
            LevelQuest = 1,
            NameQuest = "BuggyQuest1",
            NameMon = "Pirate",
            CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627),
            CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
        }
    elseif level >= 40 and level <= 59 then
        return {
            Mon = "Brute",
            LevelQuest = 2,
            NameQuest = "BuggyQuest1",
            NameMon = "Brute",
            CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627),
            CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
        }
    elseif level >= 60 and level <= 74 then
        return {
            Mon = "Desert Bandit",
            LevelQuest = 1,
            NameQuest = "DesertQuest",
            NameMon = "Desert Bandit",
            CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693),
            CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
        }
    elseif level >= 75 and level <= 89 then
        return {
            Mon = "Desert Officer",
            LevelQuest = 2,
            NameQuest = "DesertQuest",
            NameMon = "Desert Officer",
            CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693),
            CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
        }
    elseif level >= 90 and level <= 99 then
        return {
            Mon = "Snow Bandit",
            LevelQuest = 1,
            NameQuest = "SnowQuest",
            NameMon = "Snow Bandit",
            CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685),
            CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
        }
    elseif level >= 100 and level <= 119 then
        return {
            Mon = "Snowman",
            LevelQuest = 2,
            NameQuest = "SnowQuest",
            NameMon = "Snowman",
            CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685),
            CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
        }
    elseif level >= 120 and level <= 149 then
        return {
            Mon = "Chief Petty Officer",
            LevelQuest = 1,
            NameQuest = "MarineQuest2",
            NameMon = "Chief Petty Officer",
            CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0),
            CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
        }
    elseif level >= 150 and level <= 174 then
        return {
            Mon = "Sky Bandit",
            LevelQuest = 1,
            NameQuest = "SkyQuest",
            NameMon = "Sky Bandit",
            CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268),
            CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
        }
    elseif level >= 175 and level <= 189 then
        return {
            Mon = "Dark Master",
            LevelQuest = 2,
            NameQuest = "SkyQuest",
            NameMon = "Dark Master",
            CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268),
            CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
        }
    elseif level >= 190 and level <= 209 then
        return {
            Mon = "Prisoner",
            LevelQuest = 1,
            NameQuest = "PrisonerQuest",
            NameMon = "Prisoner",
            CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712),
            CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
        }
    elseif level >= 210 and level <= 249 then
        return {
            Mon = "Dangerous Prisoner",
            LevelQuest = 2,
            NameQuest = "PrisonerQuest",
            NameMon = "Dangerous Prisoner",
            CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, 0.995993316, -2.06384709e-09, -0.0894274712),
            CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
        }
    elseif level >= 250 and level <= 274 then
        return {
            Mon = "Toga Warrior",
            LevelQuest = 1,
            NameQuest = "ColosseumQuest",
            NameMon = "Toga Warrior",
            CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298),
            CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
        }
    elseif level >= 275 and level <= 299 then
        return {
            Mon = "Gladiator",
            LevelQuest = 2,
            NameQuest = "ColosseumQuest",
            NameMon = "Gladiator",
            CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298),
            CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
        }
    elseif level >= 300 and level <= 324 then
        return {
            Mon = "Military Soldier",
            LevelQuest = 1,
            NameQuest = "MagmaQuest",
            NameMon = "Military Soldier",
            CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469),
            CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
        }
    elseif level >= 325 and level <= 374 then
        return {
            Mon = "Military Spy",
            LevelQuest = 2,
            NameQuest = "MagmaQuest",
            NameMon = "Military Spy",
            CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469),
            CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
        }
    elseif level >= 375 and level <= 399 then
        return {
            Mon = "Fishman Warrior",
            LevelQuest = 1,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Warrior",
            CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
            CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
        }
    elseif level >= 400 and level <= 449 then
        return {
            Mon = "Fishman Commando",
            LevelQuest = 2,
            NameQuest = "FishmanQuest",
            NameMon = "Fishman Commando",
            CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
            CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
        }
    elseif level >= 450 and level <= 474 then
        return {
            Mon = "God's Guard",
            LevelQuest = 1,
            NameQuest = "SkyExp1Quest",
            NameMon = "God's Guard",
            CFrameQuest = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859),
            CFrameMon = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)
        }
    elseif level >= 475 and level <= 524 then
        return {
            Mon = "Shanda",
            LevelQuest = 2,
            NameQuest = "SkyExp1Quest",
            NameMon = "Shanda",
            CFrameQuest = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998),
            CFrameMon = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)
        }
    elseif level >= 525 and level <= 549 then
        return {
            Mon = "Royal Squad",
            LevelQuest = 1,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Squad",
            CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0),
            CFrameMon = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
        }
    elseif level >= 550 and level <= 624 then
        return {
            Mon = "Royal Soldier",
            LevelQuest = 2,
            NameQuest = "SkyExp2Quest",
            NameMon = "Royal Soldier",
            CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0),
            CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
        }
    elseif level >= 625 and level <= 649 then
        return {
            Mon = "Galley Pirate",
            LevelQuest = 1,
            NameQuest = "FountainQuest",
            NameMon = "Galley Pirate",
            CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381),
            CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
        }
    elseif level >= 650 then
        return {
            Mon = "Galley Captain",
            LevelQuest = 2,
            NameQuest = "FountainQuest",
            NameMon = "Galley Captain",
            CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381),
            CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
        }
    end
    return nil
end

-- Função de auto farm
local function StartAutoFarm()
    task.spawn(function()
        while _G.AutoFarm do
            pcall(function()
                local level = CheckLevel()
                if not level then
                    task.wait(1)
                    return
                end

                if level ~= _G.LastLevel then
                    _G.LastLevel = level
                    local quest = GetQuestByLevel(level)
                    if quest then
                        _G.CurrentQuest = quest
                        local args = {"StartQuest", quest.NameQuest, quest.LevelQuest}
                        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
                        
                        -- Teleport para ilhas distantes
                        if quest.CFrameQuest and player.Character then
                            local dist = (player.Character.HumanoidRootPart.Position - quest.CFrameQuest.Position).Magnitude
                            if dist > 10000 then
                                if quest.NameQuest == "FishmanQuest" or quest.NameQuest == "SkyExp1Quest" then
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", quest.CFrameQuest.Position)
                                    task.wait(5)
                                end
                            end
                        end
                    end
                end

                if not _G.CurrentQuest.NameMon then
                    task.wait(1)
                    return
                end

                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end

                local character = player.Character
                if not character then return end

                -- Procurar mob da quest
                local targetMob = nil
                local targetHrp = nil
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                            targetMob = mob
                            targetHrp = hrp
                            break
                        end
                    end
                end

                if not targetHrp and _G.CurrentQuest.CFrameMon then
                    TweenTo(_G.CurrentQuest.CFrameMon * CFrame.new(0, 20, 0), _G.TweenSpeed)
                    task.wait(2)
                    -- Procura novamente após chegar
                    for _, mob in pairs(enemies:GetChildren()) do
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        local hum = mob:FindFirstChild("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                                targetMob = mob
                                targetHrp = hrp
                                break
                            end
                        end
                    end
                end

                if targetHrp then
                    -- Tween para cima do mob
                    TweenTo(targetHrp.CFrame * CFrame.new(0, 20, 0), _G.TweenSpeed)

                    -- Bring mobs
                    if _G.BringMobs then
                        local pulled = 0
                        for _, mob in pairs(enemies:GetChildren()) do
                            if pulled >= 5 then break end
                            local hrp = mob:FindFirstChild("HumanoidRootPart")
                            local hum = mob:FindFirstChild("Humanoid")
                            if hrp and hum and hum.Health > 0 then
                                if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                                    hrp.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -15, 0)
                                    pulled = pulled + 1
                                end
                            end
                        end
                    end

                    -- Espera o mob morrer
                    local start = tick()
                    while targetMob and targetMob:FindFirstChild("Humanoid") and targetMob.Humanoid.Health > 0 do
                        if tick() - start > 30 then break end
                        task.wait(0.5)
                    end

                    -- Conta mortos
                    local dead = 0
                    for _, mob in pairs(enemies:GetChildren()) do
                        local hum = mob:FindFirstChild("Humanoid")
                        if hum and hum.Health <= 0 then
                            if mob.Name:find(_G.CurrentQuest.NameMon) or mob.Name == _G.CurrentQuest.NameMon then
                                dead = dead + 1
                            end
                        end
                    end

                    if dead >= 8 then
                        task.wait(1) -- Aguarda para o próximo loop verificar nível
                    end
                else
                    task.wait(2)
                end
            end)
            task.wait(0.5)
        end
    end)
end

-- Função de auto chest tween
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
                        TweenTo(closest.CFrame * CFrame.new(0, 2, 0), _G.TweenSpeed)
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

-- Função de auto chest teleporte (ban risk)
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

-- Função de spin fruit
local function StartSpinFruit()
    task.spawn(function()
        while _G.SpinFruit do
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy", "DLCBoxData")
            end)
            task.wait(7200) -- 2 horas
        end
    end)
end

-- Função para remover texturas (melhorada)
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
        -- Opcional: remover também de partes específicas
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

-- Função para resgatar códigos
local function RedeemAllCodes()
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
    task.spawn(function()
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
            Content = "Todos os códigos foram resgatados!",
            Duration = 5
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
    Description = "Faz farm automático de níveis",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            _G.LastLevel = CheckLevel() or 0
            StartAutoFarm()
        end
    end
})

Tabs.Farm:AddToggle("BringMobs", {
    Title = "Bring Mobs",
    Description = "Puxa os mobs para perto de você",
    Default = false,
    Callback = function(Value)
        _G.BringMobs = Value
    end
})

-- Aba Frutas
Tabs.Fruits:AddToggle("SpinFruit", {
    Title = "Spin Fruit",
    Description = "Compra spin de fruta a cada 2 horas",
    Default = false,
    Callback = function(Value)
        _G.SpinFruit = Value
        if Value then
            StartSpinFruit()
        end
    end
})

-- Aba Loja
for _, itemName in ipairs(shopItems) do
    Tabs.Shop:AddButton({
        Title = "Comprar " .. itemName,
        Description = "Compra " .. itemName .. " na loja",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", itemName)
                Fluent:Notify({
                    Title = "Loja",
                    Content = itemName .. " comprado!",
                    Duration = 3
                })
            end)
        end
    })
end

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
    Description = "Resgata todos os códigos de uma vez",
    Callback = RedeemAllCodes
})

Tabs.Extras:AddParagraph({
    Title = "📌 CRÉDITOS",
    Content = "👤 Lorenzo\n👤 JX1\n🤖 DeepSeek Interface\n\nVersão: 7.0 Fluent\nObrigado por usar nosso hub!"
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
