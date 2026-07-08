//: [Previous](@previous)

import Foundation

/*
 Mediator Pattern — centraliza a comunicação entre vários componentes num objeto
 mediador, em vez de eles se referenciarem diretamente.
 Problema que resolve: elimina o emaranhado de dependências onde cada componente
 guarda referência de vários outros. Adicionar ou trocar um componente deixa de
 exigir editar todos os demais.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Cada dispositivo da casa conhece diretamente os outros e chama-os na mão.
// O sensor de movimento guarda referência da luz E do alarme, e é ele quem
// coordena a reação. Quanto mais devices, mais referências cruzadas e mais
// pontos para editar — vira um emaranhado difícil de manter.
class LightBefore {
    func turnOn() { print("Luz: acendendo") }
}

class AlarmBefore {
    func trigger() { print("Alarme: disparando sirene") }
}

class MotionSensorBefore {
    // o sensor precisa conhecer e segurar cada device que ele controla
    private let light: LightBefore
    private let alarm: AlarmBefore

    init(light: LightBefore, alarm: AlarmBefore) {
        self.light = light
        self.alarm = alarm
    }

    func detectedMovement() {
        print("Sensor: movimento detectado")
        // o próprio sensor decide quem reage — acoplado a cada device
        light.turnOn()
        alarm.trigger()
        // ... um device novo aqui = mais uma referência e mais uma chamada
    }
}

// Uso — o sensor está amarrado à luz e ao alarme
let lightBefore = LightBefore()
let alarmBefore = AlarmBefore()
MotionSensorBefore(light: lightBefore, alarm: alarmBefore).detectedMovement()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Mediator Pattern
// ========================================================

// 1. O contrato do mediador — os devices só sabem "avisar" o mediador de um evento.
//    Eles NÃO conhecem uns aos outros.
protocol SmartHomeMediator: AnyObject {
    func notify(sender: Device, event: String)
}

// 2. A base de todo device — guarda apenas uma referência ao mediador.
class Device {
    let name: String
    weak var mediator: SmartHomeMediator?

    init(name: String) { self.name = name }
}

// 3. Devices concretos — cada um só fala com o hub via `notify`, sem tocar nos outros.
class MotionSensor: Device {
    func detectMovement() {
        print("Sensor: movimento detectado")
        mediator?.notify(sender: self, event: "movimentoDetectado")
    }
}

class Light: Device {
    func turnOn() { print("Luz: acendendo") }
}

class Alarm: Device {
    func trigger() { print("Alarme: disparando sirene") }
}

// 4. O mediador concreto (o hub) — é o ÚNICO que conhece todos os devices e
//    decide quem reage a cada evento. Adicionar um device novo = mexer só aqui.
class SmartHomeHub: SmartHomeMediator {
    private let light: Light
    private let alarm: Alarm

    init(light: Light, alarm: Alarm) {
        self.light = light
        self.alarm = alarm
    }

    func notify(sender: Device, event: String) {
        // toda a coordenação vive aqui dentro, não espalhada pelos devices
        if event == "movimentoDetectado" {
            print("Hub: reagindo ao movimento de \(sender.name)")
            light.turnOn()
            alarm.trigger()
        }
    }
}

// 5. Uso — os devices ficam desacoplados; só o hub orquestra
let light = Light(name: "Luz da sala")
let alarm = Alarm(name: "Alarme")
let sensor = MotionSensor(name: "Sensor de movimento")

let hub = SmartHomeHub(light: light, alarm: alarm)
sensor.mediator = hub  // o device só conhece o hub

sensor.detectMovement()
// Sensor: movimento detectado
// Hub: reagindo ao movimento de Sensor de movimento
// Luz: acendendo
// Alarme: disparando sirene

//: [Next](@next)
