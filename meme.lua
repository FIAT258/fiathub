local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "XfireX HUB (meme sea) beta",
    Icon = "door-open",
    Author = "by FIAT",
    Folder = "MySuperHub",
    Size = UDim2.fromOffset(580, 460),
})

-- Listas de estilos de luta e espadas
local fightingStyles = { "Combat", "Baller" }
local swords = {
    "Katana", "Hanger", "Flame Katana", "Banana",
    "Pixel Sword", "Pink Hammer", "Bonk", "Card",
    "Pumpkin", "Yellow Blade", "Purple Katana", "Portal",
    "Floppa Sword", "Popcat Sword"
}

-- Serviços
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Variáveis de controle
local KillAuraActive = false
local CurrentKillAuraLoop = nil
local AutoStoreFruits = false
local FruitStoreConnection = nil

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
})

-- Dropdown tipo de farm
local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Desc = "Selecione o tipo de farm",
    Values = { "fight", "power", "weapon" },
    Value = "fight",
    Multi = false,
    Callback = function(value)
        print("✅ Tipo selecionado:", value)
    end
})

-- Toggle Auto Farm
local AutoFarmToggle = AutoFarmTab:Toggle({
    Title = "Auto Farm",
    Value = false,
})
AutoFarmToggle:Lock()

-- KILL AURA CORRIGIDO
local KillAuraToggle = AutoFarmTab:Toggle({
    Title = "Kill Aura",
    Desc = "Raio 950 - Agrupa NPCs por nome",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("Kill Aura:", state)
        KillAuraActive = state
        
        if state then
            -- Cancelar loop anterior se existir
            if CurrentKillAuraLoop then
                CurrentKillAuraLoop:Disconnect()
            end
            
            -- Função para deitar o player (barriga para baixo - VIVO)
            local function layDownPlayer()
                local character = game.Players.LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Deitar sem matar (barriga para baixo)
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    print("✅ Player deitado (barriga para baixo)")
                end
            end
            
            -- Função para levantar o player (voltar ao normal)
            local function standUpPlayer()
                local character = game.Players.LocalPlayer.Character
                if not character then return end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    print("✅ Player levantado")
                end
            end
            
            -- Função para equipar ferramenta baseada no tipo
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
            
            -- Função para puxar NPCs com MESMO NOME para o player
            local function pullSameNameNPCs(targetNPC, allNPCs, playerPos)
                local targetName = targetNPC.Name
                
                -- Puxar apenas NPCs com o mesmo nome
                for _, npc in ipairs(allNPCs) do
                    if npc.Name == targetName then
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        if npcRoot and npc ~= targetNPC then
                            local tween = TweenService:Create(
                                npcRoot,
                                TweenInfo.new(0.3, Enum.EasingStyle.Linear),
                                {CFrame = CFrame.new(playerPos)}
                            )
                            tween:Play()
                        end
                    end
                end
            end
            
            -- Função para mover player até a CABEÇA do NPC
            local function moveToNPCHead(npc)
                local character = game.Players.LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                if not npcRoot then return end
                
                -- Posição na CABEÇA do NPC (um pouco acima)
                local headPos = npcRoot.Position + Vector3.new(0, 5, 0)
                
                -- CRIAR TWEEN e AGUARDAR
                local tween = TweenService:Create(
                    rootPart,
                    TweenInfo.new(0.5, Enum.EasingStyle.Linear),
                    {CFrame = CFrame.new(headPos)}
                )
                tween:Play()
                tween.Completed:Wait()
                print("✅ Player moveu para cabeça do NPC")
            end
            
            -- Deitar player no início
            layDownPlayer()
            
            -- Loop principal da Kill Aura
            CurrentKillAuraLoop = RunService.Heartbeat:Connect(function()
                if not KillAuraActive then return end
                
                local selectedType = FarmTypeDropdown.Value
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Manter player deitado (barriga para baixo)
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                end
                
                -- Equipar ferramenta
                equipTool(selectedType)
                
                -- Coletar TODOS os NPCs no raio 950
                local allNPCs = {}
                local playerPos = rootPart.Position
                
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if not KillAuraActive then break end
                    
                    -- Verificar se é NPC (tem Humanoid e NÃO é Player)
                    if npc:FindFirstChildOfClass("Humanoid") and not npc:IsA("Player") then
                        local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        
                        if npcRoot and npcHumanoid and npcHumanoid.Health > 0 then
                            local distance = (npcRoot.Position - playerPos).Magnitude
                            
                            if distance < 950 then
                                table.insert(allNPCs, npc)
                            end
                        end
                    end
                end
                
                -- Se encontrou NPCs
                if #allNPCs > 0 then
                    -- Encontrar o NPC mais próximo
                    local closestNPC = nil
                    local closestDistance = math.huge
                    
                    for _, npc in ipairs(allNPCs) do
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        if npcRoot then
                            local distance = (npcRoot.Position - playerPos).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestNPC = npc
                            end
                        end
                    end
                    
                    if closestNPC then
                        print("🎯 NPC mais próximo:", closestNPC.Name)
                        
                        -- Mover para CABEÇA do NPC mais próximo
                        moveToNPCHead(closestNPC)
                        
                        -- Puxar TODOS os NPCs com o MESMO NOME para o player
                        pullSameNameNPCs(closestNPC, allNPCs, rootPart.Position)
                        
                        -- Atacar
                        VirtualUser:Button1Down(Vector2.new(0, 0))
                        
                        -- Verificar se o NPC mais próximo morreu
                        local startTime = tick()
                        while KillAuraActive and tick() - startTime < 5 do
                            local npcHumanoid = closestNPC:FindFirstChildOfClass("Humanoid")
                            if not npcHumanoid or npcHumanoid.Health <= 0 then
                                print("💀 NPC morreu")
                                break
                            end
                            task.wait(0.1)
                        end
                        
                        VirtualUser:Button1Up(Vector2.new(0, 0))
                    end
                else
                    -- Se não encontrou NPCs, esperar
                    task.wait(1)
                end
                
                task.wait(0.1)
            end)
        else
            -- Parar Kill Aura e VOLTAR AO NORMAL
            if CurrentKillAuraLoop then
                CurrentKillAuraLoop:Disconnect()
                CurrentKillAuraLoop = nil
            end
            
            -- Levantar o player
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    print("✅ Player voltou ao normal")
                end
            end
        end
    end
})

