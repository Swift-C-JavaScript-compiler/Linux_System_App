import SwiftUI

@main
struct LinuxApp: App {
  // Configurazione del punto d'ingresso obbligatorio per l'avvio delle applicazioni Swift
  var body: some Scene {
    WindowGroup {
      // Mostra la finestra principale con la console grafica del terminale
      LinuxMain()
    }
  }
}
