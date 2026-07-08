//: [Previous](@previous)

import SwiftUI

/*
 Builder — separa a construção de um objeto complexo da sua representação,
 montando-o passo a passo com uma interface fluente.
 Problema que resolve: elimina o "telescoping initializer" (init gigante
 com muitos parâmetros opcionais), tornando a criação legível e sem
 precisar passar nil/valores default para tudo que não interessa.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Com um init único, todo parâmetro opcional vira posição na chamada.
// O chamador precisa lembrar a ORDEM e preencher tudo, mesmo o que não usa.

struct ProductCardBefore {
    let title: String
    let price: Double
    let imageURL: String?
    let discount: String?
    let showRating: Bool
    let isFavorite: Bool
    let badge: String?

    // Dor: telescoping initializer — muitos parâmetros, vários opcionais.
    init(title: String,
         price: Double,
         imageURL: String?,
         discount: String?,
         showRating: Bool,
         isFavorite: Bool,
         badge: String?) {
        self.title = title
        self.price = price
        self.imageURL = imageURL
        self.discount = discount
        self.showRating = showRating
        self.isFavorite = isFavorite
        self.badge = badge
    }
}

// Na chamada fica ilegível: uma parede de nil e true/false soltos.
// Qual bool é showRating? Qual é isFavorite? É fácil trocar a ordem
// e não perceber, porque ambos são Bool e o compilador não reclama.
let cardBefore = ProductCardBefore(
    title: "Noise-Cancelling Headphones",
    price: 299.99,
    imageURL: nil,
    discount: "20% OFF",
    showRating: true,
    isFavorite: false,
    badge: nil
)

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Builder
// ========================================================

// 1. O Produto — imutável (só lets). Ninguém o monta direto com um init
//    enorme; a responsabilidade de montá-lo fica no builder.
struct ProductCard {
    let title: String
    let price: Double
    let imageURL: String?
    let discount: String?
    let showRating: Bool
}

// 2. O Builder — guarda o estado parcial em propriedades privadas com
//    valores default. Só se configura o que interessa.
class ProductCardBuilder {
    private var title: String = ""
    private var price: Double = 0.0
    private var imageURL: String?
    private var discount: String?
    private var showRating: Bool = false

    // 3. Cada método configura UM campo e retorna self (-> ProductCardBuilder),
    //    o que permite encadear as chamadas de forma fluente e legível.
    func setTitle(_ title: String) -> ProductCardBuilder {
        self.title = title
        return self
    }

    func setPrice(_ price: Double) -> ProductCardBuilder {
        self.price = price
        return self
    }

    func withImage(_ imageURL: String) -> ProductCardBuilder {
        self.imageURL = imageURL
        return self
    }

    func withDiscount(_ discount: String) -> ProductCardBuilder {
        self.discount = discount
        return self
    }

    func includeRating() -> ProductCardBuilder {
        self.showRating = true
        return self
    }

    // 4. build() encerra a construção e entrega o objeto final imutável.
    func build() -> ProductCard {
        return ProductCard(title: title, price: price, imageURL: imageURL, discount: discount, showRating: showRating)
    }
}

struct ProductCardView: View {
    let product: ProductCard

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.title).font(.headline)
            Text("$\(product.price, specifier: "%.2f")").foregroundColor(.secondary)

            if let discount = product.discount {
                Text(discount).font(.caption).padding(4).background(Color.red).cornerRadius(4)
            }

            if product.showRating {
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray))
    }
}

struct StorefrontView: View {
    // 5. Uso — construção passo a passo, só com o que importa.
    //    Cada .set/.with diz claramente qual campo está sendo definido:
    //    nada de nil soltos nem de adivinhar a ordem dos parâmetros.
    let featuredProduct = ProductCardBuilder()
        .setTitle("Noise-Cancelling Headphones")
        .setPrice(299.99)
        .withDiscount("20% OFF")
        .includeRating()
        .build()

    var body: some View {
        ProductCardView(product: featuredProduct)
    }
}


//: [Next](@next)
