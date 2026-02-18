local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "XfireX HUB (meme sea) beta",
    Icon = "door-open",
    Author = "by FIAT",
    Folder = "MySuperHub",
    
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    
    User = {
        Enabled = true,
        Anonymous = true,
    },
})

-- Listas de estilos de luta e espadas
local fightingStyles = { "Combat", "Baller" }
local swords = {
    "Katana", "Hanger", "Flame Katana", "Banana",
    "Pixel Sword", "Pink Hammer", "Bonk", "Card",
    "Pumpkin", "Yellow Blade", "Purple Katana", "Portal",
    "Floppa Sword", "Popcat Sword"
}

-- Variáveis de controle
local KillAuraActive = false
local TweenService = game:GetService("TweenService")

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
})

-- Dropdown tipo de farm
local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Values = { "fight", "power", "weapon" },
    Value = "fight",
    Callback = function(value) 
        print("Tipo selecionado: " .. value)
    end
})

-- Toggle Auto Farm
local AutoFarmToggle = AutoFarmTab:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(state) 
        print("Auto Farm: " .. tostring(state))
    end
})
AutoFarmToggle:Lock()

-- KILL AURA COMPLETO
local KillAuraToggle = AutoFarmTab:Toggle({
    Title = "Kill Aura",
    Desc = "Raio 950 - Agrupa NPCs por nome",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("Kill Aura: " .. tostring(state))
        KillAuraActive = state
        
        if state then
            task.spawn(function()
                -- Função para deitar o player
                local function layDownPlayer()
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                        task.wait(0.1)
                        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                    end
                end
                
                -- Função para equipar ferramenta
                local function equipTool(selectedType)
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if not character then return false end
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid then return false end
                    
                    for _, tool in ipairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local toolName = tool.Name
                            
                            if selectedType == "fight" then
                                for _, style in ipairs(fightingStyles) do
                                    if toolName == style then
                                        humanoid:EquipTool(tool)
                                        return true
                                    end
                                end
                            elseif selectedType == "weapon" then
                                for _, sword in ipairs(swords) do
                                    if toolName == sword then
                                        humanoid:EquipTool(tool)
                                        return true
                                    end
                                end
                            elseif selectedType == "power" then
                                if string.find(toolName:lower(), "power") then
                                    humanoid:EquipTool(tool)
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end
                
                -- Função para puxar NPCs
                local function pullNPCsToPlayer(npcList, playerPos)
                    for _, npc in ipairs(npcList) do
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        if npcRoot then
                            local tween = TweenService:Create(
                                npcRoot,
                                TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                                {CFrame = CFrame.new(playerPos)}
                            )
                            tween:Play()
                        end
                    end
                end
                
                -- Função para mover player
                local function moveToPosition(pos)
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    
                    local tween = TweenService:Create(
                        root,
                        TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                        {CFrame = CFrame.new(pos)}
                    )
                    tween:Play()
                    tween.Completed:Wait()
                end
                
                -- Deitar player
                layDownPlayer()
                
                -- Loop principal
                while KillAuraActive do
                    local selectedType = FarmTypeDropdown.Value
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    
                    if not character then 
                        task.wait(1)
                        goto continue
                    end
                    
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then 
                        task.wait(1)
                        goto continue
                    end
                    
                    -- Equipar ferramenta
                    equipTool(selectedType)
                    
                    -- Agrupar NPCs por nome
                    local npcGroups = {}
                    local playerPos = rootPart.Position
                    
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if not KillAuraActive then break end
                        
                        if npc:FindFirstChildOfClass("Humanoid") and not npc:IsA("Player") then
                            local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                            local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                            
                            if npcRoot and npcHumanoid and npcHumanoid.Health > 0 then
                                local dist = (npcRoot.Position - playerPos).Magnitude
                                if dist < 950 then
                                    local name = npc.Name
                                    if not npcGroups[name] then npcGroups[name] = {} end
                                    table.insert(npcGroups[name], npc)
                                end
                            end
                        end
                    end
                    
                    -- Processar grupos
                    for npcName, npcList in pairs(npcGroups) do
                        if not KillAuraActive then break end
                        
                        if #npcList > 0 then
                            -- Calcular centro do grupo
                            local sumPos = Vector3.new(0,0,0)
                            local count = 0
                            
                            for _, npc in ipairs(npcList) do
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                                if npcRoot then
                                    sumPos = sumPos + npcRoot.Position
                                    count = count + 1
                                end
                            end
                            
                            if count > 0 then
                                local center = sumPos / count
                                
                                -- Mover para o grupo
                                moveToPosition(center)
                                
                                -- Puxar NPCs
                                pullNPCsToPlayer(npcList, rootPart.Position)
                                
                                -- Atacar
                                local virtualUser = game:GetService("VirtualUser")
                                virtualUser:Button1Down(Vector2.new(0, 0))
                                
                                -- Esperar todos morrerem
                                local start = tick()
                                while KillAuraActive and tick() - start < 10 do
                                    local allDead = true
                                    for _, npc in ipairs(npcList) do
                                        local hum = npc:FindFirstChildOfClass("Humanoid")
                                        if hum and hum.Health > 0 then
                                            allDead = false
                                            break
                                        end
                                    end
                                    if allDead then break end
                                    virtualUser:Button1Down(Vector2.new(0, 0))
                                    task.wait(0.1)
                                end
                                virtualUser:Button1Up(Vector2.new(0, 0))
                            end
                        end
                    end
                    
                    if next(npcGroups) == nil then
                        task.wait(2)
                    end
                    
                    ::continue::
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Tab Fruta
local FruitTab = Window:Tab({
    Title = "Fruta",
    Icon = "apple", 
})

-- Dropdown quantidade
local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Values = { "1", "3", "10" },
    Value = "1",
    Callback = function(value)
        print("Quantidade: " .. value)
    end
})

-- Botão Money
FruitTab:Button({
    Title = "Girar Fruta (Money)",
    Callback = function()
        local amount = SpinAmountDropdown.Value
        local spinType = amount == "1" and "Once" or (amount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            { Type = spinType, NPCName = "Floppa Gacha", GachaType = "Money" }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end)
    end
})

-- Botão Gema
FruitTab:Button({
    Title = "Girar Fruta (Gema)",
    Callback = function()
        local amount = SpinAmountDropdown.Value
        local spinType = amount == "1" and "Once" or (amount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            { Type = spinType, NPCName = "Doge Gacha", GachaType = "Gem" }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end)
    end
})

print("✅ HUB COMPLETO CARREGADO!")
print("✅ Kill Aura - Raio 950")
print("✅ Agrupa NPCs por nome")
print("✅ Puxa NPCs para baixo do player")
