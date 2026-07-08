//: [Previous](@previous)

import Foundation

/*
 Singleton — garante que uma classe tenha UMA única instância e oferece um ponto
 de acesso global a ela.
 Problema que resolve: quando várias partes do app criam seus próprios objetos de
 configuração, cada uma enxerga um estado diferente. O Singleton faz todos
 compartilharem a MESMA instância, mantendo o estado consistente.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Cada tela cria a SUA própria instância do gerenciador de configurações.
// Como são objetos diferentes, o que uma tela grava a outra não vê → estado
// inconsistente e bugs difíceis de rastrear.
class SettingsManagerBefore {
    var temperatureUnit: String = "Celsius"
    var isDarkMode: Bool = false

    init() {
        print("Novo SettingsManagerBefore criado")
    }
}

// Uso — telas diferentes, instâncias diferentes
let settingsFromScreenA = SettingsManagerBefore()
settingsFromScreenA.temperatureUnit = "Fahrenheit"   // a tela A muda a unidade

let settingsFromScreenB = SettingsManagerBefore()     // a tela B cria OUTRA instância
print("Antes -> Tela B lê: \(settingsFromScreenB.temperatureUnit)")
// Tela B lê "Celsius" — não enxergou a mudança feita na Tela A

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Singleton
// ========================================================

// 1. A instância única e compartilhada fica em `static let shared`.
//    `static let` também garante criação thread-safe e sob demanda em Swift.
final class SettingsManager {
    static let shared = SettingsManager()

    var temperatureUnit: String = "Celsius"
    var isDarkMode: Bool = false

    // 2. init privado — ninguém de fora consegue criar outra instância;
    //    o único caminho é passar por `SettingsManager.shared`.
    private init() {
        print("SettingsManager criado (única vez)")
    }
}

// 3. Uso — qualquer tela acessa a MESMA instância pelo ponto global.
SettingsManager.shared.temperatureUnit = "Fahrenheit"   // a tela A muda a unidade

// a tela B lê o mesmo objeto compartilhado
print("Depois -> Tela B lê: \(SettingsManager.shared.temperatureUnit)")
// Tela B lê "Fahrenheit" — estado consistente entre todas as telas

// 4. Cuidados (uso didático):
//    - o acesso global facilita, mas cria acoplamento escondido (qualquer código
//      pode ler/alterar o estado, dificultando rastrear quem mudou o quê);
//    - dificulta testes, pois o estado persiste entre casos de teste;
//    - use com parcimônia, só para recursos realmente únicos
//      (configurações, logger, cache).

//: [Next](@next)
