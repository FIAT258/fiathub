--// LOAD WIND UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// CREATE WINDOW (NÃO REMOVER NADA)
local Window = WindUI:CreateWindow({
    Title = "XFIREX HUB (FORSAKEN) BETA",
    Icon = "door-open",
    Author = "by JX1",
    Folder = "MySuperHub",

    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),

    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function() end,
    },

    KeySystem = {
        Key = { "#fire#hubx130key18722--KEYwalfy", "#fire#hubx130key18722--KEYwalfy" },
        Note = "Example Key System.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "XFIREX GOD",
        },
        URL = "https://link-target.net/1460648/MU09RvRj3fCW",
        SaveKey = false,
    },
})

--// TAG
Window:Tag({
    Title = "v1",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 0,
})

------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

------------------------------------------------
-- TAB AUTO BLOCK
------------------------------------------------
local AutoBlockTab = Window:Tab({
    Title = "Auto Block",
    Icon = "shield",
    Locked = false,
})

local AutoBlockEnabled = false
local BlockDistance = 10
local BlockConnection

------------------------------------------------
-- SLIDER STUDS
------------------------------------------------
AutoBlockTab:Slider({
    Title = "Studs",
    Desc = "Distância do Hitbox",
    Step = 1,
    Value = {
        Min = 5,
        Max = 50,
        Default = 10,
    },
    Callback = function(value)
        BlockDistance = value
    end
})

------------------------------------------------
-- AUTO BLOCK LOOP (EXATAMENTE COMO PEDIDO)
------------------------------------------------
local function StartAutoBlock()
    BlockConnection = RunService.Heartbeat:Connect(function()
        if not AutoBlockEnabled then return end
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

        local hrp = Character.HumanoidRootPart

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:find("Hitbox") then
                if (obj.Position - hrp.Position).Magnitude <= BlockDistance then

                    -- EXECUTA BLOCK
                    local args = {
                        "UseActorAbility",
                        {
                            buffer.fromstring("\003\005\000\000\000Block")
                        }
                    }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Modules")
                        :WaitForChild("Network")
                        :WaitForChild("RemoteEvent")
                        :FireServer(unpack(args))

                    -- ESPERA 0.2
                    task.wait(0.2)

                    -- OLHAR PARA KILLERS
                    for _, k in pairs(workspace:GetDescendants()) do
                        if k:IsA("Model") and k.Name == "Killers" then
                            local kh = k:FindFirstChild("HumanoidRootPart")
                            if kh then
                                hrp.CFrame = CFrame.new(hrp.Position, kh.Position)
                            end
                        end
                    end

                    -- EXECUTA PUNCH
                    local args2 = {
                        "UseActorAbility",
                        {
                            buffer.fromstring("\003\005\000\000\000Punch")
                        }
                    }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Modules")
                        :WaitForChild("Network")
                        :WaitForChild("RemoteEvent")
                        :FireServer(unpack(args2))
                end
            end
        end
    end)
end

local function StopAutoBlock()
    if BlockConnection then
        BlockConnection:Disconnect()
        BlockConnection = nil
    end
end

------------------------------------------------
-- TOGGLE AUTO BLOCK
------------------------------------------------
AutoBlockTab:Toggle({
    Title = "Auto Block",
    Desc = "Bloqueia ao detectar Hitbox",
    Icon = "shield",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoBlockEnabled = state
        if state then
            StartAutoBlock()
        else
            StopAutoBlock()
        end
    end
})

------------------------------------------------
-- BUTTON EQUIP GUEST (EXATO)
------------------------------------------------
AutoBlockTab:Button({
    Title = "Equip Guest",
    Desc = "Equipa Guest1337",
    Callback = function()
        local args = {
            "EquipState",
            {
                game:GetService("ReplicatedStorage")
                    :WaitForChild("Assets")
                    :WaitForChild("Survivors")
                    :WaitForChild("Guest1337"),
                buffer.fromstring("\001\001")
            }
        }
        game:GetService("ReplicatedStorage")
            :WaitForChild("Modules")
            :WaitForChild("Network")
            :WaitForChild("RemoteEvent")
            :FireServer(unpack(args))
    end
})

