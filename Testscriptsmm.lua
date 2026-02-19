// F# script para Roblox - Interface Arrastável com Sistema de Prop
#r "System.Windows.Forms"
#r "System.Drawing"

open System
open System.Drawing
open System.Windows.Forms
open System.Threading
open System.Collections.Generic

// Criar o formulário principal
let form = new Form(Text = "Prop Control System", 
                    Size = Size(300, 350),
                    FormBorderStyle = FormBorderStyle.FixedToolWindow,
                    TopMost = true,
                    StartPosition = FormStartPosition.CenterScreen)

// Variáveis de controle
let mutable isActive = false
let mutable selectedPlayer = ""
let mutable monitoring = false
let mutable playerDied = false
let mutable playerMoved = false

// Criar os controles da interface
let titleLabel = new Label(Text = "🎮 Prop Control", 
                          Font = new Font("Segoe UI", 12f, FontStyle.Bold),
                          Location = Point(10, 10),
                          Size = Size(280, 30),
                          TextAlign = ContentAlignment.MiddleCenter)

let playerCombo = new ComboBox(Location = Point(10, 50),
                               Size = Size(180, 25),
                               DropDownStyle = ComboBoxStyle.DropDownList)

let refreshButton = new Button(Text = "↻", 
                              Location = Point(200, 49),
                              Size = Size(40, 25))

let killButton = new Button(Text = "💀 KILL PLAYER", 
                           Location = Point(10, 85),
                           Size = Size(230, 35),
                           BackColor = Color.IndianRed,
                           ForeColor = Color.White,
                           Font = new Font("Segoe UI", 10f, FontStyle.Bold))

let statusLabel = new Label(Text = "Status: Aguardando...",
                           Location = Point(10, 130),
                           Size = Size(230, 20),
                           ForeColor = Color.Gray)

let progressBar = new ProgressBar(Location = Point(10, 155),
                                 Size = Size(230, 20),
                                 Style = ProgressBarStyle.Marquee,
                                 Visible = false)

let stopButton = new Button(Text = "⏹️ PARAR MONITORAMENTO", 
                           Location = Point(10, 185),
                           Size = Size(230, 35),
                           BackColor = Color.Orange,
                           ForeColor = Color.White,
                           Enabled = false)

let infoLabel = new Label(Text = "Charme Extra: ✨ Sistema Elegante",
                         Location = Point(10, 230),
                         Size = Size(230, 30),
                         ForeColor = Color.Purple,
                         Font = new Font("Segoe UI", 9f, FontStyle.Italic))

// Área para arrastar
let dragPanel = new Panel(Location = Point(0, 0),
                         Size = Size(300, 30),
                         BackColor = Color.FromArgb(51, 51, 76))

let dragLabel = new Label(Text = "≡ ARRASTE AQUI", 
                         Location = Point(10, 5),
                         Size = Size(280, 20),
                         ForeColor = Color.White,
                         Font = new Font("Segoe UI", 9f))

// Adicionar controles ao formulário
dragPanel.Controls.Add(dragLabel)
form.Controls.AddRange([| dragPanel; titleLabel; playerCombo; refreshButton; 
                          killButton; statusLabel; progressBar; stopButton; infoLabel |])

// Variáveis para arrastar
let mutable dragOffset = Point()
let mutable isDragging = false

// Eventos de arrastar
dragPanel.MouseDown.Add(fun e ->
    if e.Button = MouseButtons.Left then
        isDragging <- true
        dragOffset <- Point(e.X, e.Y))

dragPanel.MouseMove.Add(fun e ->
    if isDragging then
        form.Location <- Point(form.Location.X + e.X - dragOffset.X, 
                               form.Location.Y + e.Y - dragOffset.Y))

dragPanel.MouseUp.Add(fun e ->
    isDragging <- false)

// Função para atualizar lista de jogadores
let updatePlayerList() =
    try
        playerCombo.Items.Clear()
        // Simulação - em ambiente real, aqui viria a lista do jogo
        let players = [| "Player1"; "Player2"; "Player3"; "JogadorSelecionado" |]
        playerCombo.Items.AddRange(players |> Array.map box)
        if playerCombo.Items.Count > 0 then
            playerCombo.SelectedIndex <- 0
        statusLabel.Text <- "✅ Players carregados"
        statusLabel.ForeColor <- Color.Green
    with ex ->
        statusLabel.Text <- "❌ Erro ao carregar players"
        statusLabel.ForeColor <- Color.Red

