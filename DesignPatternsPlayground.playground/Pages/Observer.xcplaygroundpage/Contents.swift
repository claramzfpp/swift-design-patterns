//: [Previous](@previous)

import Foundation

/*
 Observer — quando um objeto muda de estado, vários interessados são notificados
 automaticamente.
 Problema que resolve: a fonte do estado não precisa mais conhecer, um a um, quem
 depende dela. Os interessados se inscrevem e são avisados sem editar a fonte.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// O estado do device chama cada interessado NA MÃO, por nome. Adicionar um novo
// interessado (analytics, notificação push, etc.) obriga a EDITAR esta classe.
// (sufixo "Before" só para não colidir com a seção DEPOIS)

class UIScreenBefore {
    func render(isOn: Bool) { print("UI: lâmpada agora está \(isOn ? "ligada" : "desligada")") }
}

class EventLogBefore {
    func record(isOn: Bool) { print("Log: estado mudou para \(isOn)") }
}

class DeviceStateBefore {
    private var isOn = false

    // a fonte do estado carrega referências fixas para cada interessado
    private let ui = UIScreenBefore()
    private let log = EventLogBefore()

    func toggle() {
        isOn.toggle()
        // ao mudar, tem que lembrar de chamar CADA um, por nome, na ordem certa
        ui.render(isOn: isOn)
        log.record(isOn: isOn)
        // um novo interessado = mais uma linha aqui + acoplamento a mais uma classe
    }
}

// Uso — a fonte conhece todos os interessados diretamente
DeviceStateBefore().toggle()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Observer
// ========================================================

// 1. O contrato do observer — todo interessado só precisa saber reagir a um update.
protocol Observer: AnyObject {
    func didUpdate(isOn: Bool)
}

// 2. O Subject (fonte do estado) mantém uma lista de observers e notifica todos.
//    Ele NÃO conhece os tipos concretos — só a abstração Observer.
class DeviceState {
    private var isOn = false
    private var observers: [Observer] = []

    func subscribe(_ observer: Observer) {
        observers.append(observer)
    }

    func toggle() {
        isOn.toggle()
        notify()
    }

    private func notify() {
        // avisa todos os inscritos, sem saber quem são
        observers.forEach { $0.didUpdate(isOn: isOn) }
    }
}

// 3. Observers concretos — cada um se inscreve e reage do seu jeito.
//    Adicionar um novo interessado = criar outra classe, sem tocar em DeviceState.
class UIScreen: Observer {
    func didUpdate(isOn: Bool) { print("UI: lâmpada agora está \(isOn ? "ligada" : "desligada")") }
}

class EventLog: Observer {
    func didUpdate(isOn: Bool) { print("Log: estado mudou para \(isOn)") }
}

class Analytics: Observer {
    func didUpdate(isOn: Bool) { print("Analytics: evento toggle=\(isOn) registrado") }
}

// 4. Uso — os interessados se inscrevem; a fonte só dispara notify() ao mudar.
let device = DeviceState()
device.subscribe(UIScreen())
device.subscribe(EventLog())
device.subscribe(Analytics())  // novo interessado, DeviceState nem sabe que ele existe

device.toggle()
// UI: lâmpada agora está ligada
// Log: estado mudou para true
// Analytics: evento toggle=true registrado

//: [Next](@next)
