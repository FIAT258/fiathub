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
    
    -- CORREÇÃO: Fechei corretamente o comentário da seção Background
    --[[ 
    You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]] 
    
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("clicked")
        end,
    },
    
    KeySystem = { 
        Key = { "#fire#hubx130key18722--KEYwalfy", "#fire#hubx130key18722--KEYwalfy" },
        Note = "Example Key System.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "FIAT HUB KEY SISTEN",
        },
        URL = "REAL",
        SaveKey = true,
    },
})

WindUI:GetTransparency(false)
WindUI:GetWindowSize(52)

-- Tab Auto Farm
local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "activity", 
    Locked = false,
})

local FarmTypeDropdown = AutoFarmTab:Dropdown({
    Title = "Tipo de Farm",
    Desc = "Selecione o tipo de farm",
    Values = { "fight", "power", "weapon" },
    Value = { "fight" },
    Multi = false,
    AllowNone = false,
    Callback = function(option) 
        print("Tipo selecionado: " .. option[1])
    end
})

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

local KillAuraButton = AutoFarmTab:Button({
    Title = "Kill Aura",
    Desc = "Ativa a kill aura",
    Locked = false,
    Callback = function()
        -- Função para deitar o player
        local function layDownPlayer()
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                task.wait(0.1)
                humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            end
        end
        
        -- Função principal da kill aura
        local function killAura()
            layDownPlayer()
            
            while AutoFarmToggle.Value do
                local selectedType = FarmTypeDropdown.Value[1]
                local character = game.Players.LocalPlayer.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    for _, npc in ipairs(workspace:GetDescendants()) do
                        if npc:FindFirstChildOfClass("Humanoid") and not npc:FindFirstChildOfClass("Player") then
                            local npcHumanoid = npc:FindFirstChildOfClass("Humanoid")
                            local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                            
                            if npcRoot and (npcRoot.Position - humanoidRootPart.Position).Magnitude < 200 then
                                local toolName = ""
                                if selectedType == "fight" then
                                    toolName = "Fight/Melee"
                                elseif selectedType == "weapon" then
                                    toolName = "Weapon"
                                elseif selectedType == "power" then
                                    toolName = "Power/Powers"
                                end
                                
                                for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                                    if string.find(tool.Name:lower(), toolName:lower()) then
                                        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
                                        break
                                    end
                                end
                                
                                game:GetService("RunService").Heartbeat:Wait()
                                
                                if npcHumanoid.Health <= 0 then
                                    break
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end
        
        killAura()
    end
})

-- Tab Fruta
local FruitTab = Window:Tab({
    Title = "Fruta",
    Icon = "apple", 
    Locked = false,
})

local SpinAmountDropdown = FruitTab:Dropdown({
    Title = "Quantidade de Giros",
    Desc = "Selecione quantas vezes girar",
    Values = { "1", "3", "10" },
    Value = { "1" },
    Multi = false,
    AllowNone = false,
    Callback = function(option) 
        print("Quantidade selecionada: " .. option[1])
    end
})

local SpinMoneyButton = FruitTab:Button({
    Title = "Girar Fruta (Money)",
    Desc = "Gira a roleta usando money",
    Locked = false,
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value[1]
        local args = {
            "Random_Power",
            {
                Type = selectedAmount == "1" and "Once" or (selectedAmount == "3" and "Triple" or "Decuple"),
                NPCName = "Floppa Gacha",
                GachaType = "Money"
            }
        }
        game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
    end
})

local SpinGemButton = FruitTab:Button({
    Title = "Girar Fruta (Gema)",
    Desc = "Gira a roleta usando gemas",
    Locked = false,
    Callback = function()
        local selectedAmount = SpinAmountDropdown.Value[1]
        local args = {
            "Random_Power",
            {
                Type = selectedAmount == "1" and "Once" or (selectedAmount == "3" and "Triple" or "Decuple"),
                NPCName = "Doge Gacha",
                GachaType = "Gem"
            }
        }
        -- CORREÇÃO: Removi a aspa dupla extra no caminho
        game:GetService("ReplicatedStorage"):WaitForChild("OtherEvent"):WaitForChild("MainEvents"):WaitForChild("Modules"):FireServer(unpack(args))
    end
})
