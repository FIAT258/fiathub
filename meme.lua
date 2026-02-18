local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "XfireX HUB (meme sea) beta",
    Icon = "door-open",
    Author = "by FIAT",
    Folder = "MySuperHub",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    -- Background comentado
    --[[
    Background = "rbxassetid://"
    --]]
    
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
})

-- Listas de estilos de luta e espadas
local fightingStyles = {
    "Combat",
    "Baller"
}

local swords = {
    "Katana",
    "Hanger",
    "Flame Katana",
    "Banana",
    "Pixel Sword",
    "Pink Hammer",
    "Bonk",
    "Card",
    "Pumpkin",
    "Yellow Blade",
    "Purple Katana",
    "Portal",
    "Floppa Sword",
    "Popcat Sword"
}

-- Variáveis de controle
local KillAuraActive = false
local TweenService = game:GetService("TweenService")

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
})

-- Dropdown para seleção de tipo
local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Desc = "Selecione o tipo de farm",
    Values = { "fight", "power", "weapon" },
    Value = "fight",
    Multi = false,
    Callback = function(value)
        print("Tipo selecionado: " .. value)
    end
})

-- Toggle Auto Farm
local AutoFarmToggle = AutoFarmTab:Toggle({
    Title = "Auto Farm",
    Desc = "Ativa/Desativa o farm automático",
    Icon = "zap",
    Value = false,
    Callback = function(state) 
        print("Auto Farm: " .. tostring(state))
    end
})
AutoFarmToggle:Lock()

