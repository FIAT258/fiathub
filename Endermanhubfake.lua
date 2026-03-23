-- Fluent completo
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
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Enderman Hub",
    Content = "UI carregada!",
    Duration = 4
})

local attacking = false
local selectedFruit = "Blade"

-- =====================================
-- LOGICA BLADE (SEM MODIFICAR)
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
-- LOGICA DOUGH (SEM MODIFICAR)
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


-- iniciar ataque
local function startAttack()

if selectedFruit == "Blade" then
startBlade()
end

if selectedFruit == "dough Beta" then
startDough()
end

end


-- UI
Tabs.OP:AddDropdown("FruitSelect", {

Title = "Select Fruit",

Values = {
"Blade",
"dough Beta"
},

Multi = false,
Default = 1

})

Options.FruitSelect:OnChanged(function(Value)

selectedFruit = Value

end)



Tabs.OP:AddToggle("FastAttack", {

Title = "fast attack fruits",

Default = false

})

Options.FastAttack:OnChanged(function(Value)

attacking = Value

if Value then
startAttack()
end

end)



Tabs.OP:AddParagraph({

Title = "BETA",

Content =
[[Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm etc.

usse com outros scripts tipo banana hub ou hoho hub

Ative bring mobs para ficar 100% forte.]]

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
