//: [Previous](@previous)

import Foundation

/*
 Chain of Responsibility — passa a requisição por uma corrente de handlers até alguém tratar.
 Problema que resolve: evita um bloco gigante de if/else que conhece TODOS os níveis de
 atendimento; cada handler decide sozinho se resolve ou repassa para o próximo.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Uma única função concentra TODA a regra de escalonamento.
// Ela precisa conhecer todos os níveis (atendente, especialista, gerente) e,
// a cada nova regra ou novo nível, essa função tem que ser editada de novo.

func handleTicketBefore(level: Int) {
    // um if/else gigante que sabe de tudo
    if level <= 3 {
        print("Atendente resolveu o ticket #\(level)")
    } else if level <= 7 {
        // se surgir um nível intermediário novo, tenho que mexer AQUI
        print("Especialista resolveu o ticket #\(level)")
    } else {
        // e AQUI de novo... a função vira uma bola de neve
        print("Gerente resolveu o ticket #\(level)")
    }
    // Problemas:
    // - toda regra nova = editar esta mesma função (viola Aberto/Fechado)
    // - a função conhece TODOS os níveis de uma vez (alto acoplamento)
    // - difícil reordenar ou remover um nível sem quebrar os outros
}

handleTicketBefore(level: 2) // "Atendente resolveu o ticket #2"
handleTicketBefore(level: 5) // "Especialista resolveu o ticket #5"
handleTicketBefore(level: 9) // "Gerente resolveu o ticket #9"

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Chain of Responsibility
// ========================================================

// 1. O protocolo base — cada handler implementa isso
protocol Handler: AnyObject {
    var next: Handler? { get set }
    func setNext(_ handler: Handler) -> Handler
    func handle(request: Int)
}

// 2. Classe base com a lógica de encadeamento (repassa para o próximo por padrão)
class HandlerBase: Handler {
    var next: Handler?

    func setNext(_ handler: Handler) -> Handler {
        next = handler
        return handler // permite encadeamento fluente
    }

    func handle(request: Int) {
        next?.handle(request: request)
    }
}

// 3. Handlers concretos — cada um só conhece a SUA regra e o próximo da corrente
class Attendant: HandlerBase {
    override func handle(request: Int) {
        if request <= 3 {
            print("Atendente resolveu o ticket #\(request)")
        } else {
            print("Atendente escalando ticket #\(request)...")
            super.handle(request: request) // repassa adiante
        }
    }
}

class Specialist: HandlerBase {
    override func handle(request: Int) {
        if request <= 7 {
            print("Especialista resolveu o ticket #\(request)")
        } else {
            print("Especialista escalando ticket #\(request)...")
            super.handle(request: request) // repassa adiante
        }
    }
}

class Manager: HandlerBase {
    override func handle(request: Int) {
        print("Gerente resolveu o ticket #\(request)")
        // fim da corrente — gerente resolve tudo
    }
}

// 4. Montando a corrente (basta reordenar/adicionar handlers para mudar as regras)
let attendant = Attendant()
let specialist = Specialist()
let manager = Manager()

attendant
    .setNext(specialist)
    .setNext(manager) // encadeamento fluente

// 5. Uso — o cliente só conhece o PRIMEIRO da corrente
attendant.handle(request: 2)
// "Atendente resolveu o ticket #2"

attendant.handle(request: 5)
// "Atendente escalando ticket #5..."
// "Especialista resolveu o ticket #5"

attendant.handle(request: 9)
// "Atendente escalando ticket #9..."
// "Especialista escalando ticket #9..."
// "Gerente resolveu o ticket #9"

//: [Next](@next)