// Função principal de execução
let executePropSequence() =
    if String.IsNullOrEmpty(selectedPlayer) then
        MessageBox.Show("Selecione um player primeiro!", "Aviso", 
                       MessageBoxButtons.OK, MessageBoxIcon.Warning) |> ignore
    else
        isActive <- true
        killButton.Enabled <- false
        stopButton.Enabled <- true
        progressBar.Visible <- true
        monitoring <- true
        playerDied <- false
        
        statusLabel.Text <- "🎯 Iniciando sequência..."
        statusLabel.ForeColor <- Color.Blue
        
        // Thread para execução
        let workerThread = new Thread(fun () ->
            try
                // Passo 1: Invocar ferramentas
                form.Invoke(Action(fun () -> 
                    statusLabel.Text <- "🔧 Invocando ferramentas..."
                )) |> ignore
                
                Thread.Sleep(1000)
                
                // Executar código PickingTools/PropMaker
                let args1 = [| "PickingTools"; "PropMaker" |]
                // game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args1))
                printfn "Executando: 1Too1l com %A" args1
                
                Thread.Sleep(3000) // Esperar 3 segundos
                
                // Passo 2: Equipar PropMaker
                form.Invoke(Action(fun () -> 
                    statusLabel.Text <- "🔨 Equipando PropMaker..."
                )) |> ignore
                
                // Executar código TelemetryClientInteraction
                let args2 = [| 
                    "filterClick"
                    box {| name = "FurnitureBleachers"; itemType = "Props"; filter = "Home" |}
                |]
                // game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TelemetryClientInteraction"):FireServer(unpack(args2))
                printfn "Executando: TelemetryClientInteraction com %A" args2
                
                // Monitoramento contínuo
                let random = Random()
                
                while monitoring && not playerDied do
                    form.Invoke(Action(fun () -> 
                        statusLabel.Text <- sprintf "👀 Monitorando %s..." selectedPlayer
                    )) |> ignore
                    
                    // Simular verificação de animação/movimento
                    playerMoved <- random.Next(0, 10) < 3 // 30% de chance de movimento
                    
                    if playerMoved then
                        form.Invoke(Action(fun () -> 
                            statusLabel.Text <- "⚡ Movimento detectado! Executando ação rápida..."
                            statusLabel.ForeColor <- Color.Orange
                        )) |> ignore
                        
                        // Executar código rápido para movimento
                        let cframe1 = "-624.6739501953125, 0.02499866485595703, -82.41798400878906"
                        let args3 = [| box cframe1 |]
                        // workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones"):WaitForChild("Propookjhndvj"):WaitForChild("SetCurrentCFrame"):InvokeServer(unpack(args3))
                        printfn "Movimento detectado: Atualizando CFrame para %s" cframe1
                        
                        // Executar segundo código rápido
                        let cframe2 = "-653.845947265625, -101.18560791015625, -37.66075897216797"
                        let args4 = [| box cframe2 |]
                        // workspace:WaitForChild("WorkspaceCom"):WaitForChild("001_TrafficCones"):WaitForChild("Propookjhndvj"):WaitForChild("SetCurrentCFrame"):InvokeServer(unpack(args4))
                        printfn "Segunda atualização rápida para %s" cframe2
                        
                        Thread.Sleep(100)
                        playerMoved <- false
                    
                    // Simular verificação de morte
                    if random.Next(0, 15) < 2 then // ~13% de chance de morte
                        playerDied <- true
                        form.Invoke(Action(fun () -> 
                            statusLabel.Text <- "💀 PLAYER MORREU! Limpando props..."
                            statusLabel.ForeColor <- Color.Red
                        )) |> ignore
                        
                        // Executar código ClearAllProps
                        let args5 = [| "ClearAllProps" |]
                        // game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer(unpack(args5))
                        printfn "Player morreu: Executando ClearAllProps"
                        
                        // Aguardar 1 minuto para poder parar
                        form.Invoke(Action(fun () -> 
                            statusLabel.Text <- "⏱️ Aguardando 1 minuto..."
                        )) |> ignore
                        
                        for i = 1 to 60 do
                            if monitoring then
                                Thread.Sleep(1000) // 1 segundo cada iteração
                            else
                                ()
                        done
                        
                        playerDied <- false // Reset para continuar monitorando
                    
                    Thread.Sleep(2000) // Verificar a cada 2 segundos
                
            with ex ->
                form.Invoke(Action(fun () -> 
                    statusLabel.Text <- sprintf "❌ Erro: %s" ex.Message
                    statusLabel.ForeColor <- Color.Red
                )) |> ignore
            finally
                form.Invoke(Action(fun () -> 
                    isActive <- false
                    killButton.Enabled <- true
                    stopButton.Enabled <- false
                    progressBar.Visible <- false
                    statusLabel.Text <- "⏸️ Monitoramento parado"
                    statusLabel.ForeColor <- Color.Gray
                    monitoring <- false
                )) |> ignore
        )
        
        workerThread.IsBackground <- true
        workerThread.Start()

// Eventos dos botões
refreshButton.Click.Add(fun _ -> updatePlayerList())

playerCombo.SelectedIndexChanged.Add(fun _ ->
    if playerCombo.SelectedItem <> null then
        selectedPlayer <- playerCombo.SelectedItem.ToString()
        statusLabel.Text <- sprintf "👤 Player selecionado: %s" selectedPlayer)

killButton.Click.Add(fun _ -> executePropSequence())

stopButton.Click.Add(fun _ ->
    monitoring <- false
    statusLabel.Text <- "⏹️ Parando monitoramento..."
    statusLabel.ForeColor <- Color.Orange)

// Atualizar lista ao iniciar
form.Load.Add(fun _ -> updatePlayerList())

// Iniciar aplicação
Application.Run(form)
