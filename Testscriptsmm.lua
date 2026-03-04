--[[
    ██████╗ ██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝
    ██████╔╝██║     ██║   ██║ ╚███╔╝ 
    ██╔══██╗██║     ██║   ██║ ██╔██╗ 
    ██████╔╝███████╗╚██████╔╝██╔╝ ██╗
    ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
    
    BLOX FRUITS TEST HUB - v1.0
    Apenas para teste da WindUI
]]

--// CARREGAR WIND UI
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--// VARIÁVEIS GLOBAIS PARA TESTE
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--// CRIAR JANELA PRINCIPAL
local Window = WindUI:CreateWindow({
    Title = "Blox Fruits Test Hub",
    Icon = "sword",  -- Ícone temático
    Author = "by Teste",
    Folder = "BloxFruitsTest",

    Size = UDim2.fromOffset(600, 480),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(900, 600),
    Transparent = true,
    Theme = "Dark",  -- Pode mudar para "Light", "Darker", etc
    Resizable = true,
    SideBarWidth = 210,
    BackgroundImageTransparency = 0.35,
    HideSearchBar = false,  -- Deixar visível para teste
    ScrollBarEnabled = true,

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("[USER] Botão do usuário clicado")
            WindUI:Notify({
                Title = "Usuário",
                Content = "Menu de perfil (em desenvolvimento)",
                Duration = 3,
                Icon = "user",
            })
        end,
    },

    KeySystem = {
        Key = { "BLOXFRUITS2024", "TESTE123" },
        Note = "Hub em teste - use qualquer key acima",
        Thumbnail = {
            Image = "rbxassetid://84973708912590",  -- Coloque um ID de imagem se quiser
            Title = "Blox Fruits Test",
        },
        URL = "https://discord.gg/exemplo",
        SaveKey = false,
    },
})

--// TAG DE VERSÃO
Window:Tag({
    Title = "BETA v1.0",
    Icon = "flask",
    Color = Color3.fromHex("#FF6B6B"),
    Radius = 8,
})

--// NOTIFICAÇÃO INICIAL
WindUI:Notify({
    Title = "⚔️ Blox Fruits Test Hub",
    Content = "Interface carregada! Todas as funções são apenas para teste (prints)",
    Duration = 5,
    Icon = "info",
})

--------------------------------------------------
--// TAB 1 - MAIN (PRINCIPAL)
--------------------------------------------------
local MainTab = Window:Tab({
    Title = "Principal",
    Icon = "home",
})

-- SEÇÃO: AUTO FARM
MainTab:Paragraph({
    Title = "⚙️ Auto Farm",
    Desc = "Configurações automáticas de farm",
    Color = "Blue",
})

MainTab:Toggle({
    Title = "Auto Farm Master",
    Desc = "Farm automático de níveis",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        print("[AUTO FARM] Auto Farm Master:", state)
        if state then
            WindUI:Notify({
                Title = "Auto Farm",
                Content = "Farm automático ativado (modo teste)",
                Duration = 3,
                Icon = "play",
            })
        end
    end
})

MainTab:Toggle({
    Title = "Auto Quest",
    Desc = "Aceita e completa quests automaticamente",
    Icon = "scroll",
    Value = false,
    Callback = function(state)
        print("[QUESTS] Auto Quest:", state)
    end
})

MainTab:Toggle({
    Title = "Auto Next Island",
    Desc = "Vai automaticamente para próxima ilha",
    Icon = "ship",
    Value = false,
    Callback = function(state)
        print("[NAVEGAÇÃO] Auto Next Island:", state)
    end
})

-- SEÇÃO: COMBATE
MainTab:Paragraph({
    Title = "⚔️ Combate",
    Desc = "Configurações de batalha",
    Color = "Red",
})

MainTab:Slider({
    Title = "Velocidade de Ataque",
    Desc = "Velocidade dos golpes",
    Step = 0.1,
    Value = {
        Min = 1,
        Max = 10,
        Default = 1,
    },
    Callback = function(value)
        print("[COMBATE] Velocidade de ataque ajustada para:", value)
    end
})