------------------------------------------------
-- TAB EM BREVE
------------------------------------------------
local SoonTab = Window:Tab({
    Title = "Em Breve",
    Icon = "door-open",
    Locked = false,
})

------------------------------------------------
-- ESP KILLERS
------------------------------------------------
local ESPEnabled = false
local ESPObjects = {}

local function EnableESP()
    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Model") and m.Name == "Killers" then
            for _, p in pairs(m:GetDescendants()) do
                if p:IsA("BasePart") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = p
                    box.AlwaysOnTop = true
                    box.Size = p.Size
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.5
                    box.Parent = p
                    table.insert(ESPObjects, box)
                end
            end
        end
    end
end

local function DisableESP()
    for _, e in pairs(ESPObjects) do
        if e then e:Destroy() end
    end
    ESPObjects = {}
end

SoonTab:Toggle({
    Title = "ESP Killers",
    Desc = "Contorno nos Killers",
    Icon = "eye",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        ESPEnabled = state
        if state then
            EnableESP()
        else
            DisableESP()
        end
    end
})

------------------------------------------------
-- INFINITE STAMINA (CÓDIGO EXATO)
------------------------------------------------
SoonTab:Toggle({
    Title = "Infinite Stamina",
    Desc = "Stamina infinita",
    Icon = "zap",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            local sprintingModule = require(
                game:GetService("ReplicatedStorage")
                .Systems.Character.Game.Sprinting
            )

            local originalStaminaChange = sprintingModule.ChangeStat
            sprintingModule.ChangeStat = function(self, stat, value)
                if stat == "Stamina" then
                    return
                end
                return originalStaminaChange(self, stat, value)
            end

            local originalInit = sprintingModule.Init
            sprintingModule.Init = function(self)
                originalInit(self)

                self.StaminaLossDisabled = true
                self.Stamina = self.MaxStamina

                local staminaLoop
                staminaLoop = game:GetService("RunService").Heartbeat:Connect(function()
                    if self.Stamina < self.MaxStamina then
                        self.Stamina = self.MaxStamina
                        if self.__staminaChangedEvent then
                            self.__staminaChangedEvent:Fire(self.MaxStamina)
                        end
                    end
                end)

                self._infiniteStaminaLoop = staminaLoop
            end

            if sprintingModule.DefaultsSet then
                sprintingModule.StaminaLossDisabled = true
                sprintingModule.Stamina = sprintingModule.MaxStamina

                if not sprintingModule._infiniteStaminaLoop then
                    local staminaLoop = game:GetService("RunService").Heartbeat:Connect(function()
                        if sprintingModule.Stamina < sprintingModule.MaxStamina then
                            sprintingModule.Stamina = sprintingModule.MaxStamina
                            if sprintingModule.__staminaChangedEvent then
                                sprintingModule.__staminaChangedEvent:Fire(sprintingModule.MaxStamina)
                            end
                        end
                    end)
                    sprintingModule._infiniteStaminaLoop = staminaLoop
                end
            end

            _G.InfiniteStaminaData = {
                OriginalChangeStat = originalStaminaChange,
                OriginalInit = originalInit,
                Module = sprintingModule
            }
        else
            if _G.InfiniteStaminaData then
                local sprintingModule = _G.InfiniteStaminaData.Module

                sprintingModule.ChangeStat = _G.InfiniteStaminaData.OriginalChangeStat
                sprintingModule.Init = _G.InfiniteStaminaData.OriginalInit
                sprintingModule.StaminaLossDisabled = false

                if sprintingModule._infiniteStaminaLoop then
                    sprintingModule._infiniteStaminaLoop:Disconnect()
                    sprintingModule._infiniteStaminaLoop = nil
                end

                _G.InfiniteStaminaData = nil
            end
        end
    end
})
