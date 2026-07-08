//: [Previous](@previous)

import Foundation

/*
 Encapsulamento (+ separação DTO / Modelo de domínio)
 Problema que resolve: evita que o formato cru da API vaze para o app inteiro e
 mantém as regras de negócio num único lugar controlado, em vez de espalhadas pela UI.
*/

// ========================================================
// ANTES — sem encapsulamento (o problema)
// ========================================================
// Aqui o app usa o DTO cru (o que vem da API) direto em todo lugar.
// Repare nos problemas que isso cria:

// O DTO da API é usado como se fosse o modelo do app.
// Os nomes dos campos são os nomes do JSON — o app fica "casado" com a API.
struct DeviceInfoBefore: Codable {
    // Propriedades mutáveis expostas sem nenhum controle:
    // qualquer parte do código pode escrever nelas à vontade.
    var deviceName: String
    var isAvailable: Bool
    var isOn: Bool
}

// A ViewModel consome o DTO cru diretamente.
class DeviceCardViewModelBefore {
    var device: DeviceInfoBefore?

    func fetch() {
        // A API devolve o DTO cru, sem tradução nenhuma.
        let deviceInfo = DeviceInfoBefore(
            deviceName: "Living Room Light",
            isAvailable: true,
            isOn: true
        )
        self.device = deviceInfo
    }

    // PROBLEMA 1: a regra de negócio ("desligar depois de X segundos")
    // mora dentro da view/viewmodel. Se outra tela precisar da mesma regra,
    // ela vai ser copiada e colada — e com o tempo cada cópia diverge.
    func turnOffAfter(_ delay: TimeInterval) {
        guard device?.isOn == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // mutando o DTO direto, sem qualquer proteção
            self.device?.isOn = false
        }
    }
}

class DeviceCardViewBefore {
    let viewModel = DeviceCardViewModelBefore()
    var name: String?

    func onAppear() {
        viewModel.fetch()
        // PROBLEMA 2: a view lê "deviceName", que é o nome do campo do JSON.
        // Se a API renomear "deviceName" para "name", ESTE arquivo quebra —
        // e todos os outros lugares que também leem o DTO cru.
        self.name = viewModel.device?.deviceName
        // PROBLEMA 3: "isAvailable" é um detalhe do JSON. A view precisa saber
        // que "disponível na API" significa "conectado na rede". Esse
        // conhecimento fica espalhado, repetido e sem nome de domínio.
        _ = viewModel.device?.isAvailable
    }
}

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com encapsulamento e mapeamento
// ========================================================

// 1. O DTO isola o formato da API. Ele existe só para "receber" o JSON.
//    Se o servidor mudar nomes de campos, o impacto fica preso AQUI.
struct DeviceInfo: Codable { //DTO
    var deviceName: String
    var isAvailable: Bool
    var isOn: Bool
    //var manufacturer: String
}

// 2. O Device é o modelo de domínio: fala a linguagem do app (não do JSON)
//    e ENCAPSULA a regra de negócio (turnOffAfter) num só lugar.
//    Propriedades que não devem mudar são `let`; só `isOn` é mutável.
class Device {
    let name: String
    let isConnectedToNetwork: Bool
    var isOn: Bool
    //let lastChangedState: Date?

    init(name: String, isConnectedToNetwork: Bool, isOn: Bool) {
        self.name = name
        self.isConnectedToNetwork = isConnectedToNetwork
        self.isOn = isOn
    }

    // A regra de negócio vive no domínio — qualquer tela reutiliza a MESMA regra.
    func turnOffAfter(_ delay: TimeInterval) {
        if isOn == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.isOn = false
            }
        }
    }
}

// 3. O mapeamento DTO -> Device acontece num único ponto.
//    É a "fronteira" entre o mundo da API e o mundo do app: o resto do
//    aplicativo nunca vê o DTO cru, só o Device já traduzido e protegido.
class API { //mapeamento
    static func fetchDevice() -> Device {
        let deviceInfo = DeviceInfo(
            deviceName: "Living Room Light",
            isAvailable: true,
            isOn: true
        )

        let device = Device(
            name: deviceInfo.deviceName,
            isConnectedToNetwork: deviceInfo.isAvailable,
            isOn: deviceInfo.isOn
        )

        return device
    }
}

// A ViewModel agora consome apenas o Device — desacoplada do formato da API.
class DeviceCardViewModel: ObservableObject {
    var device: Device?

    func fetch() {
        let deviceInfo: Device = API.fetchDevice()

        self.device = deviceInfo
    }

    func turnOffAfter(_ delay: TimeInterval) {
        // A view só pede; a regra continua encapsulada no Device.
        self.device?.turnOffAfter(delay)
    }
}

class DeviceCardView {
    let viewModel = DeviceCardViewModel()
    var name: String?

    func onAppear() {
        viewModel.fetch()
        // Lê "name" (linguagem do domínio). Se o JSON mudar, esta linha não muda.
        self.name = viewModel.device?.name
    }
}

class DeviceManager {
    var devices: [Device] = []

    func fetch() {
        let deviceInfo: Device = API.fetchDevice()
        if !deviceInfo.name.isEmpty {
            devices.append(deviceInfo)
        }
    }
}

//: [Next](@next)
