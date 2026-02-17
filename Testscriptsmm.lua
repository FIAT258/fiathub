--[[
    Script com Interface Arrastável
    Funcionalidades:
    - Interface bonita e arrastável
    - Botão de minimizar
    - Toggle Anti Lag (remove novas fontes de luz)
    - Força tools a não serem removidas do inventário
    - Auto-equip iPhone e mantém múltiplos tools equipados
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variáveis
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local topBar = Instance.new("Frame")
local title = Instance.new("TextLabel")
local minimizeBtn = Instance.new("ImageButton")
local contentFrame = Instance.new("Frame")
local iphoneBtn = Instance.new("ImageButton")
local lagToggle = Instance.new("ImageButton")
local statusText = Instance.new("TextLabel")
local iphoneStatus = Instance.new("TextLabel")
local dragToggle = nil
local dragInput = nil
local dragStart = nil
local startPos = nil

-- Configurar GUI
screenGui.Name = "iPhoneToolGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame Principal
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = false

-- Cantos arredondados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = mainFrame
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)

-- Top Bar (para arrastar)
topBar.Name = "TopBar"
topBar.Parent = mainFrame
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
topBar.BackgroundTransparency = 0.2
topBar.BorderSizePixel = 0
topBar.Size = UDim2.new(1, 0, 0, 40)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

-- Título
title.Name = "Title"
title.Parent = topBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "iPhone Controller"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Botão Minimizar
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Parent = topBar
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
minimizeBtn.Image = "rbxassetid://3926305904"
minimizeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.ImageRectOffset = Vector2.new(4, 284)
minimizeBtn.ImageRectSize = Vector2.new(36, 36)

-- Content Frame
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 45)

-- Botão iPhone
iphoneBtn.Name = "iPhoneBtn"
iphoneBtn.Parent = contentFrame
iphoneBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
iphoneBtn.Size = UDim2.new(1, -20, 0, 50)
iphoneBtn.Position = UDim2.new(0, 10, 0, 10)
iphoneBtn.AutoButtonColor = true
iphoneBtn.Image = "rbxassetid://3926307977"
iphoneBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
iphoneBtn.ScaleType = Enum.ScaleType.Fit

local iphoneCorner = Instance.new("UICorner")
iphoneCorner.CornerRadius = UDim.new(0, 8)
iphoneCorner.Parent = iphoneBtn

local iphoneLabel = Instance.new("TextLabel")
iphoneLabel.Parent = iphoneBtn
iphoneLabel.BackgroundTransparency = 1
iphoneLabel.Size = UDim2.new(1, -50, 1, 0)
iphoneLabel.Position = UDim2.new(0, 50, 0, 0)
iphoneLabel.Text = "Equipar iPhone"
iphoneLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
iphoneLabel.TextXAlignment = Enum.TextXAlignment.Left
iphoneLabel.Font = Enum.Font.Gotham
iphoneLabel.TextSize = 14

-- Status do iPhone
iphoneStatus.Name = "iPhoneStatus"
iphoneStatus.Parent = contentFrame
iphoneStatus.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
iphoneStatus.Size = UDim2.new(1, -20, 0, 30)
iphoneStatus.Position = UDim2.new(0, 10, 0, 70)
iphoneStatus.Text = "iPhone: Não equipado"
iphoneStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
iphoneStatus.Font = Enum.Font.Gotham
iphoneStatus.TextSize = 12

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = iphoneStatus

-- Toggle Anti Lag
lagToggle.Name = "LagToggle"
lagToggle.Parent = contentFrame
lagToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
lagToggle.Size = UDim2.new(1, -20, 0, 50)
lagToggle.Position = UDim2.new(0, 10, 0, 120)
lagToggle.AutoButtonColor = true
lagToggle.Image = "rbxassetid://3926305904"
lagToggle.ImageColor3 = Color3.fromRGB(200, 200, 200)
lagToggle.ScaleType = Enum.ScaleType.Fit

local lagCorner = Instance.new("UICorner")
lagCorner.CornerRadius = UDim.new(0, 8)
lagCorner.Parent = lagToggle

local lagLabel = Instance.new("TextLabel")
lagLabel.Parent = lagToggle
lagLabel.BackgroundTransparency = 1
lagLabel.Size = UDim2.new(1, -50, 1, 0)
lagLabel.Position = UDim2.new(0, 50, 0, 0)
lagLabel.Text = "Anti Lag: Desativado"
lagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lagLabel.TextXAlignment = Enum.TextXAlignment.Left
lagLabel.Font = Enum.Font.Gotham
lagLabel.TextSize = 14

-- Status geral
statusText.Name = "StatusText"
statusText.Parent = contentFrame
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -20, 0, 30)
statusText.Position = UDim2.new(0, 10, 0, 180)
statusText.Text = "Status: Ativo"
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 12

-- Variáveis de controle
local minimized = false
local antiLagActive = false
local originalSize = mainFrame.Size
local toolConnection = nil
local toolsBlocked = {}

