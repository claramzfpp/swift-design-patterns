//: [Previous](@previous)

import Foundation

/*
 State Pattern — permite que um objeto mude seu comportamento quando seu estado interno muda.
 Problema que resolve: elimina os grandes if/else (ou switch) que checam o estado atual
 espalhados por vários métodos. Cada estado vira uma classe própria, e adicionar um novo
 estado deixa de exigir editar todos os métodos existentes.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// O estado é uma String e cada método precisa checar "em que estado estou?".
// A cada NOVO estado, TODOS os métodos crescem com mais um if/else.
// O comportamento fica espalhado e difícil de manter.
class OrderBefore {
    var state: String = "AGUARDANDO_PAGAMENTO"

    func pay() {
        // um if/else por estado — e isso se repete em cada método
        if state == "AGUARDANDO_PAGAMENTO" {
            state = "PAGO"
        } else if state == "CANCELADO" {
            print("Erro: Pedido cancelado não pode ser pago")
        } else if state == "PAGO" {
            print("Erro: Pedido já está pago")
        }
        // ... imagine isso crescendo para 10 estados
    }

    func cancel() {
        // o MESMO conjunto de estados precisa ser checado de novo aqui
        if state == "PAGO" {
            print("Estornando dinheiro...")
            state = "CANCELADO"
        } else if state == "DESPACHADO" {
            print("Erro: Não pode cancelar produto em trânsito")
        } else if state == "CANCELADO" {
            print("Erro: Já está cancelado")
        }
        // ... mais if/else aqui, repetindo a lista de estados
    }

    func dispatch() {
        // e mais um switch/if gigante aqui, com a mesma lista de estados de novo...
    }
    // Dor real: cada estado novo obriga a mexer em TODOS os métodos acima.
}

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o State Pattern
// ========================================================

// 1. O protocolo do Estado — define as ações possíveis. Cada estado concreto
//    decide como reagir a cada ação, sem precisar checar "quem sou eu".
protocol OrderState {
    func pay(order: Order)
    func cancel(order: Order)
}

// 2. O Contexto — delega o comportamento para o estado atual.
//    Repare que NÃO existe if/else de estado aqui dentro.
class Order {
    private var currentState: OrderState = AwaitingPayment()

    // troca o estado atual por outro (chamado pelos próprios estados)
    func changeState(to newState: OrderState) {
        self.currentState = newState
    }

    func tapPayButton() {
        currentState.pay(order: self)      // delega ao estado atual
    }

    func tapCancelButton() {
        currentState.cancel(order: self)   // delega ao estado atual
    }
}

// 3. Estados concretos — cada classe encapsula o comportamento de UM estado.
//    Adicionar um estado novo = criar uma nova classe, sem tocar nas outras.
class AwaitingPayment: OrderState {
    func pay(order: Order) {
        print("Pagamento aprovado!")
        order.changeState(to: Paid())       // transição de estado
    }

    func cancel(order: Order) {
        print("Pedido cancelado com sucesso.")
        order.changeState(to: Cancelled())
    }
}

class Cancelled: OrderState {
    func pay(order: Order) { print("Erro: Não há como pagar um pedido cancelado") }

    func cancel(order: Order) { print("Erro: Já está cancelado!") }
}

class Paid: OrderState {
    func pay(order: Order) { print("Erro: Já está pago!") }

    func cancel(order: Order) {
        print("Fazendo estorno e cancelando...")
        order.changeState(to: Cancelled())  // transição de estado
    }
}

// 4. Uso — o contexto sempre se comporta conforme o estado atual
let order = Order()
order.tapPayButton()      // "Pagamento aprovado!" — agora está Pago
order.tapPayButton()      // "Erro: Já está pago!"
order.tapCancelButton()   // "Fazendo estorno e cancelando..." — agora Cancelado

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// ALTERNATIVA COM ENUM — quando há poucos estados
// ========================================================
// Um enum "mimetiza" o State Pattern numa escala pequena: o comportamento por estado
// fica num switch. Funciona bem com poucos casos, mas com MUITOS estados o switch
// cresce e o State Pattern (uma classe por estado) fica mais organizado e escalável.
enum OrderStatus {
    case awaitingPayment, paid, cancelled
}

class OrderWithEnum {
    var state: OrderStatus = .awaitingPayment

    /// Aqui o switch faz o papel do "state pattern" só que numa escala menor.
    /// Se tivéssemos muitos casos dentro do enum, o ideal seria usar o State Pattern.
    func changeState(to new: OrderStatus) {
        state = new

        switch new {
        case .awaitingPayment:
            print("Estado atualizado: Aguardando Pagamento")
        case .paid:
            print("Estado atualizado: Pago")
        case .cancelled:
            print("Estado atualizado: Cancelado")
        }
    }

    func pay() {
        print("Pagamento aprovado!")
        state = .paid
    }

    func cancel() {
        print("Pedido cancelado")
        state = .cancelled
    }
}

//: [Next](@next)
