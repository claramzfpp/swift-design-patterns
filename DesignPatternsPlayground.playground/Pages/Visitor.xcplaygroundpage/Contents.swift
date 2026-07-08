//: [Previous](@previous)

import Foundation

/*
 Visitor Pattern — adiciona novas operações a uma hierarquia de tipos SEM modificar
 esses tipos, colocando a operação num objeto "visitante".
 Problema que resolve: elimina os type-checks (`as?` / switch de tipo) espalhados pelo
 cliente. Cada nova operação deixa de repetir a verificação de tipo de cada device.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Para calcular o consumo de energia por tipo de device, o cliente precisa
// descobrir o tipo concreto na mão, com um encadeamento de `as?`.
// Cada NOVA operação (ex: relatório de status) repete exatamente esse mesmo
// type-check, e um device novo obriga a mexer em todos esses pontos.
protocol DeviceBefore {}

class LightBefore: DeviceBefore {
    let watts: Double = 10
}

class ThermostatBefore: DeviceBefore {
    let watts: Double = 50
}

class CameraBefore: DeviceBefore {
    let watts: Double = 5
}

func energyReportBefore(devices: [DeviceBefore]) {
    for device in devices {
        // type-check frágil e espalhado — repetido em toda operação nova
        if let light = device as? LightBefore {
            print("Luz consome \(light.watts)W")
        } else if let thermostat = device as? ThermostatBefore {
            print("Termostato consome \(thermostat.watts)W")
        } else if let camera = device as? CameraBefore {
            print("Câmera consome \(camera.watts)W")
        }
        // ... device novo = mais um "else if" aqui e em cada outra função
    }
}

// Uso
energyReportBefore(devices: [LightBefore(), ThermostatBefore(), CameraBefore()])

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Visitor Pattern
// ========================================================

// 1. O contrato do visitante — declara um `visit` para cada tipo concreto.
//    Uma operação nova = uma nova implementação deste protocolo, sem tocar nos devices.
protocol DeviceVisitor {
    func visit(light: Light)
    func visit(thermostat: Thermostat)
    func visit(camera: Camera)
}

// 2. O contrato do elemento — todo device sabe "aceitar" um visitante.
//    É o device que chama o `visit` certo, resolvendo o tipo sem `as?` no cliente.
protocol Device {
    func accept(_ visitor: DeviceVisitor)
}

// 3. Devices concretos — cada um repassa a si mesmo ao método correto do visitante.
class Light: Device {
    let watts: Double = 10
    func accept(_ visitor: DeviceVisitor) { visitor.visit(light: self) }
}

class Thermostat: Device {
    let watts: Double = 50
    func accept(_ visitor: DeviceVisitor) { visitor.visit(thermostat: self) }
}

class Camera: Device {
    let watts: Double = 5
    func accept(_ visitor: DeviceVisitor) { visitor.visit(camera: self) }
}

// 4. Um visitante concreto — a operação "relatório de energia" isolada aqui.
//    Toda a lógica por tipo vive num só lugar, sem espalhar type-checks.
class EnergyReportVisitor: DeviceVisitor {
    private(set) var totalWatts: Double = 0

    func visit(light: Light) {
        print("Luz consome \(light.watts)W")
        totalWatts += light.watts
    }

    func visit(thermostat: Thermostat) {
        print("Termostato consome \(thermostat.watts)W")
        totalWatts += thermostat.watts
    }

    func visit(camera: Camera) {
        print("Câmera consome \(camera.watts)W")
        totalWatts += camera.watts
    }
}

// 5. Uso — o cliente só chama `accept`; o device escolhe o `visit` certo
let devices: [Device] = [Light(), Thermostat(), Camera()]
let report = EnergyReportVisitor()

for device in devices {
    device.accept(report)
}
print("Consumo total: \(report.totalWatts)W")
// Luz consome 10.0W
// Termostato consome 50.0W
// Câmera consome 5.0W
// Consumo total: 65.0W

//: [Next](@next)
