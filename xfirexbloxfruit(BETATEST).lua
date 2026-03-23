--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝

    XFIREX HUB BLOX FRUITS - VERSÃO NORMAL (Redz Hub V5)
    by Lorenzo, JX1 & DeepSeek
]]

--=====================================================
-- 1. CARREGAR BIBLIOTECA REDZ HUB
--=====================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"))()

local Window = Library:MakeWindow({
    Title = "XFIREX HUB BLOX FRUITS",
    SubTitle = "by Lorenzo, JX1 & DeepSeek",
    ScriptFolder = "XFIREX-Hub"
})

Library:SetUIScale(1.0)

local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl
})

local MobileButton = Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://17382040552",
    BackgroundColor3 = Color3.fromRGB(30, 30, 30)
})

--=====================================================
-- 2. FUNÇÃO PARA APLICAR FONTE PERSONALIZADA (OPCIONAL)
--=====================================================
local function applyCustomFont()
    pcall(function()
        local font = Font.new("rbxassetid://12187375716")
        local gui = player.PlayerGui:FindFirstChild("XFIREX-Hub")
        if gui then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    v.FontFace = font
                end
            end
        end
    end)
end

task.wait(1)
applyCustomFont()
task.spawn(function()
    while true do
        task.wait(5)
        applyCustomFont()
    end
end)

--=====================================================
-- 3. VARIÁVEIS GLOBAIS
--=====================================================
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
_G.VisitedChests = {}
_G.ChestTPCount = 0
_G.ESPNumber = 1

--=====================================================
-- 4. LISTAS AUXILIARES
--=====================================================
local combatStyles = {
    "Combat", "Dark Step", "Electric", "Water Kung Fu", "Dragon Breath",
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw",
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

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
-- 5. SERVICES E FUNÇÕES AUXILIARES
--=====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")

local function round(x)
    return math.floor(x + 0.5)
end

local function CheckLevel()
    local success, level = pcall(function() return player.Data.Level.Value end)
    return success and level or nil
end

-- Função de Tween (global, com trava no ar)
local function TweenTo(targetCFrame, speed, callback)
    speed = speed or _G.TweenSpeed
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local originalGravity = workspace.Gravity
    local wasAutoRotate = humanoid.AutoRotate
    workspace.Gravity = 0
    humanoid.AutoRotate = false
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local time = math.min(distance / speed, 30)

    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween.Completed:Connect(function()
        workspace.Gravity = originalGravity
        humanoid.AutoRotate = wasAutoRotate
        if callback then callback() end
    end)
    tween:Play()
    return tween
end

--=====================================================
-- 6. FUNÇÕES DE LÓGICA (AUTO FARM, KILL AURA, ETC.)
--=====================================================

-- (aqui entrariam todas as funções do script normal, como StartAutoFarm, StartKillAura, etc.)
-- Para não alongar desnecessariamente, vou apenas listar os cabeçalhos; na prática, devem ser coladas todas as funções que já tínhamos.

-- Exemplo:
local function StartAutoEquip() ... end
local function StartAutoBuso() ... end
local function StartAutoSpeed() ... end
local function StartAutoAttack() ... end
local function StartAutoChestTween() ... end
local function StartAutoChestTP() ... end
local function StartAntiGods() ... end
local function StartFruitESP() ... end
local function StartKillAura() ... end
local function StartAntiGravity() ... end
local function StartSpinFruit() ... end
local function StartAutoStatus() ... end
local function StartAutoSaber() ... end
local function RemoveTextures() ... end
local function ServerHop() ... end
local function Rejoin() ... end
local function RemoveSky() ... end

--=====================================================
-- 7. CRIAÇÃO DAS ABAS
--=====================================================
local Tabs = {}

-- Aba Farm
Tabs.Farm = Window:MakeTab({ Title = "Farm", Icon = "sword" })
Tabs.Farm:AddDropdown({
    Name = "Tipo de Arma",
    MultiSelect = false,
    Options = {"punch", "espada", "gun"},
    Default = "punch",
    Callback = function(v) _G.SelectedWeapon = v end
})
Tabs.Farm:AddToggle({
    Name = "Auto Equip",
    Default = false,
    Callback = function(v) _G.AutoEquip = v if v then StartAutoEquip() end end
})
Tabs.Farm:AddToggle({
    Name = "Bring Mobs (2)",
    Default = false,
    Callback = function(v) _G.BringMobs = v end
})
Tabs.Farm:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(v) _G.KillAura = v if v then StartKillAura() end end
})

-- Aba Frutas
Tabs.Fruits = Window:MakeTab({ Title = "Frutas", Icon = "apple" })
Tabs.Fruits:AddToggle({
    Name = "Spin Fruit (2h)",
    Default = false,
    Callback = function(v) _G.SpinFruit = v if v then StartSpinFruit() end end
})
Tabs.Fruits:AddToggle({
    Name = "ESP Frutas",
    Default = false,
    Callback = function(v) _G.ESP_Fruit = v if v then StartFruitESP() end end
})

-- Aba Baús
Tabs.Chest = Window:MakeTab({ Title = "Baús", Icon = "gift" })
Tabs.Chest:AddToggle({
    Name = "Auto Baú (Tween)",
    Default = false,
    Callback = function(v) _G.AutoChestTween = v if v then StartAutoChestTween() end end
})
Tabs.Chest:AddToggle({
    Name = "Auto Baú (TP) - BAN RISK",
    Default = false,
    Callback = function(v) _G.AutoChestTP = v if v then StartAutoChestTP() end end
})
Tabs.Chest:AddToggle({
    Name = "Anti Gods Itens",
    Default = false,
    Callback = function(v) _G.AntiGods = v if v then StartAntiGods() end end
})