-- BOTÃO BIG HIT BOX FLOPA X (beta)
AutoFarmTab:Button({
    Title = "BIG HIT BOX FLOPA X (beta)",
    Desc = "Expande hitbox para cobrir o mapa",
    Callback = function()
        print("🔥 Ativando BIG HIT BOX")
        
        -- Encontrar qualquer monstro importante
        local monster = workspace:FindFirstChild("Monster") or workspace:FindFirstChild("Mob") or workspace
        local target = monster:FindFirstChild("The Rock") or monster:FindFirstChildWhichIsA("Model")
        
        if target then
            -- Posição no meio do mapa (ajuste conforme necessário)
            local mapCenter = Vector3.new(-2800, -60, -1800)
            
            local args = {
                target,
                "Floppa",
                "X",
                {
                    RootPart_Position = Vector3.new(999999, 999999, 999999), -- Valor máximo
                    Mouse_Position = mapCenter
                }
            }
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("SkillEvents"):WaitForChild("Server_Hitbox"):FireServer(unpack(args))
                print("✅ BIG HIT BOX ativado!")
            end)
        else
            print("❌ Alvo não encontrado")
        end
    end
})

-- Tab Fruta
local FruitTab = Window:Tab({
    Title = "Fruta",
    Icon = "apple", 
})

-- Dropdown quantidade de giros
local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Values = { "1", "3", "10" },
    Value = "1",
    Callback = function(value)
        print("Quantidade selecionada:", value)
    end
})

-- Botão Girar Fruta Money
FruitTab:Button({
    Title = "Girar Fruta (Money)",
    Desc = "Gira a roleta usando money",
    Callback = function()
        local amount = SpinAmountDropdown.Value
        local spinType = amount == "1" and "Once" or (amount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            {
                Type = spinType,
                NPCName = "Floppa Gacha",
                GachaType = "Money"
            }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
            print("✅ Giro Money realizado:", amount, "vez(es)")
        end)
    end
})

-- Botão Girar Fruta Gema
FruitTab:Button({
    Title = "Girar Fruta (Gema)",
    Desc = "Gira a roleta usando gemas",
    Callback = function()
        local amount = SpinAmountDropdown.Value
        local spinType = amount == "1" and "Once" or (amount == "3" and "Triple" or "Decuple")
        
        local args = {
            "Random_Power",
            {
                Type = spinType,
                NPCName = "Doge Gacha",
                GachaType = "Gem"
            }
        }
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
            print("✅ Giro Gema realizado:", amount, "vez(es)")
        end)
    end
})

-- TOGGLE GUARDAR FRUTAS
local AutoStoreToggle = FruitTab:Toggle({
    Title = "Guarda Frutas",
    Desc = "Auto guardar frutas da mochila",
    Icon = "package",
    Value = false,
    Callback = function(state)
        print("Guarda Frutas:", state)
        AutoStoreFruits = state
        
        if state then
            -- Conectar ao evento de novo item na mochila
            if FruitStoreConnection then
                FruitStoreConnection:Disconnect()
            end
            
            FruitStoreConnection = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
                if not AutoStoreFruits then return end
                
                if child:IsA("Tool") then
                    task.wait(0.1) -- Pequena espera para garantir
                    
                    local args = {
                        "Eatable_Power",
                        {
                            Action = "Store",
                            Tool = child
                        }
                    }
                    
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
                        print("✅ Fruta guardada:", child.Name)
                    end)
                end
            end)
            
            print("✅ Auto guarda frutas ativado")
        else
            if FruitStoreConnection then
                FruitStoreConnection:Disconnect()
                FruitStoreConnection = nil
            end
            print("❌ Auto guarda frutas desativado")
        end
    end
})

print("🚀 HUB COMPLETO CORRIGIDO!")
print("✅ Player de BARRIGA PARA BAIXO (vivo)")
print("✅ Tween para CABEÇA do NPC (FUNCIONANDO)")
print("✅ Puxa NPCs com MESMO NOME")
print("✅ Desliga: player volta ao normal")
print("✅ Botão BIG HIT BOX FLOPA X")
print("✅ Toggle Guarda Frutas")
