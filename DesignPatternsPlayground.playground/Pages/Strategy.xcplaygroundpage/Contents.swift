//: [Previous](@previous)

import Foundation

/*
 Strategy Pattern — define uma família de algoritmos, encapsula cada um e os torna
 intercambiáveis em tempo de execução.
 Problema que resolve: elimina o if/else que escolhe "qual algoritmo usar" dentro de
 uma classe. Trocar ou adicionar um algoritmo deixa de exigir editar essa classe.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// A própria Light decide COMO enviar o sinal, checando o tipo de conexão com if/else.
// Para suportar um novo tipo de conexão (ex: Zigbee), é preciso EDITAR a Light e
// adicionar mais um "else if" — violando o Aberto/Fechado (aberta a extensão, fechada
// a modificação).
class LightBefore {
    private var isOn: Bool = false
    private var connectionType: String   // "bluetooth" ou "wifi"

    init(connectionType: String) { self.connectionType = connectionType }

    func toggle() {
        let newState = !isOn

        // a lógica de cada conexão fica misturada aqui dentro
        if connectionType == "bluetooth" {
            print("Enviando via Bluetooth: \(newState ? "ligado" : "desligado")")
        } else if connectionType == "wifi" {
            print("Enviando via Wifi: \(newState ? "ligado" : "desligado")")
        }
        // ... um novo tipo de conexão = mais um "else if" aqui, editando esta classe

        isOn.toggle()
    }
}

// Uso — o tipo de conexão é uma String frágil
LightBefore(connectionType: "bluetooth").toggle()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Strategy Pattern
// ========================================================

// 1. O Contexto (A Luz) guarda o estado, mas NÃO sabe como o sinal é enviado.
//    A estratégia é injetada e pode ser trocada sem editar a Light.
class Light {
    private var isOn: Bool = false
    private var connectionMethod: ConnectionStrategy // o "cérebro" intercambiável

    init(method: ConnectionStrategy) { self.connectionMethod = method }

    func toggle() {
        // o Strategy decide COMO a mensagem chega na lâmpada física
        connectionMethod.sendSignal(toState: !isOn)
        isOn.toggle()
    }
}

// 2. A abstração da estratégia — o contrato que toda conexão deve cumprir.
protocol ConnectionStrategy {
    func sendSignal(toState: Bool)
}

// 3. Estratégias concretas — cada tipo de conexão é uma implementação isolada.
//    Adicionar uma nova conexão = criar um novo struct, sem tocar na Light.
struct BluetoothStrategy: ConnectionStrategy {
    func sendSignal(toState: Bool) {
        print("Enviando via Bluetooth: \(toState ? "ligado" : "desligado")")
    }
}

struct WifiStrategy: ConnectionStrategy {
    func sendSignal(toState: Bool) {
        print("Enviando via Wifi: \(toState ? "ligado" : "desligado")")
    }
}

// 4. Uso — a estratégia é escolhida na injeção, não com if/else dentro da Light
Light(method: BluetoothStrategy()).toggle()  // Enviando via Bluetooth: ligado
Light(method: WifiStrategy()).toggle()        // Enviando via Wifi: ligado

//: [Next](@next)
