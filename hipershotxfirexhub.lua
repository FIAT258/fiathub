-- Carrega Fluent (sem add-ons)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Meu Hub Aimbot",
    SubTitle = "by JX1 & DeepSeek",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark"
})

-- Abas
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Extras = Window:AddTab({ Title = "Extras", Icon = "package" }),
    Creditos = Window:AddTab({ Title = "Créditos", Icon = "heart" })
}

-- Variáveis de controle
local aimbotEnabled = false
local aimbotTeamOnly = true
local aimbotPart = "Tronco"
local espEnabled = false
local espTeam = true
local speedEnabled = false
local speedValue = 16
local infiniteJumpEnabled = false
local jumpConnection = nil
local espObjects = {}

-- ==================== AIMBOT ====================
Tabs.Aimbot:AddDropdown("BodyPart", {
    Title = "Parte do Corpo",
    Values = { "Tronco", "Costas", "Cabeça" },
    Default = 1,
    Callback = function(value) aimbotPart = value end
})

Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "Aimbot Players",
    Default = false,
    Callback = function(state) aimbotEnabled = state end
})

Tabs.Aimbot:AddToggle("TeamToggle", {
    Title = "Mirar apenas em Rivals",
    Default = true,
    Callback = function(state) aimbotTeamOnly = state end
})

-- Função para achar o humanoide mais próximo
local function getClosestHumanoid()
    local player = game.Players.LocalPlayer
    if not player.Character then return nil end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closestDist = math.huge
    local closestTarget = nil

    -- Jogadores
    for _, other in ipairs(game.Players:GetPlayers()) do
        if other ~= player then
            if aimbotTeamOnly and player.Team and other.Team == player.Team then
                -- pula
            else
                local char = other.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local dist = (root.Position - part.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = other
                        end
                    end
                end
            end
        end
    end

    -- NPCs
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
            local hum = npc:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if part then
                    local dist = (root.Position - part.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = npc
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Loop do aimbot (câmera)
game:GetService("RunService").RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local target = getClosestHumanoid()
    if not target then return end

    local char = target:IsA("Player") and target.Character or target
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local parts = { Tronco = "HumanoidRootPart", Costas = "UpperTorso", Cabeça = "Head" }
    local partName = parts[aimbotPart]
    local targetPart = char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart")
    if targetPart then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPart.Position)
    end
end)

-- ==================== ESP ====================
Tabs.ESP:AddToggle("ESPToggle", {
    Title = "ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if not state then
            for _, v in pairs(espObjects) do
                if v.Highlight then v.Highlight:Destroy() end
                if v.Billboard then v.Billboard:Destroy() end
            end
            espObjects = {}
        end
    end
})

Tabs.ESP:AddToggle("ESPTeamToggle", {
    Title = "ESP por Time",
    Default = true,
    Callback = function(state) espTeam = state end
})

-- Função ESP (simplificada)
local function updateESP()
    if not espEnabled then return end
    local player = game.Players.LocalPlayer
    local function processCharacter(char, owner)
        if not char then return end
        if not espObjects[owner] then espObjects[owner] = {} end
        local esp = espObjects[owner]

        if not esp.Highlight then
            esp.Highlight = Instance.new("Highlight")
            esp.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            esp.Highlight.Parent = char
        end
        esp.Highlight.Adornee = char

        if espTeam and owner:IsA("Player") and player.Team and owner.Team == player.Team then
            esp.Highlight.FillColor = Color3.fromRGB(0, 100, 255)
            esp.Highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        else
            esp.Highlight.FillColor = Color3.fromRGB(255, 255, 255)
            esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        end

        if not esp.Billboard then
            esp.Billboard = Instance.new("BillboardGui")
            esp.Billboard.Size = UDim2.new(0, 200, 0, 50)
            esp.Billboard.StudsOffset = Vector3.new(0, 3, 0)
            esp.Billboard.AlwaysOnTop = true
            esp.Billboard.Parent = char
            local frame = Instance.new("Frame", esp.Billboard)
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            local name = Instance.new("TextLabel", frame)
            name.Size = UDim2.new(1, 0, 0.5, 0)
            name.BackgroundTransparency = 1
            name.Text = owner:IsA("Player") and owner.Name or "NPC"
            name.TextColor3 = Color3.new(1,1,1)
            name.TextStrokeTransparency = 0.5
            name.Font = Enum.Font.SourceSansBold
            name.TextSize = 16
            local dist = Instance.new("TextLabel", frame)
            dist.Size = UDim2.new(1, 0, 0.5, 0)
            dist.Position = UDim2.new(0, 0, 0.5, 0)
            dist.BackgroundTransparency = 1
            dist.TextColor3 = Color3.new(1,1,1)
            dist.Font = Enum.Font.SourceSans
            dist.TextSize = 14
            esp.NameLabel = name
            esp.DistLabel = dist
        end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if head then
            esp.Billboard.Adornee = head
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
            local d = (player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            esp.DistLabel.Text = string.format("Dist: %.1f", d)
        end
    end

    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            processCharacter(p.Character, p)
        end
    end
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
            processCharacter(npc, npc)
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(updateESP)

-- Conexões para novos jogadores/NPCs (simplificadas)
game.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        wait(0.5)
        if espEnabled then updateESP() end
    end)
end)

-- ==================== EXTRAS ====================
Tabs.Extras:AddSlider("SpeedSlider", {
    Title = "Velocidade",
    Default = 16,
    Min = 0,
    Max = 300,
    Callback = function(v) speedValue = v end
})

Tabs.Extras:AddToggle("SpeedToggle", {
    Title = "Speed Player",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        local plr = game.Players.LocalPlayer
        if plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = state and speedValue or 16 end
        end
    end
})

Tabs.Extras:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        if state then
            jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr and plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        else
            if jumpConnection then jumpConnection:Disconnect() end
        end
    end
})

-- Dropdown de players
local playerNames = {}
Tabs.Extras:AddDropdown("PlayerDropdown", {
    Title = "Players",
    Values = playerNames,
    Callback = function(v) _G.selectedPlayer = v end
})

local function updatePlayerList()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
    end
    Fluent.Options.PlayerDropdown:SetValues(names)
end
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

Tabs.Extras:AddButton({
    Title = "Teleportar",
    Callback = function()
        if not _G.selectedPlayer then
            Fluent:Notify({ Title = "Erro", Content = "Selecione um jogador" })
            return
        end
        local target = game.Players:FindFirstChild(_G.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
            end
        end
    end
})

-- ==================== CRÉDITOS ====================
Tabs.Creditos:AddParagraph({
    Title = "Créditos",
    Content = "Interface: deep seek\nDonos: JX1\nCara aleatório: Lorenzo gay"
})

Fluent:Notify({ Title = "Hub carregado", Content = "Tudo pronto!" })
