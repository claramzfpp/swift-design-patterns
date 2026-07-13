//: [Previous](@previous)

import Foundation

/*
 Memento Pattern — captura e externaliza o estado interno de um objeto sem violar seu encapsulamento.
 Problema que resolve: permite salvar e restaurar o estado de um objeto (undo, save/load)
 sem expor suas propriedades internas nem acoplar quem guarda o estado aos detalhes do objeto.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Problema 1: estado interno completamente exposto.
// Problema 2: quem salva precisa conhecer cada detalhe interno do personagem.
// Problema 3: se o Character mudar internamente, o sistema de save quebra.

class CharacterBefore {
    var name: String        // exposto
    var health: Int         // exposto
    var mana: Int           // exposto
    var level: Int          // exposto
    var gold: Int           // exposto
    var inventory: [String] // exposto
    var positionX: Double   // exposto
    var positionY: Double   // exposto

    init(name: String) {
        self.name = name
        self.health = 100
        self.mana = 50
        self.level = 1
        self.gold = 0
        self.inventory = []
        self.positionX = 0
        self.positionY = 0
    }
}

// Sistema de save precisa conhecer TUDO do Character
class SaveSystemBefore {
    struct SaveData {
        var name: String
        var health: Int
        var mana: Int
        var level: Int
        var gold: Int
        var inventory: [String]
        var positionX: Double
        var positionY: Double
    }

    var slots: [Int: SaveData] = [:]

    func save(character: CharacterBefore, slot: Int) {
        // acessa cada propriedade interna diretamente
        slots[slot] = SaveData(
            name: character.name,
            health: character.health,
            mana: character.mana,
            level: character.level,
            gold: character.gold,
            inventory: character.inventory,
            positionX: character.positionX,
            positionY: character.positionY
        )
        print("Salvo no slot \(slot)")
    }

    func load(character: CharacterBefore, slot: Int) {
        guard let saveData = slots[slot] else { return }
        // modifica cada propriedade interna diretamente
        character.name = saveData.name
        character.health = saveData.health
        character.mana = saveData.mana
        character.level = saveData.level
        character.gold = saveData.gold
        character.inventory = saveData.inventory
        character.positionX = saveData.positionX
        character.positionY = saveData.positionY
        print("Carregado slot \(slot)")
    }
}

// Uso
let hero = CharacterBefore(name: "Arthas")
let saveSystem = SaveSystemBefore()

hero.health = 80
hero.level = 5
hero.gold = 200
hero.inventory = ["Espada", "Escudo"]
hero.positionX = 150
hero.positionY = 320

saveSystem.save(character: hero, slot: 1)

// jogador morre e perde progresso
hero.health = 0
hero.gold = 0
hero.inventory = []

// carrega o save
saveSystem.load(character: hero, slot: 1)
// hero.health = 80, hero.gold = 200... mas o SaveSystem
// precisou conhecer TUDO para fazer isso

// Três problemas claros: Character com todas as propriedades públicas, SaveSystem acoplado a cada detalhe interno,
// e se você adicionar uma propriedade nova ao Character (ex: experience: Int), precisa abrir SaveSystem e atualizar em dois lugares.

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Memento Pattern
// ========================================================

// 1. O Memento — snapshot opaco do estado do Character.
//    O SaveSystem não sabe o que está dentro — só guarda e devolve.
class CharacterMemento {
    // fileprivate — só o Character (mesmo arquivo) acessa
    fileprivate let name: String
    fileprivate let health: Int
    fileprivate let mana: Int
    fileprivate let level: Int
    fileprivate let gold: Int
    fileprivate let inventory: [String]
    fileprivate let positionX: Double
    fileprivate let positionY: Double
    fileprivate let timestamp: Date

    fileprivate init(
        name: String, health: Int, mana: Int, level: Int,
        gold: Int, inventory: [String], positionX: Double, positionY: Double
    ) {
        self.name = name
        self.health = health
        self.mana = mana
        self.level = level
        self.gold = gold
        self.inventory = inventory
        self.positionX = positionX
        self.positionY = positionY
        self.timestamp = Date()
    }
}

// 2. O Originator — o Character cria e restaura seus próprios Mementos.
class Character {
    private var name: String      // privado — encapsulado
    private var health: Int
    private var mana: Int
    private var level: Int
    private var gold: Int
    private var inventory: [String]
    private var positionX: Double
    private var positionY: Double

    init(name: String) {
        self.name = name
        self.health = 100
        self.mana = 50
        self.level = 1
        self.gold = 0
        self.inventory = []
        self.positionX = 0
        self.positionY = 0
    }

    func gainExperience() {
        level += 1
        health = 100
        mana = 100
        print("Level up! Nível \(level)")
    }

    func collectGold(_ amount: Int) {
        gold += amount
        print("+\(amount) ouro (total: \(gold))")
    }

    func addItem(_ item: String) {
        inventory.append(item)
        print("Item adicionado: \(item)")
    }

    func move(x: Double, y: Double) {
        positionX = x
        positionY = y
    }

    func takeDamage(_ damage: Int) {
        health = max(0, health - damage)
        print("Dano: \(damage) | Vida restante: \(health)")
    }

    func showStatus() {
        print("""
        \(name) | Nível \(level)
        Vida: \(health) | Mana: \(mana)
        Ouro: \(gold)
        Inventário: \(inventory)
        Posição: (\(positionX), \(positionY))
        """)
    }

    // Originator cria seu próprio Memento
    func saveState() -> CharacterMemento {
        return CharacterMemento(
            name: name, health: health, mana: mana, level: level,
            gold: gold, inventory: inventory,
            positionX: positionX, positionY: positionY
        )
    }

    // Originator restaura a partir do Memento
    func restoreState(_ memento: CharacterMemento) {
        name = memento.name
        health = memento.health
        mana = memento.mana
        level = memento.level
        gold = memento.gold
        inventory = memento.inventory
        positionX = memento.positionX
        positionY = memento.positionY
        print("Estado restaurado")
    }
}

// 3. O Caretaker — guarda Mementos sem saber o que está dentro.
class SaveSystem {
    private var slots: [Int: CharacterMemento] = [:]

    // não sabe o que está dentro do Memento — só guarda
    func save(memento: CharacterMemento, slot: Int) {
        slots[slot] = memento
        print("Salvo no slot \(slot) — \(memento.timestamp)")
    }

    func load(slot: Int) -> CharacterMemento? {
        return slots[slot]
    }

    func listSlots() {
        slots.forEach { slot, memento in
            print("Slot \(slot): salvo em \(memento.timestamp)")
        }
    }
}

// 4. Uso
let heroV2 = Character(name: "Arthas")
let saveSystemV2 = SaveSystem()

// jogador avança no jogo
heroV2.gainExperience()
heroV2.collectGold(200)
heroV2.addItem("Espada Lendária")
heroV2.move(x: 150, y: 320)

print("\n--- Status antes de salvar ---")
heroV2.showStatus()

// salva o progresso — SaveSystem não precisa saber nada do Character
saveSystemV2.save(memento: heroV2.saveState(), slot: 1)

// jogador continua e as coisas vão mal
heroV2.takeDamage(80)
heroV2.takeDamage(30) // vida = 0
heroV2.addItem("Item Inútil")

print("\n--- Status após tomar dano ---")
heroV2.showStatus()

// carrega o save — só o Character sabe como restaurar o estado
if let memento = saveSystemV2.load(slot: 1) {
    heroV2.restoreState(memento)
}

print("\n--- Status após carregar save ---")
heroV2.showStatus()

// múltiplos slots de save
heroV2.gainExperience()
heroV2.collectGold(500)
saveSystemV2.save(memento: heroV2.saveState(), slot: 2)

print("\n--- Slots disponíveis ---")
saveSystemV2.listSlots()

// ir direto para o slot 1
if let memento = saveSystemV2.load(slot: 1) {
    heroV2.restoreState(memento)
}
print("\n--- Voltou para o slot 1 ---")
heroV2.showStatus()

//: [Next](@next)
