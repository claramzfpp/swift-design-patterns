//: [Previous](@previous)

import Foundation

// Problema 1: estado interno completamente exposto
// Problema 2: quem salva precisa conhecer cada detalhe interno do personagem
// Problema 3: se o Personagem mudar internamente, o sistema de save quebra

class Personagem {
    var nome: String        // exposto
    var vida: Int           // exposto
    var mana: Int           // exposto
    var nivel: Int          // exposto
    var ouro: Int           // exposto
    var inventario: [String] // exposto
    var posicaoX: Double    // exposto
    var posicaoY: Double    // exposto
    
    init(nome: String) {
        self.nome = nome
        self.vida = 100
        self.mana = 50
        self.nivel = 1
        self.ouro = 0
        self.inventario = []
        self.posicaoX = 0
        self.posicaoY = 0
    }
}

// Sistema de save precisa conhecer TUDO do Personagem
class SistemaSave {
    struct SaveData {
        var nome: String
        var vida: Int
        var mana: Int
        var nivel: Int
        var ouro: Int
        var inventario: [String]
        var posicaoX: Double
        var posicaoY: Double
    }
    
    var slots: [Int: SaveData] = [:]
    
    func salvar(personagem: Personagem, slot: Int) {
        // acessa cada propriedade interna diretamente
        slots[slot] = SaveData(
            nome: personagem.nome,
            vida: personagem.vida,
            mana: personagem.mana,
            nivel: personagem.nivel,
            ouro: personagem.ouro,
            inventario: personagem.inventario,
            posicaoX: personagem.posicaoX,
            posicaoY: personagem.posicaoY
        )
        print("💾 Salvo no slot \(slot)")
    }
    
    func carregar(personagem: Personagem, slot: Int) {
        guard let save = slots[slot] else { return }
        // modifica cada propriedade interna diretamente
        personagem.nome = save.nome
        personagem.vida = save.vida
        personagem.mana = save.mana
        personagem.nivel = save.nivel
        personagem.ouro = save.ouro
        personagem.inventario = save.inventario
        personagem.posicaoX = save.posicaoX
        personagem.posicaoY = save.posicaoY
        print("📂 Carregado slot \(slot)")
    }
}

// Uso
let heroi = Personagem(nome: "Arthas")
let save = SistemaSave()

heroi.vida = 80
heroi.nivel = 5
heroi.ouro = 200
heroi.inventario = ["Espada", "Escudo"]
heroi.posicaoX = 150
heroi.posicaoY = 320

save.salvar(personagem: heroi, slot: 1)

// jogador morre e perde progresso
heroi.vida = 0
heroi.ouro = 0
heroi.inventario = []

// carrega o save
save.carregar(personagem: heroi, slot: 1)
// heroi.vida = 80, heroi.ouro = 200... mas o SistemaSave
// precisou conhecer TUDO para fazer isso

// Três problemas claros: Personagem com todas as propriedades públicas, SistemaSave acoplado a cada detalhe interno,
// e se você adicionar uma propriedade nova ao Personagem (ex: experiencia: Int), precisa abrir SistemaSave e atualizar em dois lugares.

//-----------------------------------------------

// 1. O Memento — snapshot opaco do estado do Personagem
// SistemaSave não sabe o que está dentro — só guarda e devolve
class PersonagemMemento {
    // fileprivate — só o Personagem (mesmo arquivo) acessa
    fileprivate let nome: String
    fileprivate let vida: Int
    fileprivate let mana: Int
    fileprivate let nivel: Int
    fileprivate let ouro: Int
    fileprivate let inventario: [String]
    fileprivate let posicaoX: Double
    fileprivate let posicaoY: Double
    fileprivate let timestamp: Date
    
    fileprivate init(
        nome: String, vida: Int, mana: Int, nivel: Int,
        ouro: Int, inventario: [String], posicaoX: Double, posicaoY: Double
    ) {
        self.nome = nome
        self.vida = vida
        self.mana = mana
        self.nivel = nivel
        self.ouro = ouro
        self.inventario = inventario
        self.posicaoX = posicaoX
        self.posicaoY = posicaoY
        self.timestamp = Date()
    }
}

// 2. O Originator — o Personagem cria e restaura seus próprios Mementos
class PersonagemV2 {
    private var nome: String      // privado — encapsulado
    private var vida: Int
    private var mana: Int
    private var nivel: Int
    private var ouro: Int
    private var inventario: [String]
    private var posicaoX: Double
    private var posicaoY: Double
    
