//: [Previous](@previous)

import Foundation

/*
 Decorator — adiciona comportamento a um objeto embrulhando-o em outro que tem a
 mesma interface, empilhando responsabilidades em tempo de execução.
 Problema que resolve: em vez de uma função gigante cheia de if/else para cada
 caso, cada comportamento vira uma peça independente que você combina como quiser.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Uma única função concentra toda a lógica de montar a URL com if/else.
// A dor: cada parâmetro novo (source, user, token, locale...) é mais um
// parâmetro na assinatura e mais um if aqui dentro. A função incha e fica rígida;
// e a ORDEM de concatenação fica fixa, difícil de reaproveitar.
func buildURLBefore(base: String, source: String?, user: String?) -> String {
    var result = base

    if let source = source {
        result += "?source=\(source)"
    }

    if let user = user {
        result += "?user=\(user)"
    }

    // adicionou "token"? mais um parâmetro + mais um if aqui.
    // adicionou "locale"? idem. A função cresce sem parar.
    return result
}

let oldURL = buildURLBefore(base: "https://example.com", source: "AppStore", user: "Clara")
print(oldURL)

// ========================================================
// DEPOIS — com o Decorator
// ========================================================

// 1. A interface comum — tanto a URL "crua" quanto cada decorator a implementam.
protocol URLProtocol {
    func url() -> String
}

// 2. Os decorators — cada um EMBRULHA um URLProtocol e acrescenta um pedaço.
//    Cada comportamento novo é uma struct nova, sem tocar nas outras.
struct URLSourceDecorator: URLProtocol { //temos controle
    let wrapped: URLProtocol

    func url() -> String {
        return wrapped.url() + "?source=AppStore"
    }
}

struct URLUserDecorator: URLProtocol { //temos controle
    let wrapped: URLProtocol

    func url() -> String {
        return wrapped.url() + "?user=Clara"
    }
}

// 3. O componente concreto — a URL base, o "miolo" que será embrulhado.
//    (Obs: a struct chama-se URL de propósito e sombreia Foundation.URL aqui.)
struct URL: URLProtocol {
    let urlString: String

    func url() -> String {
        return urlString
    }
}

// 4. Uso — empilho os comportamentos em tempo de execução.
//    Quero um parâmetro novo? Só embrulhar em mais um decorator, na ordem que eu quiser.
struct ContentView {
    func onAppear() {
        var base: URLProtocol = URL(urlString: "https://example.com")

        base = URLUserDecorator(wrapped: base)   // embrulha: acrescenta ?user
        base = URLSourceDecorator(wrapped: base) // embrulha de novo: acrescenta ?source

        print(base.url())
    }
}

let view = ContentView()
view.onAppear()


//: [Next](@next)
