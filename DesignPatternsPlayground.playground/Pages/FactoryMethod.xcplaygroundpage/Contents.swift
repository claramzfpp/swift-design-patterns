//: [Previous](@previous)

import Foundation

/*
 Factory Method — define uma interface para criar objetos, mas deixa
 as subclasses (fábricas concretas) decidirem qual tipo instanciar.
 Problema que resolve: remove o acoplamento do cliente aos tipos
 concretos e centraliza a lógica de criação, evitando if/else espalhados.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// O cliente precisa conhecer TODOS os tipos concretos e decidir,
// na unha, qual instanciar através de uma cadeia de if/else.

protocol VehicleBefore {
    func drive()
    func getType() -> String
}

class CarBefore: VehicleBefore {
    func drive() { print("Driving a car on the road") }
    func getType() -> String { "Car" }
}

class TruckBefore: VehicleBefore {
    func drive() { print("Driving a truck, hauling cargo") }
    func getType() -> String { "Truck" }
}

class MotorcycleBefore: VehicleBefore {
    func drive() { print("Riding a motorcycle") }
    func getType() -> String { "Motorcycle" }
}

// Dor: o cliente decide o tipo com base numa String e fica acoplado
// a cada classe concreta. Toda vez que surge um veículo novo (ex: "bus"),
// é preciso ABRIR este método e adicionar mais um if — ele nunca fecha.
// Essa lógica de escolha ainda tende a se repetir em vários lugares do app.
func produceAndDriveBefore(type: String) {
    let vehicle: VehicleBefore

    if type == "car" {
        vehicle = CarBefore()
    } else if type == "truck" {
        vehicle = TruckBefore()
    } else if type == "motorcycle" {
        vehicle = MotorcycleBefore()
    } else {
        // e se ninguém tratar o "else"? cai num fatalError ou num default duvidoso
        fatalError("Tipo de veículo desconhecido: \(type)")
    }

    print("Produced: \(vehicle.getType())")
    vehicle.drive()
}

produceAndDriveBefore(type: "motorcycle")

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Factory Method
// ========================================================

// 1. O Produto — a interface comum que todos os veículos respeitam.
//    O cliente só conversa com esse protocolo, nunca com a classe concreta.
protocol Vehicle {
    func drive()
    func getType() -> String
}

// 2. Os Produtos Concretos — cada tipo implementa a interface do jeito dele.
class Car: Vehicle {
    func drive() {
        print("Driving a car on the road")
    }

    func getType() -> String {
        return "Car"
    }
}

class Truck: Vehicle {
    func drive() {
        print("Driving a truck, hauling cargo")
    }

    func getType() -> String {
        return "Truck"
    }
}

class Motorcycle: Vehicle {
    func drive() {
        print("Riding a motorcycle")
    }

    func getType() -> String {
        return "Motorcycle"
    }
}

// 3. O Criador (Factory) — declara o "factory method" createVehicle().
//    É ele que abstrai a criação: quem chama não sabe qual classe nasce.
protocol VehicleFactory {
    func createVehicle() -> Vehicle
}

// 4. As Fábricas Concretas — cada uma sabe criar UM tipo de veículo.
//    Adicionar um veículo novo = criar uma fábrica nova, sem tocar no
//    código existente (Aberto/Fechado). Não há mais cadeia de if/else.
class CarFactory: VehicleFactory {
    func createVehicle() -> Vehicle {
        return Car()
    }
}

class TruckFactory: VehicleFactory {
    func createVehicle() -> Vehicle {
        return Truck()
    }
}

class MotorcycleFactory: VehicleFactory {
    func createVehicle() -> Vehicle {
        return Motorcycle()
    }
}

// 5. Uso via polimorfismo — o cliente recebe uma fábrica qualquer e trabalha
//    só com as abstrações Vehicle/VehicleFactory. Zero acoplamento a tipos
//    concretos e nenhum if para escolher o que instanciar.
func produceAndDrive(factory: VehicleFactory) {
    let vehicle = factory.createVehicle()
    print("Produced: \(vehicle.getType())")
    vehicle.drive()
}

produceAndDrive(factory: MotorcycleFactory())

//: [Next](@next)