    init(nome: String) {
        self.nome = nome
        self.vida = 100
        self.mana = 50
        self.nivel = 1
        self.ouro = 0
        self.inventario = []
        self.posicaoX = 0
        self.posicaoY = 0
    }
    
    func ganharExperiencia() {
        nivel += 1
        vida = 100
        mana = 100
        print("⬆️ Level up! Nível \(nivel)")
    }
    
    func coletarOuro(_ quantidade: Int) {
        ouro += quantidade
        print("💰 +\(quantidade) ouro (total: \(ouro))")
    }
    
    func adicionarItem(_ item: String) {
        inventario.append(item)
        print("🎒 Item adicionado: \(item)")
    }
    
    func mover(x: Double, y: Double) {
        posicaoX = x
        posicaoY = y
    }
    
    func sofrerDano(_ dano: Int) {
        vida = max(0, vida - dano)
        print("💔 Dano: \(dano) | Vida restante: \(vida)")
    }
    
    func exibirStatus() {
        print("""
        👤 \(nome) | Nível \(nivel)
        ❤️  Vida: \(vida) | 💧 Mana: \(mana)
        💰 Ouro: \(ouro)
        🎒 Inventário: \(inventario)
        📍 Posição: (\(posicaoX), \(posicaoY))
        """)
    }
    
    // Originator cria seu próprio Memento
    func salvarEstado() -> PersonagemMemento {
        return PersonagemMemento(
            nome: nome, vida: vida, mana: mana, nivel: nivel,
            ouro: ouro, inventario: inventario,
            posicaoX: posicaoX, posicaoY: posicaoY
        )
    }
    
    // Originator restaura a partir do Memento
    func restaurarEstado(_ memento: PersonagemMemento) {
        nome = memento.nome
        vida = memento.vida
        mana = memento.mana
        nivel = memento.nivel
        ouro = memento.ouro
        inventario = memento.inventario
        posicaoX = memento.posicaoX
        posicaoY = memento.posicaoY
        print("📂 Estado restaurado")
    }
}

// 3. O Caretaker — guarda Mementos sem saber o que está dentro
class SistemaSaveV2 {
    private var slots: [Int: PersonagemMemento] = [:]
    
    // não sabe o que está dentro do Memento — só guarda
    func salvar(memento: PersonagemMemento, slot: Int) {
        slots[slot] = memento
        print("💾 Salvo no slot \(slot) — \(memento.timestamp)")
    }
    
    func carregar(slot: Int) -> PersonagemMemento? {
        return slots[slot]
    }
    
    func listarSlots() {
        slots.forEach { slot, memento in
            print("Slot \(slot): salvo em \(memento.timestamp)")
        }
    }
}

// 4. Uso
let heroiV2 = PersonagemV2(nome: "Arthas")
let saveV2 = SistemaSaveV2()

// jogador avança no jogo
heroiV2.ganharExperiencia()
heroiV2.coletarOuro(200)
heroiV2.adicionarItem("Espada Lendária")
heroiV2.mover(x: 150, y: 320)

print("\n--- Status antes de salvar ---")
heroiV2.exibirStatus()

// salva o progresso — SistemaSave não precisa saber nada do Personagem
saveV2.salvar(memento: heroiV2.salvarEstado(), slot: 1)

// jogador continua e as coisas vão mal
heroiV2.sofrerDano(80)
heroiV2.sofrerDano(30) // vida = 0
heroiV2.adicionarItem("Item Inútil")

print("\n--- Status após tomar dano ---")
heroiV2.exibirStatus()

// carrega o save — só o Personagem sabe como restaurar o estado
if let memento = saveV2.carregar(slot: 1) {
    heroiV2.restaurarEstado(memento)
}

print("\n--- Status após carregar save ---")
heroiV2.exibirStatus()

// múltiplos slots de save
heroiV2.ganharExperiencia()
heroiV2.coletarOuro(500)
saveV2.salvar(memento: heroiV2.salvarEstado(), slot: 2)

print("\n--- Slots disponíveis ---")
saveV2.listarSlots()

// ir direto para o slot 1
if let memento = saveV2.carregar(slot: 1) {
    heroiV2.restaurarEstado(memento)
}
print("\n--- Voltou para o slot 1 ---")
heroiV2.exibirStatus()


//: [Next](@next)
