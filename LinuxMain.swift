import SwiftUI

/// Modello di supporto per differenziare i tipi di riga nella cronologia del terminale
struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let isCommand: Bool // True se è il comando digitato dall'utente, False se è la risposta del Kernel
}
public struct ContentView: View {
    // Inizializzazione del Kernel all'avvio dell'applicazione grafica
    @State private var kernel = KernelBootInitializer()
    
    // Variabili di stato per gestire l'input e la cronologia avanzata
    @State private var commandInput: String = ""
    @State private var terminalHistory: [TerminalLine] = []
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Intestazione estetica della finestra del Terminale
            HStack {
                Circle().fill(Color.red).frame(width: 12, height: 12)
                Circle().fill(Color.yellow).frame(width: 12, height: 12)
                Circle().fill(Color.green).frame(width: 12, height: 12)
                Spacer()
                Text("swift-linux-terminal")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Area dello schermo con scorrimento per la cronologia
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        // Banner di benvenuto del Kernel (rimane verde stile boot log)
                        Text(kernel.launchSystemPipeline())
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Rendering dinamico della cronologia dei comandi e delle risposte
                        ForEach(terminalHistory) { line in
                            if line.isCommand {
                                // Se è il comando dell'utente, mostra il prompt colorato e il testo in bianco
                                HStack(spacing: 0) {
                                    Text(kernel.shell?.getPrompt() ?? "root@swift-linux:# ")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.cyan)
                                        .bold()
                                    Text(line.text)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.white) // Testo digitato bianco
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // Se è la risposta del Kernel, la stampa direttamente in bianco puro
                                Text(line.text)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.white) // Output del Kernel bianco
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                // Scorrimento automatico verso il basso all'aggiunta di nuove righe
                .onChange(of: terminalHistory.count) { _ in
                    if let lastLine = terminalHistory.last {
                        withAnimation {
                            proxy.scrollTo(lastLine.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider().background(Color.gray)
            
            // Riga di input interattiva posizionata in basso
            HStack {
                // Prompt dinamico della Shell corrente (es. root@swift-linux:/#)
                Text(kernel.shell?.getPrompt() ?? "root@swift-linux:# ")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.cyan)
                    .bold()
                
                // Campo di inserimento testo per l'utente
                TextField("Type Linux command...", text: $commandInput)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white) // Testo in digitazione bianco
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        submitCommand()
                    }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        // Sfondo scuro opaco stile console di programmazione
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        .cornerRadius(12)
        .padding()
        .preferredColorScheme(.dark)
    }
    
    /// Prende l'input, interroga la logica del Kernel e aggiorna l'interfaccia grafica
    private func submitCommand() {
        let trimmedCommand = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCommand.isEmpty else { return }
        
        // 1. Salva il comando inserito contrassegnandolo come riga utente
        terminalHistory.append(TerminalLine(text: trimmedCommand, isCommand: true))
        
        // 2. Invia la stringa alla Shell del Kernel per l'elaborazione interna
        if let terminalShell = kernel.shell {
            let result = terminalShell.executeCommand(trimmedCommand)
            
            if trimmedCommand == "clear" {
                // Svuota lo schermo se viene richiesto esplicitamente il comando clear
                terminalHistory.removeAll()
            } else {
                // Aggiunge la risposta testuale del Kernel contrassegnandola come riga di output
                terminalHistory.append(TerminalLine(text: result.output, isCommand: false))
            }
        }
        
        // 3. Resetta il campo di testo per la prossima istruzione
        commandInput = ""
    }
}
