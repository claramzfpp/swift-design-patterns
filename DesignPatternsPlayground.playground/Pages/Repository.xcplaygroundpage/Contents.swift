//: [Previous](@previous)

import Foundation

/*
 Repository — abstrai a ORIGEM dos dados atrás de uma interface.
 Problema que resolve: quem consome os dados (View/ViewModel) não precisa
 saber se eles vêm da rede, de cache ou de um banco local — e trocar/combinar
 essas fontes não obriga a mexer em quem consome.
*/

struct Device {
    let name: String
    let id: Int
}

class Service {
    func getDeviceList() -> [Device] {
        return [Device(name: "Light 1", id: 1), Device(name: "Light 2", id: 2)]
    }
}

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// A ViewModel fala DIRETO com o Service de rede.
// (sufixo "Before" só para não colidir com a seção DEPOIS)

class DeviceListViewModelBefore {
    // acoplamento direto à implementação concreta de rede
    let service = Service()

    func loadDevices() -> [Device] {
        // Dor real:
        //  - sem abstração: a View conhece a classe concreta Service;
        //  - sem cache: toda vez bate na rede, mesmo que os dados não mudem;
        //  - para adicionar cache ou trocar a fonte (banco local, arquivo, mock
        //    de teste), você é obrigado a editar ESTA classe — que deveria só
        //    cuidar da tela.
        return service.getDeviceList()
    }
}

let viewModelBefore = DeviceListViewModelBefore()
print(viewModelBefore.loadDevices())

// ========================================================
// DEPOIS — com o Repository
// ========================================================

// 1. O contrato — a View/ViewModel vai depender DISTO, não de classes concretas.
protocol DeviceRepositoryProtocol {
    func getAllDevices() throws -> [Device]
}

// 2. Implementação que busca na rede — uma das fontes possíveis.
class DeviceRepository: DeviceRepositoryProtocol {
    let service: Service = Service()

    func getAllDevices() throws -> [Device] {
        return service.getDeviceList()
    }
}

// 3. Implementação de cache — outra fonte, com a MESMA interface.
class DeviceRepositoryCache: DeviceRepositoryProtocol {
    var offlineDevices: [Device] = []

    func getAllDevices() throws -> [Device] {
        return offlineDevices
    }

    func saveDevices(_ devices: [Device]) {
        self.offlineDevices = devices
    }
}

// 4. Composição cache-first — tenta o cache primeiro e cai na rede só se precisar.
//    Repare que ele mesmo é um DeviceRepositoryProtocol: quem usa nem percebe
//    que existe cache por baixo.
class CacheFirstDeviceRepository: DeviceRepositoryProtocol {
    let deviceRepository: DeviceRepositoryProtocol
    let cache: DeviceRepositoryCache

    init(deviceRepository: DeviceRepositoryProtocol, cache: DeviceRepositoryCache) {
        self.deviceRepository = deviceRepository
        self.cache = cache
    }

    func getAllDevices() throws -> [Device] {
        do {
            return try cache.getAllDevices()
        } catch {
            let devices = try deviceRepository.getAllDevices()
            cache.saveDevices(devices)

            return devices
        }
    }
}

// 5. Uso — a ViewModel enxerga só o protocolo. Trocar a estratégia de dados
//    (rede pura, cache, mock de teste) é trocar UMA linha aqui, sem tocar na tela.
let cacheFirstDeviceRepository = CacheFirstDeviceRepository(deviceRepository: DeviceRepository(), cache: DeviceRepositoryCache())
let deviceRepository: DeviceRepositoryProtocol = cacheFirstDeviceRepository
let devices = try deviceRepository.getAllDevices()
print(devices)
//: [Next](@next)
