-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela principal
local Window = WindUI:CreateWindow({
    Title = "Enderman Hub",
    Icon = "crown",
    Author = "by Enderman",
    Subtitle = "blox fruts troll",
    Folder = "EndermanHub",
    Size = UDim2.fromOffset(500, 400),
    MinSize = Vector2.new(450, 350),
    MaxSize = Vector2.new(700, 500),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 180,
    HideSearchBar = true,
    KeySystem = {
        Key = {"Endermanhub-key-130-KEY/LUA"},
        Note = "KEY SALVA PARA TODA VIDA antes de dúvidas mais coisas no hub em breve",
        URL = "https://linkvertise.com/1460648/0qx6liYVnx53?o=sharing",
        SaveKey = true,
    }
})

Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#ff6a30"),
    Radius = 6
})

WindUI:Notify({
    Title = "Enderman Hub",
    Content = "Interface carregada!",
    Duration = 3,
    Icon = "check"
})

-- serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local enemiesFolder = workspace:WaitForChild("Enemies")

-- variáveis globais
local selectedFruit = "Blade"
local attacking = false

local character = player.Character or player.CharacterAdded:Wait()
local root

local bladeRemote
local doughRemote

local combo = 1

-- atualizar personagem
local function updateChar(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")

    pcall(function()
        bladeRemote = char:WaitForChild("Blade-Blade"):WaitForChild("LeftClickRemote")
    end)

    -- encontrar remote da dough automaticamente
    pcall(function()
        for _, v in pairs(char:WaitForChild("Humanoid"):GetChildren()) do
            if v:IsA("RemoteFunction") then
                doughRemote = v
            end
        end
    end)
end

updateChar(character)

player.CharacterAdded:Connect(updateChar)

-- encontrar inimigo mais próximo
local function getNearest(range)

    local nearest
    local shortest = math.huge

    for _, mob in ipairs(enemiesFolder:GetChildren()) do

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
local function startBlade()

    task.spawn(function()

        while attacking and selectedFruit == "Blade" do

            local nearest = getNearest(120)

            if nearest and bladeRemote then

                local direction = (nearest.Position - root.Position).Unit

                bladeRemote:FireServer(direction, combo)

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
local function startDough()

    task.spawn(function()

        while attacking and selectedFruit == "dough Beta" do

            local nearest = getNearest(120)

            if nearest and doughRemote then

                root.CFrame = CFrame.lookAt(
                    root.Position,
                    nearest.Position
                )

                pcall(function()
                    doughRemote:InvokeServer("TAP")
                end)

            end

            task.wait(0.03)

        end

    end)

end


-- iniciar ataque correto
local function startAttack()

    if selectedFruit == "Blade" then
        startBlade()
    end

    if selectedFruit == "dough Beta" then
        startDough()
    end

end


-- =============================================
-- TAB OP
-- =============================================
local Tab = Window:Tab({
    Title = "OP",
    Icon = "bolt"
})


-- dropdown
Tab:Dropdown({
    Title = "Selecionar Fruta",
    Desc = "Escolha Blade ou Dough Beta",
    Values = {"Blade","dough Beta"},
    Value = "Blade",

    Callback = function(option)

        selectedFruit = option

        if attacking then
            startAttack()
        end

    end
})


-- toggle fast attack
Tab:Toggle({
    Title = "fast attack fruits",
    Icon = "zap",
    Value = false,

    Callback = function(state)

        attacking = state

        if state then
            startAttack()
        end

    end
})


-- aviso
Tab:Paragraph({
    Title = "BETA",
    Desc = "Tudo isso está em beta script vai foçar em quebrar jogo completamente invés de só auto farm é etc usse com outros scripts tipo banana hub ó recomendo são hoho hub\nAtive bring mobs para ficar 100% forte.",
    Color = "Orange"
})


WindUI:Notify({
    Title = "Pronto",
    Content = "Selecione a fruta e ative fast attack",
    Duration = 3,
    Icon = "info"
})
