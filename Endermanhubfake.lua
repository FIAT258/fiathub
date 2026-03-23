-- Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
-- Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Enderman Hub",
    SubTitle = "blox fruts troll",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    OP = Window:AddTab({ Title = "OP", Icon = "zap" }),
    Updates = Window:AddTab({ Title = "Updates", Icon = "history" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Enderman Hub",
    Content = "v1.1 carregado",
    Duration = 4
})

local attacking = false
local selectedFruit = "Blade"

-- =====================================
-- FAST ATTACK SOCO / ESPADA / FRUIT
-- (SEM MODIFICAR LOGICA)
-- =====================================
local fastAttackMelee = true

task.spawn(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function getEnemies(root)

    local list = {}

    for _, mob in ipairs(enemiesFolder:GetChildren()) do

        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then

            local dist = (root.Position - hrp.Position).Magnitude

            if dist <= 60 then
                table.insert(list, hrp)
            end

        end
    end

    return list
end


while true do

    if fastAttackMelee then

        local root = getRoot()

        local enemies = getEnemies(root)

        for _, target in ipairs(enemies) do

            local attackId = tostring(math.random(100000,999999))

            pcall(function()

                RegisterAttack:FireServer(0.1)

                task.wait(0.02)

                RegisterHit:FireServer(
                    target,
                    {},
                    nil,
                    attackId
                )

            end)

        end

    end

    task.wait(0.03)

end

end)



-- =====================================
-- BLADE (LOGICA ORIGINAL)
-- =====================================
local function startBlade()

task.spawn(function()

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local remote = character:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")

local combo = 1

player.CharacterAdded:Connect(function(char)

    character = char
    root = char:WaitForChild("HumanoidRootPart")

    remote = char:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")

end)


while attacking and selectedFruit == "Blade" do

    local nearest
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

        combo += 1
        if combo > 2 then
            combo = 1
        end

    end

    task.wait()

end

end)

end


-- =====================================
-- DOUGH (LOGICA ORIGINAL)
-- =====================================
local function startDough()

task.spawn(function()

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

player.CharacterAdded:Connect(function(c)

    char = c
    root = char:WaitForChild("HumanoidRootPart")

    remote = getRemote()

end)

local RANGE = 80


while attacking and selectedFruit == "dough Beta" do

    local nearest
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

        root.CFrame = CFrame.lookAt(
            root.Position,
            nearest.Position
        )

        pcall(function()

            remote:InvokeServer("TAP")

        end)

    end


    task.wait(0.04)

end

end)

end


local function startFruit()

if selectedFruit == "Blade" then
startBlade()
end

if selectedFruit == "dough Beta" then
startDough()
end

end


-- =====================================
-- UI
-- =====================================

Tabs.OP:AddToggle("FastMelee", {
    Title = "fast attack recomendado soco/espada/fruit",
    Default = true
})

Options.FastMelee:OnChanged(function(v)
    fastAttackMelee = v
end)


Tabs.OP:AddDropdown("FruitSelect", {

    Title = "Select Fruit",

    Values = {
        "Blade",
        "dough Beta"
    },

    Multi = false,
    Default = 1

})

Options.FruitSelect:OnChanged(function(v)

    selectedFruit = v

end)



Tabs.OP:AddToggle("FastFruit", {

    Title = "fast attack fruits",

    Default = false

})

Options.FastFruit:OnChanged(function(v)

    attacking = v

    if v then
        startFruit()
    end

end)



Tabs.OP:AddParagraph({

Title = "BETA",

Content =
[[Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm etc.

use com banana hub ou hoho hub

Ative bring mobs para ficar 100% forte.]]

})


-- =====================================
-- UPDATES
-- =====================================

Tabs.Updates:AddParagraph({

Title = "v1.1 lançamento",

Content =
[[+ adicionado fast attack soco/espada/fruit
+ adicionado suporte blade
+ adicionado suporte dough beta
+ sistema config
+ melhorias de velocidade
+ nova aba updates]]

})


-- managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("EndermanHub")
SaveManager:SetFolder("EndermanHub/bloxfruits")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Enderman Hub",
    SubTitle = "blox fruts troll",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    OP = Window:AddTab({ Title = "OP", Icon = "zap" }),
    Updates = Window:AddTab({ Title = "Updates", Icon = "history" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Enderman Hub",
    Content = "v1.1 carregado",
    Duration = 4
})

local attacking = false
local selectedFruit = "Blade"

-- =====================================
-- FAST ATTACK SOCO / ESPADA / FRUIT
-- (SEM MODIFICAR LOGICA)
-- =====================================
local fastAttackMelee = true

task.spawn(function()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function getEnemies(root)

    local list = {}

    for _, mob in ipairs(enemiesFolder:GetChildren()) do

        local hum = mob:FindFirstChildOfClass("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")

        if hum and hrp and hum.Health > 0 then

            local dist = (root.Position - hrp.Position).Magnitude

            if dist <= 60 then
                table.insert(list, hrp)
            end

        end
    end

    return list
end


while true do

    if fastAttackMelee then

        local root = getRoot()

        local enemies = getEnemies(root)

        for _, target in ipairs(enemies) do

            local attackId = tostring(math.random(100000,999999))

            pcall(function()

                RegisterAttack:FireServer(0.1)

                task.wait(0.02)

                RegisterHit:FireServer(
                    target,
                    {},
                    nil,
                    attackId
                )

            end)

        end

    end

    task.wait(0.03)

end

end)



-- =====================================
-- BLADE (LOGICA ORIGINAL)
-- =====================================
local function startBlade()

task.spawn(function()

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local remote = character:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")

local combo = 1

player.CharacterAdded:Connect(function(char)

    character = char
    root = char:WaitForChild("HumanoidRootPart")

    remote = char:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")

end)


while attacking and selectedFruit == "Blade" do

    local nearest
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

        combo += 1
        if combo > 2 then
            combo = 1
        end

    end

    task.wait()

end

end)

end


-- =====================================
-- DOUGH (LOGICA ORIGINAL)
-- =====================================
local function startDough()

task.spawn(function()

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

player.CharacterAdded:Connect(function(c)

    char = c
    root = char:WaitForChild("HumanoidRootPart")

    remote = getRemote()

end)

local RANGE = 80


while attacking and selectedFruit == "dough Beta" do

    local nearest
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

        root.CFrame = CFrame.lookAt(
            root.Position,
            nearest.Position
        )

        pcall(function()

            remote:InvokeServer("TAP")

        end)

    end


    task.wait(0.04)

end

end)

end


local function startFruit()

if selectedFruit == "Blade" then
startBlade()
end

if selectedFruit == "dough Beta" then
startDough()
end

end


-- =====================================
-- UI
-- =====================================

Tabs.OP:AddToggle("FastMelee", {
    Title = "fast attack recomendado soco/espada/fruit",
    Default = true
})

Options.FastMelee:OnChanged(function(v)
    fastAttackMelee = v
end)


Tabs.OP:AddDropdown("FruitSelect", {

    Title = "Select Fruit",

    Values = {
        "Blade",
        "dough Beta"
    },

    Multi = false,
    Default = 1

})

Options.FruitSelect:OnChanged(function(v)

    selectedFruit = v

end)



Tabs.OP:AddToggle("FastFruit", {

    Title = "fast attack fruits",

    Default = false

})

Options.FastFruit:OnChanged(function(v)

    attacking = v

    if v then
        startFruit()
    end

end)



Tabs.OP:AddParagraph({

Title = "BETA",

Content =
[[Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm etc.

use com banana hub ou hoho hub

Ative bring mobs para ficar 100% forte.]]

})


-- =====================================
-- UPDATES
-- =====================================

Tabs.Updates:AddParagraph({

Title = "v1.1 lançamento",

Content =
[[+ adicionado fast attack soco/espada/fruit
+ adicionado suporte blade
+ adicionado suporte dough beta
+ sistema config
+ melhorias de velocidade
+ nova aba updates]]

})


-- managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("EndermanHub")
SaveManager:SetFolder("EndermanHub/bloxfruits")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
