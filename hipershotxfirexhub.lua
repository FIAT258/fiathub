-- Teste mínimo Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
if not Fluent then
    warn("Falha ao carregar Fluent")
    return
end
local Window = Fluent:CreateWindow({
    Title = "Teste",
    SubTitle = "by teste",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})
local Tab = Window:AddTab({ Title = "Main", Icon = "home" })
Tab:AddButton({ Title = "Botão", Callback = function() print("ok") end })
Fluent:Notify({ Title = "Teste", Content = "Funcionou!" })
