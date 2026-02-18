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

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
})

-- CORREÇÃO 1: Value como STRING, não tabela
local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Desc = "Selecione o tipo de farm",
    Values = { "fight", "power", "weapon" },
    Value = "fight",  -- Mudado de { "fight" } para "fight"
    Multi = false,
    Callback = function(value)  -- Callback recebe string direto
        print("Tipo selecionado: " .. value)
        -- Se precisar do valor em outra parte, use FarmTypeDropdown.Value
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

-- Kill Aura como Toggle (com sua lógica adaptada)
local KillAuraToggle = AutoFarmTab:Toggle({
    Title = "Kill Aura",
    Desc = "Ativa/Desativa a kill aura",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("Kill Aura: " .. tostring(state))
        
        if state then
            -- Sua lógica original, mas usando FarmTypeDropdown.Value direto
            task.spawn(function()
                -- Função para deitar o player
                local function layDownPlayer()
                    local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                        task.wait(0.1)
                        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                    end
                end
                
                layDownPlayer()
                
                while KillAuraToggle.Value do
                    local selectedType = FarmTypeDropdown.Value  -- Agora é string direto
                    local character = game.Players.LocalPlayer.Character
                    if not character then task.wait(1) break end
                    
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoidRootPart then
                        for _, npc in ipairs(workspace:GetDescendants()) do
                            if not KillAuraToggle.Value then break end
                            
                            if npc:FindFirstChildOfClass("Humanoid") and not npc:FindFirstChildOfClass("Player") then
                                local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                                
                                if npcRoot and npcHumanoid and npcHumanoid.Health > 0 then
                                    local distance = (npcRoot.Position - humanoidRootPart.Position).Magnitude
                                    
                                    if distance < 200 then
                                        -- Equipar ferramenta
                                        local toolName = ""
                                        if selectedType == "fight" then
                                            toolName = "Fight/Melee"
                                        elseif selectedType == "weapon" then
                                            toolName = "Weapon"
                                        elseif selectedType == "power" then
                                            toolName = "Power/Powers"
                                        end
                                        
                                        for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                            if tool:IsA("Tool") and string.find(tool.Name:lower(), toolName:lower()) then
                                                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                                if humanoid then
                                                    humanoid:EquipTool(tool)
                                                end
                                                break
                                            end
                                        end
                                        
                                        -- Atacar
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                                        task.wait(0.1)
                                        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                                    end
                                end
                            end
                        end
                    end
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

-- CORREÇÃO 2: Value como STRING, não tabela
local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Desc = "Selecione quantas vezes girar",
    Values = { "1", "3", "10" },
    Value = "1",  -- Mudado de { "1" } para "1"
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
        local selectedAmount = SpinAmountDropdown.Value  -- Agora é string direto
        
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
        local selectedAmount = SpinAmountDropdown.Value  -- Agora é string direto
        
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

print("✅ HUB carregado com 2 abas!")
