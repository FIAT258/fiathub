local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "XfireX HUB (meme sea) beta",
    Icon = "door-open", -- lucide icon
    Author = "by FIAT",
    Folder = "MySuperHub",
    
    -- ↓ This all is Optional. You can remove it.
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
    
    -- CORREÇÃO: Comentário fechado corretamente
    --[[
    You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]]
    
    -- ↓ Optional. You can remove it.
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
})

-- CORREÇÃO: Removidas funções que não existem
-- WindUI:GetTransparency(false)
-- WindUI:GetWindowSize(52)

-- Variáveis para controle
local KillAuraActive = false
local KillAuraLoop = nil

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
    Locked = false,
})

-- Dropdown para seleção de tipo
local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Desc = "Selecione o tipo de farm",
    Values = { "fight", "power", "weapon" },
    Value = { "fight" }, -- Mantido como tabela
    Multi = false,
    AllowNone = false,
    Callback = function(option) 
        print("Tipo selecionado: " .. option[1])
    end
})

-- Toggle Auto Farm (trancado inicialmente)
local AutoFarmToggle = AutoFarmTab:Toggle({
    Title = "Auto Farm",
    Desc = "Ativa/Desativa o farm automático",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state) 
        print("Auto Farm: " .. tostring(state))
    end
})
AutoFarmToggle:Lock()

-- KILL AURA COMO TOGGLE (igual você pediu)
local KillAuraToggle = AutoFarmTab:Toggle({
    Title = "Kill Aura",
    Desc = "Ativa/Desativa a kill aura",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("Kill Aura: " .. tostring(state))
        KillAuraActive = state
        
        if state then
            -- Iniciar kill aura
            if KillAuraLoop then
                KillAuraLoop:Disconnect()
            end
            
            -- Função para deitar o player
            local function layDownPlayer()
                local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    task.wait(0.1)
                    humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                end
            end
            
            -- Deitar o player uma vez
            layDownPlayer()
            
            -- Loop da kill aura
            KillAuraLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if not KillAuraActive then return end
                
                local selectedType = FarmTypeDropdown.Value[1]
                local character = game.Players.LocalPlayer.Character
                if not character then return end
                
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                -- Encontrar todos os humanoides próximos (não players)
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if not KillAuraActive then break end
                    
                    if npc:FindFirstChildOfClass("Humanoid") and not npc:FindFirstChildOfClass("Player") then
                        local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                        
                        if npcRoot and npcHumanoid and npcHumanoid.Health > 0 then
                            local distance = (npcRoot.Position - humanoidRootPart.Position).Magnitude
                            
                            if distance < 200 then
                                -- Equipar a ferramenta correta baseada no dropdown
                                local toolName = ""
                                if selectedType == "fight" then
                                    toolName = "Fight/Melee"
                                elseif selectedType == "weapon" then
                                    toolName = "Weapon"
                                elseif selectedType == "power" then
                                    toolName = "Power/Powers"
                                end
                                
                                -- Procurar e equipar a ferramenta
                                for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and string.find(tool.Name:lower(), toolName:lower()) then
                                        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                        if humanoid then
                                            humanoid:EquipTool(tool)
                                        end
                                        break
                                    end
                                end
                                
                                -- Atacar o NPC
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                                task.wait()
                                game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                            end
                        end
                    end
                end
            end)
        else
            -- Parar kill aura
            if KillAuraLoop then
                KillAuraLoop:Disconnect()
                KillAuraLoop = nil
            end
        end
    end
})

-- Tab Fruta
local FruitTab = Window:Tab({
    Title = "Fruta",
    Icon = "apple", 
    Locked = false,
})

-- Dropdown para quantidade de giros
local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Desc = "Selecione quantas vezes girar",
    Values = { "1", "3", "10" },
    Value = { "1" }, -- Mantido como tabela
    Multi = false,
    AllowNone = false,
    Callback = function(option) 
        print("Quantidade selecionada: " .. option[1])
    end
})

-- Botão Girar Fruta Money
local SpinMoneyButton = FruitTab:Button({
    Title = "Girar Fruta (Money)",
    Desc = "Gira a roleta usando money",
    Locked = false,
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value[1]
        
        if selectedAmount == "1" then
            local args = {
                "Random_Power",
                {
                    Type = "Once",
                    NPCName = "Floppa Gacha",
                    GachaType = "Money"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        elseif selectedAmount == "3" then
            local args = {
                "Random_Power",
                {
                    Type = "Triple",
                    NPCName = "Floppa Gacha",
                    GachaType = "Money"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        elseif selectedAmount == "10" then
            local args = {
                "Random_Power",
                {
                    Type = "Decuple",
                    NPCName = "Floppa Gacha",
                    GachaType = "Money"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end
    end
})

-- Botão Girar Fruta Gema (CORRIGIDO)
local SpinGemButton = FruitTab:Button({
    Title = "Girar Fruta (Gema)",
    Desc = "Gira a roleta usando gemas",
    Locked = false,
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value[1]
        
        if selectedAmount == "1" then
            local args = {
                "Random_Power",
                {
                    Type = "Once",
                    NPCName = "Doge Gacha",
                    GachaType = "Gem"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        elseif selectedAmount == "3" then
            local args = {
                "Random_Power",
                {
                    Type = "Triple",
                    NPCName = "Doge Gacha",
                    GachaType = "Gem"
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        elseif selectedAmount == "10" then
            local args = {
                "Random_Power",
                {
                    Type = "Decuple",
                    NPCName = "Doge Gacha",
                    GachaType = "Gem"
                }
            }
            -- CORREÇÃO: Removida a aspa dupla extra
            game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
        end
    end
})

print("✅ HUB carregado!")
print("✅ Kill Aura é Toggle")
print("✅ Key System removido")
