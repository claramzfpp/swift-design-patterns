//: [Previous](@previous)

import Foundation

/*
 Proxy — um objeto intermediário controla o acesso a outro objeto real,
 expondo a mesma interface que ele.
 Problema que resolve: adiar a criação de um objeto caro até que ele seja
 realmente necessário (lazy) e/ou controlar o acesso (permissão) sem que
 o cliente precise saber se fala com o objeto real ou com o proxy.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// O cliente usa a câmera real diretamente. Conectar à câmera é caro e acontece
// já na criação do objeto, mesmo que o vídeo nunca seja assistido — desperdício.
// Além disso, não há nenhum controle de acesso antes de transmitir.

class RealCameraBefore {
    init() {
        // custo pago logo na criacao, sempre
        print("Conectando a camera... (operacao cara)")
    }

    func stream() {
        print("Transmitindo video da camera")
    }
}

// Uso — a conexao cara acontece aqui, mesmo que stream() nunca seja chamado
let cameraBefore = RealCameraBefore()   // ja pagou o custo da conexao
print("Camera criada, mas o video ainda nao foi assistido")
// se o usuario nunca assistir, a conexao foi desperdicada
cameraBefore.stream()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Proxy
// ========================================================

// 1. A abstração — o contrato que tanto o objeto real quanto o proxy cumprem.
//    O cliente depende só disto, sem saber quem está por trás.
protocol Camera {
    func stream()
}

// 2. O objeto real — é "caro": conecta já no init (com print).
class RealCamera: Camera {
    init() {
        print("Conectando a camera... (operacao cara)")
    }

    func stream() {
        print("Transmitindo video da camera")
    }
}

// 3. O proxy — conforma a mesma interface Camera, mas segura uma referência
//    opcional à RealCamera. Ela só é criada na PRIMEIRA chamada de stream()
//    (lazy). Antes disso, o proxy ainda pode checar permissão (controle de acesso).
class CameraProxy: Camera {
    private var realCamera: RealCamera?      // ainda nao existe
    private let hasPermission: Bool

    init(hasPermission: Bool) {
        self.hasPermission = hasPermission
        // repare: nenhuma conexao cara acontece aqui
    }

    func stream() {
        // controle de acesso antes de tocar no objeto real
        guard hasPermission else {
            print("Acesso negado: sem permissao para a camera")
            return
        }

        // lazy: cria a RealCamera apenas na primeira vez
        if realCamera == nil {
            print("Proxy: criando a camera real sob demanda")
            realCamera = RealCamera()
        }

        realCamera?.stream()
    }
}

// 4. Uso — o cliente usa apenas o tipo Camera, sem saber que é um proxy.
//    A RealCamera (e sua conexao cara) só nasce quando o stream é pedido.
let camera: Camera = CameraProxy(hasPermission: true)
print("Proxy criado, nenhuma conexao cara ainda")
camera.stream()   // aqui a RealCamera finalmente e criada e conecta
camera.stream()   // segunda chamada reaproveita a mesma RealCamera (sem reconectar)

// Sem permissao, o objeto real nunca chega a ser criado
let blocked: Camera = CameraProxy(hasPermission: false)
blocked.stream()  // acesso negado, nenhuma conexao cara

//: [Next](@next)
