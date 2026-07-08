//: [Previous](@previous)

import SwiftUI

/*
 Flyweight — compartilha o estado comum (intrínseco) entre muitos objetos e mantém
 fora deles o estado que varia (extrínseco), para economizar memória.
 Problema que resolve: quando milhares de objetos duplicam os mesmos dados pesados
 (ícones, cores, categorias), a memória estoura. O Flyweight guarda UMA cópia
 compartilhada desses dados em vez de uma por objeto.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Cada ponto guarda sua PRÓPRIA cópia do ícone/cor/categoria, mesmo que sejam
// idênticos entre milhares de objetos do mesmo tipo → memória duplicada sem necessidade.
class PointOfInterestBefore {
    let name: String
    let latitude: Double
    let longitude: Double

    // esses três são IGUAIS para todos os restaurantes
    // mas cada objeto guarda sua própria cópia
    let icon: Image      // ~500KB por imagem
    let color: UIColor
    let category: String

    init(name: String, latitude: Double, longitude: Double, category: String) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.category = category

        // cada instância carrega sua própria cópia do ícone
        switch category {
        case "restaurante":
            self.icon = Image(systemName: "person.crop.circle") // 500KB
            self.color = .orange
        case "farmacia":
            self.icon = Image(systemName: "person.crop.circle")   // 500KB
            self.color = .green
        case "hospital":
            self.icon = Image(systemName: "person.crop.circle")   // 500KB
            self.color = .red
        default:
            self.icon = Image(systemName: "person.crop.circle")
            self.color = .gray
        }
    }

    func render() {
        print("Renderizando \(name) em (\(latitude), \(longitude)) com ícone \(category)")
    }
}

// Uso — criando pontos no mapa
var pointsBefore: [PointOfInterestBefore] = []

// 3000 restaurantes = 3000 cópias do mesmo ícone de 500KB na memória
// = ~1.5GB só para ícones de restaurante
for i in 0..<3000 {
    pointsBefore.append(PointOfInterestBefore(
        name: "Restaurante \(i)",
        latitude: -23.5 + Double(i) * 0.001,
        longitude: -46.6 + Double(i) * 0.001,
        category: "restaurante"
    ))
}

// 2000 farmácias = mais 1GB de ícones duplicados
for i in 0..<2000 {
    pointsBefore.append(PointOfInterestBefore(
        name: "Farmácia \(i)",
        latitude: -23.5 + Double(i) * 0.002,
        longitude: -46.6 + Double(i) * 0.002,
        category: "farmacia"
    ))
}

// print("Total de pontos: \(pointsBefore.count)") // 5000
// problema: 5000 cópias de ícones na memória

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Flyweight
// ========================================================

// 1. O Flyweight — guarda só o estado intrínseco (igual entre objetos do mesmo tipo)
class PointCategory {
    let category: String  // intrínseco
    let icon: UIImage     // intrínseco — carregado UMA VEZ, compartilhado por todos
    let color: UIColor    // intrínseco

    init(category: String, icon: UIImage, color: UIColor) {
        self.category = category
        self.icon = icon
        self.color = color
        print("Flyweight criado para categoria: \(category)")
    }
}

// 2. A Factory — garante que cada categoria existe só uma vez na memória
class PointCategoryFactory {
    private var cache: [String: PointCategory] = [:]

    func get(category: String) -> PointCategory {
        if let existing = cache[category] {
            return existing // reutiliza — não cria novo
        }

        let newCategory: PointCategory

        switch category {
        case "restaurante":
            newCategory = PointCategory(
                category: category,
                icon: UIImage(named: "icon_restaurante")!, // carregado só UMA VEZ
                color: .orange
            )
        case "farmacia":
            newCategory = PointCategory(
                category: category,
                icon: UIImage(named: "icon_farmacia")!,
                color: .green
            )
        case "hospital":
            newCategory = PointCategory(
                category: category,
                icon: UIImage(named: "icon_hospital")!,
                color: .red
            )
        default:
            newCategory = PointCategory(
                category: category,
                icon: UIImage(named: "icon_default")!,
                color: .gray
            )
        }

        cache[category] = newCategory
        return newCategory
    }

    var totalFlyweights: Int { cache.count }
}

// 3. O Contexto — guarda só o estado extrínseco (único para cada ponto)
struct PointOfInterest {
    let name: String           // extrínseco — único para cada ponto
    let latitude: Double       // extrínseco — único para cada ponto
    let longitude: Double      // extrínseco — único para cada ponto
    let category: PointCategory // referência compartilhada — não uma cópia

    func render() {
        print("Renderizando \(name) em (\(latitude), \(longitude)) | categoria: \(category.category)")
    }
}

// 4. Uso — o mesmo flyweight é reaproveitado para milhares de pontos
let factory = PointCategoryFactory()
var points: [PointOfInterest] = []

// 3000 restaurantes — mas só 1 flyweight "restaurante" na memória
for i in 0..<3000 {
    let category = factory.get(category: "restaurante") // reutiliza
    points.append(PointOfInterest(
        name: "Restaurante \(i)",
        latitude: -23.5 + Double(i) * 0.001,
        longitude: -46.6 + Double(i) * 0.001,
        category: category
    ))
}

// 2000 farmácias — mais 1 flyweight "farmacia" na memória
for i in 0..<2000 {
    let category = factory.get(category: "farmacia") // reutiliza
    points.append(PointOfInterest(
        name: "Farmácia \(i)",
        latitude: -23.5 + Double(i) * 0.002,
        longitude: -46.6 + Double(i) * 0.002,
        category: category
    ))
}

print("Total de pontos: \(points.count)")           // 5000
print("Total de flyweights na memória: \(factory.totalFlyweights)") // 2
// Flyweight criado para categoria: restaurante
// Flyweight criado para categoria: farmacia
// — ícones carregados só 2 vezes no total, não 5000

//: [Next](@next)