MainTab:Toggle({
    Title = "Auto Click (M1)",
    Desc = "Clica automaticamente em inimigos",
    Icon = "mouse-pointer-click",
    Value = false,
    Callback = function(state)
        print("[COMBATE] Auto Click:", state)
    end
})

MainTab:Toggle({
    Title = "Auto Skill",
    Desc = "Usa habilidades automaticamente",
    Icon = "sparkles",
    Value = false,
    Callback = function(state)
        print("[COMBATE] Auto Skill:", state)
    end
})

--------------------------------------------------
--// TAB 2 - FRUTAS
--------------------------------------------------
local FruitTab = Window:Tab({
    Title = "Frutas",
    Icon = "apple",
})

-- SEÇÃO: CONFIGURAÇÕES DE FRUTA
FruitTab:Paragraph({
    Title = "🍎 Configurações de Fruta",
    Desc = "Opções relacionadas às frutas do jogo",
    Color = "Green",
})

FruitTab:Dropdown({
    Title = "Fruta Principal",
    Desc = "Selecione sua fruta principal",
    Values = { 
        "Magma", "Buddha", "Dark", "Ice", "Flame", 
        "Light", "Quake", "Rumble", "Sand", "String",
        "Dragon", "Venom", "Soul", "Dough", "Shadow"
    },
    Value = { "Buddha" },
    Multi = false,
    Callback = function(options)
        print("[FRUTA] Fruta selecionada:", options[1])
    end
})

FruitTab:Toggle({
    Title = "Auto Store Fruit",
    Desc = "Armazena fruta automaticamente ao spawnar",
    Icon = "package",
    Value = false,
    Callback = function(state)
        print("[FRUTA] Auto Store:", state)
    end
})

FruitTab:Toggle({
    Title = "Auto Farm Fruit",
    Desc = "Farm específico para frutas",
    Icon = "apple",
    Value = false,
    Callback = function(state)
        print("[FRUTA] Auto Farm Fruit:", state)
    end
})

FruitTab:Slider({
    Title = "Distância para coletar fruta",
    Desc = "Distância em studs",
    Step = 10,
    Value = {
        Min = 50,
        Max = 500,
        Default = 200,
    },
    Callback = function(value)
        print("[FRUTA] Distância de coleta:", value, "studs")
    end
})

FruitTab:Button({
    Title = "Teleport para Fruit Spawns",
    Desc = "Vai para locais onde frutas spawnam",
    Callback = function()
        print("[FRUTA] Teleportando para spawns de fruta")
        WindUI:Notify({
            Title = "Teleport",
            Content = "Teleportando para área de frutas (modo teste)",
            Duration = 3,
            Icon = "map-pin",
        })
    end
})

--------------------------------------------------
--// TAB 3 - TELEPORTS
--------------------------------------------------
local TeleportTab = Window:Tab({
    Title = "Teleports",
    Icon = "map",
})

-- SEÇÃO: ILHAS
TeleportTab:Paragraph({
    Title = "🏝️ Ilhas",
    Desc = "Teleporte rápido entre ilhas",
    Color = "Purple",
})

-- DROPDOWN DE ILHAS
TeleportTab:Dropdown({
    Title = "Ilhas do 1º Mar",
    Desc = "Teleport para ilhas do primeiro mar",
    Values = { 
        "Ilha Inicial", "Marina", "Ilha do Café", "Ilha do Gelo",
        "Ilha do Peixe", "Ilha Magma", "Coliseu", "Ilha do Céu",
        "Ilha da Neve", "Ilha do Palácio"
    },
    Value = { "Ilha Inicial" },
    Multi = false,
    Callback = function(options)
        print("[TELEPORT] Teleportando para:", options[1])
    end
})

TeleportTab:Button({
    Title = "Ir para 2º Mar",
    Desc = "Teleport para o segundo mar",
    Callback = function()
        print("[TELEPORT] Indo para 2º Mar")
        WindUI:Notify({
            Title = "Teleport",
            Content = "Indo para o Segundo Mar (modo teste)",
            Duration = 3,
            Icon = "arrow-right",
        })
    end
})

