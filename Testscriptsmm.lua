-- GUI Interface Arrastável
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local dragBar = Instance.new("Frame")
local title = Instance.new("TextLabel")
local selectPlayerBtn = Instance.new("TextButton")
local toggleBtn = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")
local selectedPlayerLabel = Instance.new("TextLabel")

-- Configuração da GUI
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "ToolGUI"
screenGui.ResetOnSpawn = false

mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Active = true
mainFrame.Draggable = false

dragBar.Parent = mainFrame
dragBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
dragBar.BorderSizePixel = 0
dragBar.Size = UDim2.new(1, 0, 0, 25)
dragBar.Position = UDim2.new(0, 0, 0, 0)

title.Parent = dragBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "TOOL SELECT PLAYER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

selectPlayerBtn.Parent = mainFrame
selectPlayerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
selectPlayerBtn.BorderColor3 = Color3.fromRGB(255, 170, 0)
selectPlayerBtn.Position = UDim2.new(0.5, -100, 0.25, 0)
selectPlayerBtn.Size = UDim2.new(0, 200, 0, 35)
selectPlayerBtn.Text = "SELECIONAR JOGADOR"
selectPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectPlayerBtn.Font = Enum.Font.Gotham

toggleBtn.Parent = mainFrame
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
toggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Position = UDim2.new(0.5, -100, 0.55, 0)
toggleBtn.Size = UDim2.new(0, 200, 0, 35)
toggleBtn.Text = "KILL ÔNIBUS TEST"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Font = Enum.Font.GothamBold

statusLabel.Parent = mainFrame
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(0, 10, 0.8, 0)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Text = "Status: Pronto"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham

selectedPlayerLabel.Parent = mainFrame
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.Position = UDim2.new(0, 10, 0.4, 0)
selectedPlayerLabel.Size = UDim2.new(1, -20, 0, 20)
selectedPlayerLabel.Text = "Nenhum jogador selecionado"
selectedPlayerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayerLabel.TextScaled = true
selectedPlayerLabel.Font = Enum.Font.Gotham

-- Tornar arrastável
local dragging = false
local dragInput
local dragStart
local startPos

dragBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

dragBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Variáveis globais
local selectedPlayer = nil
local isActive = false
local magnetActive = false
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local connections = {}

-- Função para limpar conexões
local function cleanup()
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end
	connections = {}
	magnetActive = false
end

-- Função para encontrar VehicleSeat
local function findVehicleSeat()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "VehicleSeat" and obj:IsA("BasePart") then
			return obj
		end
	end
	return nil
end

-- Função para encontrar SchoolBus
local function findSchoolBus()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "SchoolBus" then
			return obj
		end
	end
	return nil
end

-- Função para verificar animação
local function checkAnimation(character)
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Seated then
		return true
	end
	
	for _, obj in pairs(character:GetDescendants()) do
		if obj.Name == "Animation_Sit" or (obj:IsA("Animation") and obj.AnimationId:find("sit")) then
			return true
		end
	end
	return false
end

