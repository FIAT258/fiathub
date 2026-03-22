local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Teste WindUI",
    Size = UDim2.fromOffset(500, 400)
})
local Tab1 = Window:Tab({ Title = "Aba 1" })
local Tab2 = Window:Tab({ Title = "Aba 2" })
local Tab3 = Window:Tab({ Title = "Aba 3" })
Tab1:Paragraph({ Title = "Ok", Desc = "Funcionou!" })