TeleportTab:Button({
    Title = "Ir para 3º Mar",
    Desc = "Teleport para o terceiro mar",
    Callback = function()
        print("[TELEPORT] Indo para 3º Mar")
        WindUI:Notify({
            Title = "Teleport",
            Content = "Indo para o Terceiro Mar (modo teste)",
            Duration = 3,
            Icon = "arrow-right",
        })
    end
})

-- SEÇÃO: BOSSES
TeleportTab:Paragraph({
    Title = "👾 Bosses",
    Desc = "Teleport para locais de bosses",
    Color = "Orange",
})

TeleportTab:Button({
    Title = "Saber (NPC)",
    Callback = function()
        print("[BOSS] Teleportando para Saber")
    end
})

TeleportTab:Button({
    Title = "Don Swan",
    Callback = function()
        print("[BOSS] Teleportando para Don Swan")
    end
})

TeleportTab:Button({
    Title = "Fajita",
    Callback = function()
        print("[BOSS] Teleportando para Fajita")
    end
})

TeleportTab:Button({
    Title = "Order (Raid Boss)",
    Callback = function()
        print("[BOSS] Teleportando para Order")
    end
})

--------------------------------------------------
--// TAB 4 - PLAYER
--------------------------------------------------
local PlayerTab = Window:Tab({
    Title = "Jogador",
    Icon = "user",
})

-- SEÇÃO: ESTATÍSTICAS
PlayerTab:Paragraph({
    Title = "📊 Estatísticas",
    Desc = "Visualize e modifique stats",
    Color = "Blue",
})

PlayerTab:Slider({
    Title = "WalkSpeed",
    Desc = "Velocidade de movimento",
    Step = 1,
    Value = {
        Min = 16,
        Max = 250,
        Default = 16,
    },
    Callback = function(value)
        print("[PLAYER] WalkSpeed alterado para:", value)
    end
})

PlayerTab:Slider({
    Title = "JumpPower",
    Desc = "Força do pulo",
    Step = 5,
    Value = {
        Min = 50,
        Max = 500,
        Default = 50,
    },
    Callback = function(value)
        print("[PLAYER] JumpPower alterado para:", value)
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Pulo infinito",
    Icon = "chevrons-up",
    Value = false,
    Callback = function(state)
        print("[PLAYER] Infinite Jump:", state)
    end
})

PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Atravessar paredes",
    Icon = "ghost",
    Value = false,
    Callback = function(state)
        print("[PLAYER] Noclip:", state)
    end
})

-- SEÇÃO: VISUAIS
PlayerTab:Paragraph({
    Title = "👁️ Visuais",
    Desc = "Configurações visuais",
})

PlayerTab:Input({
    Title = "Nome Espectral",
    Desc = "Muda a cor do nome",
    Placeholder = "Ex: #FF0000",
    Callback = function(text)
        print("[VISUAL] Cor do nome alterada para:", text)
    end
})

PlayerTab:Toggle({
    Title = "ESP Inimigos",
    Desc = "Destaca inimigos na tela",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        print("[ESP] Inimigos:", state)
    end
})

PlayerTab:Toggle({
    Title = "ESP Frutas",
    Desc = "Destaca frutas no chão",
    Icon = "eye",
    Value = false,
    Callback = function(state)
        print("[ESP] Frutas:", state)
    end
})

--------------------------------------------------
--// TAB 5 - RAIDS
--------------------------------------------------
local RaidTab = Window:Tab({
    Title = "Raids",
    Icon = "shield",
})

RaidTab:Paragraph({
    Title = "⚡ Configurações de Raid",
    Desc = "Opções para raids e dungeons",
    Color = "Red",
})

RaidTab:Toggle({
    Title = "Auto Raid",
    Desc = "Completa raids automaticamente",
    Icon = "sword",
    Value = false,
    Callback = function(state)
        print("[RAID] Auto Raid:", state)
    end
})

RaidTab:Dropdown({
    Title = "Chip de Raid",
    Desc = "Tipo de chip para usar",
    Values = { 
        "Flame", "Ice", "Quake", "Light", "Dark",
        "String", "Rumble", "Magma", "Human: Buddha"
    },
    Value = { "Flame" },
    Multi = false,
    Callback = function(options)
        print("[RAID] Chip selecionado:", options[1])
    end
})