-- Função de magnetismo
local function activateMagnet()
	if not selectedPlayer or not selectedPlayer.Character then return end
	
	magnetActive = true
	local vehicleSeat = findVehicleSeat()
	local schoolBus = findSchoolBus()
	
	if not vehicleSeat or not schoolBus then
		statusLabel.Text = "Erro: VehicleSeat ou SchoolBus não encontrado"
		return
	end
	
	-- Tween até o VehicleSeat
	local tweenInfo = TweenInfo.new(
		2,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	
	local targetPos = vehicleSeat.Position + Vector3.new(0, 5, 0)
	local tween = tweenService:Create(player.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
	tween:Play()
	
	statusLabel.Text = "Teleportando para VehicleSeat..."
	task.wait(2)
	
	-- Ativar magnetismo
	local magnetStrength = 100
	local rotationSpeed = 5
	
	local magnetConnection = runService.Heartbeat:Connect(function(dt)
		if not magnetActive or not selectedPlayer or not selectedPlayer.Character then
			magnetActive = false
			return
		end
		
		local mainChar = player.Character
		local targetChar = selectedPlayer.Character
		local schoolBusPart = schoolBus:FindFirstChildWhichIsA("BasePart")
		
		if mainChar and targetChar and schoolBusPart then
			local mainRoot = mainChar:FindFirstChild("HumanoidRootPart")
			local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
			
			if mainRoot and targetRoot then
				-- Puxar SchoolBus para o jogador principal
				local busPos = schoolBusPart.Position
				local mainPos = mainRoot.Position
				local direction = (mainPos - busPos).Unit
				schoolBusPart.Velocity = direction * magnetStrength
				
				-- Puxar jogador selecionado para o jogador principal
				local targetDir = (mainPos - targetRoot.Position).Unit
				targetRoot.Velocity = targetDir * magnetStrength
				
				-- Rotacionar SchoolBus
				schoolBusPart.RotVelocity = Vector3.new(0, rotationSpeed, 0)
				
				-- Verificar animação do jogador selecionado
				if checkAnimation(targetChar) then
					-- Dar voo para baixo
					local downTween = tweenService:Create(mainRoot, 
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
						{CFrame = mainRoot.CFrame * CFrame.new(0, -50, 0)}
					)
					downTween:Play()
					
					statusLabel.Text = "Animação detectada! Voo para baixo!"
					task.wait(0.6)
					cleanup()
					magnetActive = false
					statusLabel.Text = "Processo finalizado"
				end
			end
		end
	end)
	
	table.insert(connections, magnetConnection)
end

-- Função principal
local function executeKillBus()
	if not selectedPlayer then
		statusLabel.Text = "Selecione um jogador primeiro!"
		return
	end
	
	if isActive then
		isActive = false
		cleanup()
		toggleBtn.Text = "KILL ÔNIBUS TEST"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		statusLabel.Text = "Status: Desativado"
	else
		isActive = true
		toggleBtn.Text = "DESATIVAR"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		statusLabel.Text = "Status: Ativado - Teleportando..."
		
		-- Teleportar 20 pés (~6.1 metros) de distância
		local playerPos = player.Character and player.Character.HumanoidRootPart.Position
		if playerPos and selectedPlayer.Character then
			local randomDir = Vector3.new(math.random(-10,10), 0, math.random(-10,10)).Unit
			local teleportPos = playerPos + (randomDir * 6.1)
			selectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPos)
		end
		
		task.wait(0.5)
		
		-- Executar o código do FireServer
		local args = {"PickingCar", "SchoolBus"}
		local replicatedStorage = game:GetService("ReplicatedStorage")
		local reFolder = replicatedStorage:FindFirstChild("RE")
		if reFolder then
			local carEvent = reFolder:FindFirstChild("1Ca1r")
			if carEvent then
				carEvent:FireServer(unpack(args))
				statusLabel.Text = "Evento disparado!"
			end
		end
		
		task.wait(1)
		activateMagnet()
	end
end

-- Selecionar jogador
selectPlayerBtn.MouseButton1Click:Connect(function()
	local players = game:GetService("Players"):GetPlayers()
	local playerList = {}
	
	for _, plr in ipairs(players) do
		if plr ~= player then
			table.insert(playerList, plr.Name)
		end
	end
	
	if #playerList == 0 then
		statusLabel.Text = "Nenhum outro jogador online"
		return
	end
	
	-- Criar menu simples de seleção (pode ser melhorado)
	local selectionFrame = Instance.new("Frame")
	selectionFrame.Parent = mainFrame
	selectionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	selectionFrame.BorderColor3 = Color3.fromRGB(255, 170, 0)
	selectionFrame.Position = UDim2.new(0, 10, 0, 30)
	selectionFrame.Size = UDim2.new(1, -20, 0, #playerList * 25)
	selectionFrame.ZIndex = 10
	
	for i, plrName in ipairs(playerList) do
		local btn = Instance.new("TextButton")
		btn.Parent = selectionFrame
		btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		btn.Size = UDim2.new(1, 0, 0, 23)
		btn.Position = UDim2.new(0, 0, 0, (i-1)*25)
		btn.Text = plrName
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.Gotham
		btn.ZIndex = 11
		
		btn.MouseButton1Click:Connect(function()
			selectedPlayer = game.Players:FindFirstChild(plrName)
			selectedPlayerLabel.Text = "Selecionado: " .. plrName
			statusLabel.Text = "Jogador selecionado!"
			selectionFrame:Destroy()
		end)
	end
	
	-- Fechar ao clicar fora
	local function closeOnClick(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local pos = input.Position
			local absPos = selectionFrame.AbsolutePosition
			local absSize = selectionFrame.AbsoluteSize
			if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
				selectionFrame:Destroy()
				game:GetService("UserInputService").InputBegan:Disconnect(closeConnection)
			end
		end
	end
	
	local closeConnection = game:GetService("UserInputService").InputBegan:Connect(closeOnClick)
end)

-- Toggle button
toggleBtn.MouseButton1Click:Connect(executeKillBus)

-- Manter o tool após reset
player.CharacterAdded:Connect(function()
	if screenGui and screenGui.Parent == nil then
		screenGui.Parent = player:WaitForChild("PlayerGui")
	end
end)

-- Inicialização
statusLabel.Text = "Pronto - Selecione um jogador"