-- Função para tornar arrastável
local function updateDrag(input)
	local delta = input.Position - dragStart
	local newPos = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
	
	-- Limitar à tela
	local viewportSize = workspace.CurrentCamera.ViewportSize
	newPos = UDim2.new(
		0,
		math.clamp(newPos.X.Offset, 0, viewportSize.X - mainFrame.AbsoluteSize.X),
		0,
		math.clamp(newPos.Y.Offset, 0, viewportSize.Y - mainFrame.AbsoluteSize.Y)
	)
	
	mainFrame.Position = newPos
end

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragToggle = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end)

topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragToggle then
		updateDrag(input)
	end
end)

-- Função Minimizar
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	
	if minimized then
		mainFrame:TweenSize(UDim2.new(0, 400, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		contentFrame.Visible = false
		minimizeBtn.ImageRectOffset = Vector2.new(4, 244)
	else
		mainFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		contentFrame.Visible = true
		minimizeBtn.ImageRectOffset = Vector2.new(4, 284)
	end
end)

-- Função para bloquear remoção de tools
local function blockToolRemoval(tool)
	if toolsBlocked[tool] then return end
	
	toolsBlocked[tool] = true
	
	-- Conectar ao evento de remoção
	local connection
	connection = tool.AncestryChanged:Connect(function()
		if not tool.Parent then
			-- Tool foi removida, colocar de volta no jogador
			tool.Parent = player.Backpack
			statusText.Text = "Tool bloqueada: " .. tool.Name
			statusText.TextColor3 = Color3.fromRGB(255, 255, 0)
			task.wait(2)
			statusText.Text = "Status: Ativo"
			statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
		end
	end)
	
	-- Armazenar conexão
	tool:SetAttribute("BlockConnection", connection)
end

-- Função para detectar tools
local function checkTools()
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and not toolsBlocked[tool] then
			blockToolRemoval(tool)
		end
	end
	
	for _, tool in ipairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") and not toolsBlocked[tool] then
			blockToolRemoval(tool)
		end
	end
end

-- Loop principal
task.spawn(function()
	while true do
		task.wait(1)
		checkTools()
		
		-- Verificar se iPhone está no inventário
		local hasIPhone = false
		local iphoneTool = nil
		
		for _, tool in ipairs(player.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == "Iphone" then
				hasIPhone = true
				iphoneTool = tool
				break
			end
		end
		
		if not hasIPhone then
			for _, tool in ipairs(player.Character:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == "Iphone" then
					hasIPhone = true
					iphoneTool = tool
					break
				end
			end
		end
		
		-- Atualizar status
		if hasIPhone then
			iphoneStatus.Text = "iPhone: Equipado/Disponível ✓"
			iphoneStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			iphoneStatus.Text = "iPhone: Não encontrado ✗"
			iphoneStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
		
		-- ⬇️⬇️⬇️ SEU CÓDIGO AQUI - EXECUTADO A CADA 1 SEGUNDO ⬇️⬇️⬇️
		local args = {
			"PickingTools",
			"Iphone"
		}
		
		local success, result = pcall(function()
			return game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
		end)
		
		if not success then
			statusText.Text = "Erro ao executar comando"
			statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
		else
			print("Comando executado:", result) -- Debug opcional
		end
		-- ⬆️⬆️⬆️ SEU CÓDIGO AQUI ⬆️⬆️⬆️
	end
end)

-- Equipar iPhone quando disponível
local function equipIPhone()
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool.Name == "Iphone" then
			tool.Parent = player.Character
			break
		end
	end
end

-- Monitorar inventário para equipar iPhone
player.Backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child.Name == "Iphone" then
		task.wait(0.1)
		equipIPhone()
	end
end)

-- Monitorar character para manter múltiplos tools equipados
player.CharacterAdded:Connect(function(character)
	task.wait(0.5)
	equipIPhone()
end)

-- Toggle Anti Lag
lagToggle.MouseButton1Click:Connect(function()
	antiLagActive = not antiLagActive
	
	if antiLagActive then
		lagLabel.Text = "Anti Lag: Ativado"
		lagToggle.ImageColor3 = Color3.fromRGB(100, 255, 100)
		statusText.Text = "Anti Lag ativado - Bloqueando novas luzes"
		
		-- Conectar ao evento de criação de luzes
		if toolConnection then
			toolConnection:Disconnect()
		end
		
		toolConnection = game.DescendantAdded:Connect(function(instance)
			if antiLagActive and instance:IsA("Light") then
				-- Remover apenas luzes novas
				task.wait()
				if instance and instance.Parent then
					instance:Destroy()
					statusText.Text = "Nova luz bloqueada!"
					statusText.TextColor3 = Color3.fromRGB(255, 255, 0)
					task.wait(1)
					statusText.Text = "Anti Lag ativado - Bloqueando novas luzes"
					statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
				end
			end
		end)
	else
		lagLabel.Text = "Anti Lag: Desativado"
		lagToggle.ImageColor3 = Color3.fromRGB(200, 200, 200)
		statusText.Text = "Anti Lag desativado"
		statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
		
		if toolConnection then
			toolConnection:Disconnect()
			toolConnection = nil
		end
	end
end)

-- Limpeza ao remover GUI
screenGui.DescendantRemoving:Connect(function()
	if toolConnection then
		toolConnection:Disconnect()
	end
end)

print("iPhone Controller carregado com sucesso!")
statusText.Text = "Status: Carregado ✓"