RaidTab:Slider({
    Title = "Quantidade de Chips",
    Desc = "Número de chips para farmar",
    Step = 1,
    Value = {
        Min = 1,
        Max = 10,
        Default = 1,
    },
    Callback = function(value)
        print("[RAID] Quantidade de chips:", value)
    end
})

RaidTab:Button({
    Title = "Iniciar Raid",
    Desc = "Começa a raid com configurações atuais",
    Callback = function()
        print("[RAID] Iniciando raid...")
        WindUI:Notify({
            Title = "Raid",
            Content = "Iniciando raid (modo teste)",
            Duration = 4,
            Icon = "play",
        })
    end
})

--------------------------------------------------
--// TAB 6 - CONFIGURAÇÕES
--------------------------------------------------
local SettingsTab = Window:Tab({
    Title = "Configurações",
    Icon = "settings",
})

SettingsTab:Paragraph({
    Title = "🎨 Interface",
    Desc = "Personalize a aparência da UI",
})

SettingsTab:Dropdown({
    Title = "Tema",
    Desc = "Muda o tema da interface",
    Values = { "Dark", "Light", "Darker", "Midnight", "Ocean" },
    Value = { "Dark" },
    Multi = false,
    Callback = function(options)
        print("[UI] Tema alterado para:", options[1])
        -- Não muda realmente o tema porque é só teste
    end
})

SettingsTab:Slider({
    Title = "Transparência",
    Desc = "Transparência da interface",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 0.8,
        Default = 0.35,
    },
    Callback = function(value)
        print("[UI] Transparência:", value)
    end
})

SettingsTab:Toggle({
    Title = "Salvar Configurações",
    Desc = "Salva as configurações automaticamente",
    Icon = "save",
    Value = true,
    Callback = function(state)
        print("[CONFIG] Auto Save:", state)
    end
})

SettingsTab:Button({
    Title = "Resetar Configurações",
    Desc = "Volta às configurações padrão",
    Callback = function()
        print("[CONFIG] Resetando configurações")
        WindUI:Notify({
            Title = "Configurações",
            Content = "Configurações resetadas (modo teste)",
            Duration = 3,
            Icon = "rotate-ccw",
        })
    end
})

--------------------------------------------------
--// TAB 7 - SOBRE
--------------------------------------------------
local AboutTab = Window:Tab({
    Title = "Sobre",
    Icon = "info",
})

AboutTab:Paragraph({
    Title = "📌 Blox Fruits Test Hub",
    Desc = [[
        Versão: 1.0.0 (Teste)
        
        Este é um hub de teste para demonstrar
        as funcionalidades da WindUI em um contexto
        de Blox Fruits.
        
        Todas as funções são apenas ilustrativas
        e usam print() para demonstrar o funcionamento.
        
        Características:
        • Interface completa com 7 abas
        • Sistema de keys incluso
        • Múltiplos tipos de elementos
        • Design responsivo
        
        Desenvolvido com WindUI
        Ícones por Lucide Icons
    ]],
    Color = "Blue",
})

AboutTab:Button({
    Title = "📋 Copiar Discord",
    Desc = "Copia link do Discord",
    Callback = function()
        setclipboard("https://discord.gg/bloxfruits")
        WindUI:Notify({
            Title = "Discord",
            Content = "Link copiado para área de transferência!",
            Duration = 3,
            Icon = "clipboard-copy",
        })
    end
})

AboutTab:Button({
    Title = "🔄 Verificar Updates",
    Desc = "Checa por novas versões",
    Callback = function()
        print("[UPDATE] Verificando...")
        WindUI:Notify({
            Title = "Updates",
            Content = "Nenhuma atualização encontrada (modo teste)",
            Duration = 3,
            Icon = "refresh-cw",
        })
    end
})

--// NOTIFICAÇÃO FINAL
task.wait(1)
WindUI:Notify({
    Title = "✅ Pronto para teste!",
    Content = "Todas as funções estão em modo debug (prints)",
    Duration = 4,
    Icon = "check-circle",
})

print("=== BLOX FRUITS TEST HUB CARREGADO ===")
print("Jogador:", player.Name)
print("Personagem:", character.Name)
print("Interface de teste pronta para uso!")
