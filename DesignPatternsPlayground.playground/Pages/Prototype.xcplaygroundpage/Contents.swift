//: [Previous](@previous)

import Foundation

/*
 Prototype — cria novos objetos clonando um objeto já existente e configurado,
 em vez de construí-los do zero campo a campo.
 Problema que resolve: quando duplicar um objeto exige copiar manualmente cada
 propriedade, é fácil esquecer um campo e a lógica de cópia se repete pelo código
 inteiro. O Prototype centraliza essa cópia dentro do próprio objeto.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Para duplicar a configuração de um device, o cliente precisa copiar propriedade
// por propriedade na mão. Se um campo novo for adicionado (ex: firmwareVersion),
// é preciso lembrar de atualizar TODOS os lugares que fazem essa cópia — se esquecer
// um campo, o clone sai errado e o bug é silencioso.
class DeviceConfigBefore {
    var name: String
    var room: String
    var brightness: Int
    var isOn: Bool
    var firmwareVersion: String

    init(name: String, room: String, brightness: Int, isOn: Bool, firmwareVersion: String) {
        self.name = name
        self.room = room
        self.brightness = brightness
        self.isOn = isOn
        self.firmwareVersion = firmwareVersion
    }
}

// Uso — cópia manual, frágil e repetida em todo lugar
let originalBefore = DeviceConfigBefore(
    name: "Luz Padrão",
    room: "Sala",
    brightness: 80,
    isOn: true,
    firmwareVersion: "1.2.0"
)

// duplicando para o quarto: copiando campo a campo na mão...
let bedroomCopyBefore = DeviceConfigBefore(
    name: originalBefore.name,
    room: "Quarto",                 // só isso muda
    brightness: originalBefore.brightness,
    isOn: originalBefore.isOn,
    firmwareVersion: originalBefore.firmwareVersion
    // se um campo novo aparecer e eu esquecer de copiá-lo aqui, o clone sai errado
)

print("Antes -> \(bedroomCopyBefore.name) no \(bedroomCopyBefore.room)")

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Prototype
// ========================================================

// 1. O contrato do protótipo — todo objeto clonável sabe se copiar.
protocol Prototype {
    func clone() -> Self
}

// 2. O objeto concreto implementa clone() copiando o próprio estado.
//    A lógica de cópia vive em UM só lugar: dentro do objeto.
final class DeviceConfig: Prototype {
    var name: String
    var room: String
    var brightness: Int
    var isOn: Bool
    var firmwareVersion: String

    init(name: String, room: String, brightness: Int, isOn: Bool, firmwareVersion: String) {
        self.name = name
        self.room = room
        self.brightness = brightness
        self.isOn = isOn
        self.firmwareVersion = firmwareVersion
    }

    // 3. clone() devolve uma cópia INDEPENDENTE (mudar o clone não afeta o original).
    //    Campos novos entram só aqui — nenhum cliente precisa saber copiá-los.
    func clone() -> Self {
        return DeviceConfig(
            name: name,
            room: room,
            brightness: brightness,
            isOn: isOn,
            firmwareVersion: firmwareVersion
        ) as! Self
    }
}

// 4. Uso — clona o protótipo já configurado e ajusta só o que muda.
let original = DeviceConfig(
    name: "Luz Padrão",
    room: "Sala",
    brightness: 80,
    isOn: true,
    firmwareVersion: "1.2.0"
)

let bedroomCopy = original.clone()   // cópia completa, sem esquecer nenhum campo
bedroomCopy.room = "Quarto"          // ajusta apenas a diferença

print("Original -> \(original.name) no \(original.room), brilho \(original.brightness)")
print("Clone    -> \(bedroomCopy.name) no \(bedroomCopy.room), brilho \(bedroomCopy.brightness)")
// o original continua "Sala"; o clone virou "Quarto" — instâncias independentes

//: [Next](@next)
