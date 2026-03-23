-- carregar UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- janela
local Window = WindUI:CreateWindow({
    Title = "Enderman Hub",
    Icon = "crown",
    Author = "by Enderman",
    Subtitle = "blox fruts troll",
    Folder = "EndermanHub",
    Size = UDim2.fromOffset(500, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,

    KeySystem = {
        Key = {"Endermanhub-key-130-KEY/LUA"},
        Note = "Key salva para sempre",
        URL = "https://linkvertise.com/1460648/0qx6liYVnx53?o=sharing",
            SaveKey = true
    }
})

-- notificação
WindUI:Notify({
    Title = "Enderman Hub",
    Content = "UI carregada",
    Duration = 3
})

-- serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local enemies = workspace:WaitForChild("Enemies")

-- variáveis
local selectedFruit = "Blade"
local attacking = false

local character
local root
local bladeRemote
local doughRemote

local combo = 1

-- atualizar personagem
local function updateCharacter()

    character = player.Character or player.CharacterAdded:Wait()

    root = character:WaitForChild("HumanoidRootPart")

    bladeRemote = nil
    doughRemote = nil

    -- blade remote
    pcall(function()
        bladeRemote = character:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")
    end)

    -- dough remote
    pcall(function()

        local hum = character:WaitForChild("Humanoid")

        for _,v in pairs(hum:GetChildren()) do

            if v:IsA("RemoteFunction") then
                doughRemote = v
            end

        end

    end)

end

updateCharacter()

player.CharacterAdded:Connect(function()

    task.wait(1)
    updateCharacter()

end)


-- encontrar inimigo
local function getNearest(range)

    if not root then return end

    local nearest
    local shortest = math.huge

    for _,mob in pairs(enemies:GetChildren()) do

        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local dist = (root.Position - hrp.Position).Magnitude

            if dist < shortest and dist <= range then

                shortest = dist
                nearest = hrp

            end

        end

    end

    return nearest

end


-- loop blade
local function bladeLoop()

    task.spawn(function()

        while attacking and selectedFruit == "Blade" do

            local enemy = getNearest(120)

            if enemy and bladeRemote then

                local dir = (enemy.Position - root.Position).Unit

                bladeRemote:FireServer(dir, combo)

                combo += 1

                if combo > 2 then
                    combo = 1
                end

            end

            task.wait()

        end

    end)

end


-- loop dough
local function doughLoop()

    task.spawn(function()

        while attacking and selectedFruit == "dough Beta" do

            local enemy = getNearest(120)

            if enemy and doughRemote then

                root.CFrame = CFrame.lookAt(root.Position, enemy.Position)

                pcall(function()
                    doughRemote:InvokeServer("TAP")
                end)

            end

            task.wait(0.03)

        end

    end)

end


-- iniciar ataque
local function startAttack()

    if selectedFruit == "Blade" then
        bladeLoop()
    end

    if selectedFruit == "dough Beta" then
        doughLoop()
    end

end


-- TAB
local Tab = Window:Tab({
    Title = "OP",
    Icon = "zap"
})


-- dropdown
Tab:Dropdown({

    Title = "Fruta",
    Values = {"Blade","dough Beta"},
    Value = "Blade",

    Callback = function(v)

        selectedFruit = v

    end

})


-- toggle
Tab:Toggle({

    Title = "fast attack fruits",

    Value = false,

    Callback = function(v)

        attacking = v

        if v then
            startAttack()
        end

    end

})


-- texto
Tab:Paragraph({

    Title = "BETA",

    Desc = "Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm é etc usse com outros scripts tipo banana hub ó recomendo são hoho hub\nAtive bring mobs para ficar 100% forte."

})