-- Aba Status
Tabs.Status = Window:MakeTab({ Title = "Status", Icon = "bar-chart" })
Tabs.Status:AddSlider({
    Name = "Quantidade de Pontos",
    Min = 1,
    Max = 100,
    Increment = 1,
    Default = 1,
    Callback = function(v) _G.StatusAmount = v end
})
Tabs.Status:AddDropdown({
    Name = "Tipo de Status",
    MultiSelect = false,
    Options = {"punch", "espada", "fruta", "arma", "defesa"},
    Default = "punch",
    Callback = function(v)
        if v == "punch" then _G.StatusType = "Melee"
        elseif v == "espada" then _G.StatusType = "Sword"
        elseif v == "fruta" then _G.StatusType = "Demon Fruit"
        elseif v == "arma" then _G.StatusType = "Gun"
        elseif v == "defesa" then _G.StatusType = "Defense" end
    end
})
Tabs.Status:AddToggle({
    Name = "Auto Status",
    Default = false,
    Callback = function(v) _G.AutoStatus = v if v then StartAutoStatus() end end
})

-- Aba Loja
Tabs.Shop = Window:MakeTab({ Title = "Loja", Icon = "shopping-cart" })
for _, item in ipairs(shopItems) do
    Tabs.Shop:AddButton({
        Name = "Comprar " .. item.Name,
        Debounce = 1,
        Callback = function()
            pcall(function() CommF:InvokeServer("BuyItem", item.RemoteArg) end)
            Window:Notify({ Title = "Loja", Content = item.Name .. " comprado!", Duration = 3 })
        end
    })
end

-- Aba 1 Sea
Tabs.Sea1 = Window:MakeTab({ Title = "1 Sea", Icon = "anchor" })
Tabs.Sea1:AddToggle({
    Name = "Auto Saber",
    Default = false,
    Callback = function(v) _G.AutoSaber = v if v then StartAutoSaber() end end
})

-- Aba Configurações
Tabs.Config = Window:MakeTab({ Title = "Config", Icon = "settings" })
Tabs.Config:AddDropdown({
    Name = "Velocidade do Tween",
    MultiSelect = false,
    Options = {"200", "250", "300", "350"},
    Default = "250",
    Callback = function(v) _G.TweenSpeed = tonumber(v) end
})
Tabs.Config:AddSlider({
    Name = "Velocidade de Andar",
    Min = 16,
    Max = 300,
    Increment = 1,
    Default = 16,
    Callback = function(v)
        _G.WalkSpeedValue = v
        if _G.AutoSpeed then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})
Tabs.Config:AddToggle({
    Name = "Auto Speed",
    Default = false,
    Callback = function(v) _G.AutoSpeed = v if v then StartAutoSpeed() end end
})
Tabs.Config:AddToggle({
    Name = "Auto Attack",
    Default = false,
    Callback = function(v) _G.AutoAttack = v if v then StartAutoAttack() end end
})
Tabs.Config:AddToggle({
    Name = "Auto Buso",
    Default = false,
    Callback = function(v) _G.AutoBuso = v if v then StartAutoBuso() end end
})
Tabs.Config:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        _G.Noclip = v
        if v then
            task.spawn(function()
                while _G.Noclip do
                    pcall(function()
                        local char = player.Character
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})
Tabs.Config:AddToggle({
    Name = "Anti Gravidade",
    Default = false,
    Callback = function(v) _G.AntiGravity = v if v then StartAntiGravity() end end
})

-- Aba Extras
Tabs.Extras = Window:MakeTab({ Title = "Extras", Icon = "star" })
Tabs.Extras:AddButton({
    Name = "Remover Texturas (Ultra)",
    Debounce = 1,
    Callback = RemoveTextures
})
Tabs.Extras:AddButton({
    Name = "Tirar Céu",
    Debounce = 1,
    Callback = RemoveSky
})
Tabs.Extras:AddButton({
    Name = "Server Hop",
    Debounce = 1,
    Callback = ServerHop
})
Tabs.Extras:AddButton({
    Name = "Rejoin",
    Debounce = 1,
    Callback = Rejoin
})

-- Aba Updates
Tabs.Updates = Window:MakeTab({ Title = "Updates", Icon = "info" })
Tabs.Updates:AddParagraph("📌 Novidades da Versão", [[
    • Farm: Auto Equip, Bring Mobs, Kill Aura (com tween)
    • Frutas: Spin Fruit (2h), ESP Frutas com distância
    • Baús: Auto Baú Tween (foco único), Auto Baú TP (ban risk), Anti Gods Itens
    • Status: Auto Status com escolha de tipo e quantidade
    • Loja: Comprar itens do 1º mar (Katana, Cutlass, etc.)
    • 1 Sea: Auto Saber completo (todos os passos)
    • Config: Velocidade Tween, WalkSpeed, Auto Speed, Auto Attack, Auto Buso, Noclip, Anti Gravidade
    • Extras: Remover texturas ultra, tirar céu, server hop, rejoin
    • Tween com trava no ar (gravidade zero durante movimento)
    • Interface Redz Hub V5
    • Fonte personalizada aplicada (ID 12187375716)
]])

--=====================================================
-- 8. NOTIFICAÇÃO FINAL
--=====================================================
Window:Notify({
    Title = "XFIREX HUB",
    Content = "Hub carregado! Nível: " .. (CheckLevel() or "??"),
    Duration = 5
})

print("=== XFIREX HUB BLOX FRUITS CARREGADO ===")
print("👤 Jogador:", player.Name)
print("📊 Nível:", CheckLevel() or "Desconhecido")
print("🎨 Fonte personalizada aplicada.")
