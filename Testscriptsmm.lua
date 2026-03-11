local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Enabled = true
local Sounds = {}
local MaxSounds = 20

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SoundLogger"
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0,300,0,250)
main.Position = UDim2.new(0.3,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(40,40,40)
main.Parent = gui

-- TITULO
local title = Instance.new("TextButton")
title.Size = UDim2.new(1,0,0,30)
title.Text = "Sound Logger"
title.BackgroundColor3 = Color3.fromRGB(0,200,0)
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

-- MINIMIZAR
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-30,0,0)
minimize.Text = "-"
minimize.Parent = main

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,-30)
scroll.Position = UDim2.new(0,0,0,30)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ARRSTAR
local dragging = false
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- ATIVAR / DESATIVAR COPIAR
title.MouseButton1Click:Connect(function()
	Enabled = not Enabled
	
	if Enabled then
		title.BackgroundColor3 = Color3.fromRGB(0,200,0)
	else
		title.BackgroundColor3 = Color3.fromRGB(200,0,0)
	end
end)

-- MINIMIZAR
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	
	scroll.Visible = not minimized
	
	if minimized then
		main.Size = UDim2.new(0,300,0,30)
	else
		main.Size = UDim2.new(0,300,0,250)
	end
end)

-- CRIAR BOTAO
local function createButton(id)

	if #Sounds >= MaxSounds then
		local old = table.remove(Sounds,1)
		old:Destroy()
	end
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-5,0,30)
	frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
	frame.Parent = scroll
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.7,0,1,0)
	text.Text = id
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.Parent = frame
	
	if Enabled then
		local copy = Instance.new("TextButton")
		copy.Size = UDim2.new(0.3,0,1,0)
		copy.Position = UDim2.new(0.7,0,0,0)
		copy.Text = "Copiar"
		copy.Parent = frame
		
		copy.MouseButton1Click:Connect(function()
			setclipboard(id)
		end)
	end
	
	table.insert(Sounds,frame)
	
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end

-- DETECTAR SONS
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Sound") then
		
		obj.Played:Connect(function()
			
			local id = obj.SoundId
			
			if id ~= "" then
				id = string.gsub(id,"rbxassetid://","")
				createButton(id)
			end
			
		end)
		
	end
end)