-- KILL AURA TOGGLE com a lógica completa
local KillAuraToggle = AutoFarmTab:Toggle({
    Title = "Kill Aura",
    Desc = "Ativa/Desativa a kill aura (Raio 950)",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("Kill Aura: " .. tostring(state))
        KillAuraActive = state
        
        if state then
            -- Iniciar Kill Aura em uma thread separada
            task.spawn(function()
                -- Função para deitar o player (barriga para baixo)
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
                
                -- Função para equipar ferramenta baseada no tipo selecionado
                local function equipTool(selectedType)
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if not character then return end
                    
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid then return end
                    
                    -- Procurar no inventário
                    for _, tool in ipairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local toolName = tool.Name
                            
                            if selectedType == "fight" then
                                -- Verificar se é um estilo de luta
                                for _, style in ipairs(fightingStyles) do
                                    if toolName == style then
                                        humanoid:EquipTool(tool)
                                        return true
                                    end
                                end
                            elseif selectedType == "weapon" then
                                -- Verificar se é uma espada
                                for _, sword in ipairs(swords) do
                                    if toolName == sword then
                                        humanoid:EquipTool(tool)
                                        return true
                                    end
                                end
                            elseif selectedType == "power" then
                                -- Para power, verificar se tem "Power" no nome
                                if string.find(toolName:lower(), "power") then
                                    humanoid:EquipTool(tool)
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end
                
                -- Função para puxar NPCs para baixo do player
                local function pullNPCsToPlayer(npcList, playerPosition)
                    for _, npc in ipairs(npcList) do
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        if npcRoot then
                            -- Criar tween para puxar o NPC
                            local tweenInfo = TweenInfo.new(
                                0.3, -- Tempo rápido para puxar
                                Enum.EasingStyle.Linear,
                                Enum.EasingDirection.Out
                            )
                            
                            local tween = TweenService:Create(
                                npcRoot,
                                tweenInfo,
                                {CFrame = CFrame.new(playerPosition)}
                            )
                            tween:Play()
                        end
                    end
                end
                
                -- Função para mover player até grupo de NPCs
                local function moveToGroup(groupPosition)
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then return end
                    
                    local tweenInfo = TweenInfo.new(
                        0.5, -- Tempo de movimento
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.Out
                    )
                    
                    local tween = TweenService:Create(
                        humanoidRootPart,
                        tweenInfo,
                        {CFrame = CFrame.new(groupPosition)}
                    )
                    tween:Play()
                    tween.Completed:Wait()
                end
                
                -- Deitar o player uma vez no início
                layDownPlayer()
                
                -- Loop principal da Kill Aura
                while KillAuraActive do
                    local selectedType = FarmTypeDropdown.Value
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    
                    if not character then 
                        task.wait(1)
                        goto continue
                    end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if not humanoidRootPart then 
                        task.wait(1)
                        goto continue
                    end
                    
                    -- Equipar ferramenta correta
                    equipTool(selectedType)
                    
                    -- Mapa para agrupar NPCs por nome
                    local npcGroups = {}
                    local playerPos = humanoidRootPart.Position
                    
                    -- Primeiro, encontrar todos os NPCs no raio de 950
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if not KillAuraActive then break end
                        
                        -- Verificar se é um NPC (tem Humanoid e não é Player)
                        if npc:FindFirstChildOfClass("Humanoid") and not npc:IsA("Player") then
                            local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                            local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                            
                            if npcRoot and npcHumanoid and npcHumanoid.Health > 0 then
                                local distance = (npcRoot.Position - playerPos).Magnitude
                                
                                if distance < 950 then
                                    -- Agrupar por nome
                                    local npcName = npc.Name
                                    if not npcGroups[npcName] then
                                        npcGroups[npcName] = {}
                                    end
                                    table.insert(npcGroups[npcName], npc)
                                end
                            end
                        end
                    end
                    
                    -- Processar cada grupo de NPCs
                    for npcName, npcList in pairs(npcGroups) do
                        if not KillAuraActive then break end
                        
                        if #npcList > 0 then
                            print("Processando grupo: " .. npcName .. " (" .. #npcList .. " NPCs)")
                            
                            -- Calcular posição média do grupo
                            local sumPosition = Vector3.new(0, 0, 0)
                            local validNPCs = 0
                            
                            for _, npc in ipairs(npcList) do
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                                if npcRoot then
                                    sumPosition = sumPosition + npcRoot.Position
                                    validNPCs = validNPCs + 1
                                end
                            end
                            
                            if validNPCs > 0 then
                                local groupCenter = sumPosition / validNPCs
                                
                                -- Mover para o grupo
                                moveToGroup(groupCenter)
                                
                                -- Puxar todos os NPCs do grupo para baixo do player
                                pullNPCsToPlayer(npcList, humanoidRootPart.Position)
                                
                                -- Atacar clicando no meio da tela
                                local virtualUser = game:GetService("VirtualUser")
                                virtualUser:Button1Down(Vector2.new(0, 0))
                                
                                -- Continuar atacando até todos do grupo morrerem
                                local startTime = tick()
                                while KillAuraActive and tick() - startTime < 10 do -- Timeout de 10 segundos
                                    local allDead = true
                                    
                                    for _, npc in ipairs(npcList) do
                                        local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                                        if npcHumanoid and npcHumanoid.Health > 0 then
                                            allDead = false
                                            break
                                        end
                                    end
                                    
                                    if allDead then
                                        break
                                    end
                                    
                                    -- Continuar clicando
                                    virtualUser:Button1Down(Vector2.new(0, 0))
                                    task.wait(0.1)
                                end
                                
                                virtualUser:Button1Up(Vector2.new(0, 0))
                            end
                        end
                    end
                    
                    -- Se não encontrou nenhum NPC, esperar um pouco
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

-- Dropdown para quantidade de giros
local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Desc = "Selecione quantas vezes girar",
    Values = { "1", "3", "10" },
    Value = "1",
    Multi = false,
    Callback = function(value)
        print("Quantidade selecionada: " .. value)
    end
})

-- Botão Girar Fruta Money
FruitTab:Button({
    Title = "Girar Fruta (Money)",
    Desc = "Gira a roleta usando money",
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value
        
        local type = selectedAmount == "1" and "Once" or (selectedAmount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            {
                Type = type,
                NPCName = "Floppa Gacha",
                GachaType = "Money"
            }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end)
    end
})

-- Botão Girar Fruta Gema
FruitTab:Button({
    Title = "Girar Fruta (Gema)",
    Desc = "Gira a roleta usando gemas",
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value
        
        local type = selectedAmount == "1" and "Once" or (selectedAmount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            {
                Type = type,
                NPCName = "Doge Gacha",
                GachaType = "Gem"
            }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end)
    end
})

print("✅ HUB carregado!")
print("✅ Kill Aura - Raio 950")
print("✅ Agrupa NPCs por nome")
print("✅ Puxa NPCs para baixo do player")
