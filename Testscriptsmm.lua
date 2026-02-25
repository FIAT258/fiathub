--// LOAD WIND UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// CREATE WINDOW (NÃO REMOVIDO NADA)
local Window = WindUI:CreateWindow({
    Title = "My Super Hub",
    Icon = "door-open",
    Author = "by .ftgs and .ftgs",
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

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("User clicked")
        end,
    },

    KeySystem = {
        Key = { "1234", "5678" },
        Note = "Example Key System.",
        Thumbnail = {
            Image = "rbxassetid://",
            Title = "Thumbnail",
        },
        URL = "YOUR LINK TO GET KEY",
        SaveKey = false,
    },
})

--// TAG AO LADO DO TÍTULO
Window:Tag({
    Title = "v1",
    Icon = "github",
    Color = Color3.fromHex("#30ff6a"),
    Radius = 6,
})

--// NOTIFICAÇÃO AO ABRIR
WindUI:Notify({
    Title = "WindUI carregado",
    Content = "Interface iniciada com sucesso!",
    Duration = 4,
    Icon = "check",
})

--------------------------------------------------
--// TAB 1 - TESTES BÁSICOS
--------------------------------------------------
local TabTest = Window:Tab({
    Title = "Testes",
    Icon = "flask",
})

-- BOTÃO
TabTest:Button({
    Title = "Botão de Teste",
    Desc = "Clique para testar",
    Callback = function()
        print("Botão clicado")
        WindUI:Notify({
            Title = "Botão",
            Content = "Você clicou no botão!",
            Duration = 3,
            Icon = "mouse-pointer-click",
        })
    end
})

-- TOGGLE
TabTest:Toggle({
    Title = "Ativar modo teste",
    Desc = "Liga / desliga algo",
    Icon = "power",
    Value = false,
    Callback = function(state)
        print("Toggle:", state)
    end
})

-- SLIDER
TabTest:Slider({
    Title = "Velocidade Fake",
    Desc = "Slider de exemplo",
    Step = 1,
    Value = {
        Min = 1,
        Max = 100,
        Default = 50,
    },
    Callback = function(value)
        print("Slider valor:", value)
    end
})

--------------------------------------------------
--// TAB 2 - INPUT E DROPDOWN
--------------------------------------------------
local TabInput = Window:Tab({
    Title = "Inputs",
    Icon = "keyboard",
})

-- INPUT
TabInput:Input({
    Title = "Nome",
    Desc = "Digite qualquer coisa",
    Placeholder = "Digite aqui...",
    Callback = function(text)
        print("Texto digitado:", text)
    end
})

-- DROPDOWN
TabInput:Dropdown({
    Title = "Opções",
    Desc = "Escolha múltipla",
    Values = { "Opção A", "Opção B", "Opção C" },
    Value = { "Opção A" },
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        print("Selecionado:", game:GetService("HttpService"):JSONEncode(options))
    end
})

--------------------------------------------------
--// TAB 3 - PARAGRAPH
--------------------------------------------------
local TabInfo = Window:Tab({
    Title = "Info",
    Icon = "info",
})

TabInfo:Paragraph({
    Title = "WindUI Teste",
    Desc = "Esse parágrafo é só para confirmar que tudo está funcionando corretamente.",
    Color = "Green",
    Buttons = {
        {
            Icon = "bell",
            Title = "Aviso",
            Callback = function()
                WindUI:Notify({
                    Title = "Aviso",
                    Content = "Botão do parágrafo clicado!",
                    Duration = 3,
                    Icon = "alert-circle",
                })
            end
        }
    }
})
