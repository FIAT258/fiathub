-- Carregar WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Criar janela principal
local Window = WindUI:CreateWindow({
    Title = "Teste WindUI",
    Icon = "star",
    Author = "Teste",
    Folder = "TesteHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "rbxassetid://121164944768475" -- opcional
})

-- Notificação de carregamento
WindUI:Notify({
    Title = "WindUI",
    Content = "Interface carregada com sucesso!",
    Duration = 3
})

-- Criar algumas abas para teste
local Tab1 = Window:Tab({ Title = "Principal", Icon = "home" })
local Tab2 = Window:Tab({ Title = "Configurações", Icon = "settings" })
local Tab3 = Window:Tab({ Title = "Sobre", Icon = "info" })

-- Adicionar elementos na aba Principal
Tab1:Button({
    Title = "Botão de Teste",
    Callback = function()
        print("Botão clicado!")
        WindUI:Notify({
            Title = "Teste",
            Content = "Você clicou no botão!",
            Duration = 2
        })
    end
})

Tab1:Toggle({
    Title = "Toggle de Teste",
    Default = false,
    Callback = function(state)
        print("Toggle:", state)
    end
})

Tab1:Slider({
    Title = "Slider de Teste",
    Value = {
        Min = 0,
        Max = 100,
        Default = 50
    },
    Callback = function(value)
        print("Slider:", value)
    end
})

-- Adicionar elementos na aba Configurações
Tab2:Dropdown({
    Title = "Dropdown de Teste",
    Values = {"Opção 1", "Opção 2", "Opção 3"},
    Callback = function(option)
        print("Dropdown:", option)
    end
})

Tab2:Input({
    Title = "Input de Teste",
    Placeholder = "Digite algo...",
    Callback = function(text)
        print("Input:", text)
    end
})

-- Adicionar texto na aba Sobre
Tab3:Paragraph({
    Title = "Informações",
    Desc = "Esta é uma interface de teste para verificar se a WindUI está funcionando corretamente.\n\nSe você está vendo esta mensagem, a UI foi carregada com sucesso!"
})

print("Interface de teste carregada.")
