//: [Previous](@previous)

import Foundation

/*
 Bridge — separa uma abstração (forma) da sua implementação (cor), para que
 as duas variem de forma independente.
 Problema que resolve: evita a explosão combinatória de subclasses quando você
 tem duas dimensões que variam (forma x cor).
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Sem a "ponte", cada combinação de forma + cor vira uma subclasse própria.
// Com 2 formas e 2 cores já são 4 classes. Adicionar UMA cor nova (ex: Blue)
// obriga a criar uma subclasse para CADA forma existente (BlueCircleBefore,
// BlueSquareBefore, ...). O número de classes cresce como formas x cores.

class RedCircleBefore {
    func draw() { print("Circle drawn in Red") }
}

class GreenCircleBefore {
    func draw() { print("Circle drawn in Green") }
}

class RedSquareBefore {
    func draw() { print("Square drawn in Red") }
}

class GreenSquareBefore {
    func draw() { print("Square drawn in Green") }
}

// Para adicionar a cor "Blue" eu precisaria criar TAMBÉM:
// class BlueCircleBefore { ... }
// class BlueSquareBefore { ... }
// ...e assim por diante para cada nova forma. A dor: N formas x M cores = N*M classes.

let redCircleBefore = RedCircleBefore()
redCircleBefore.draw()      // "Circle drawn in Red"

let greenSquareBefore = GreenSquareBefore()
greenSquareBefore.draw()    // "Square drawn in Green"

// ========================================================
// DEPOIS — com o Bridge
// ========================================================

// 1. O Implementador — a dimensão "cor", que varia sozinha.
//    Cada cor nova é só mais UMA classe, sem tocar nas formas.
public protocol Color {
    func getFill() -> String
}

public class Red: Color {
    public func getFill() -> String { "Red" }
}

public class Green: Color {
    public func getFill() -> String { "Green" }
}

// 2. A Abstração — a "ponte" mora aqui: Shape guarda uma REFERÊNCIA para Color.
//    A forma não sabe qual cor é; só delega para o implementador.
public class Shape {
    let color: Color // a ponte: referência para o implementador

    init(color: Color) {
        self.color = color
    }

    func draw() {
        fatalError("Subclasses must implement")
    }
}

// 3. Abstração Refinada — a dimensão "forma", que também varia sozinha.
//    Cada forma nova é só mais UMA classe, e funciona com QUALQUER cor.
public class Circle: Shape {
    override func draw() {
        print("Circle drawn in \(color.getFill())")
    }
}

public class Square: Shape {
    override func draw() {
        print("Square drawn in \(color.getFill())")
    }
}

// 4. Uso — combino forma e cor em tempo de execução, sem criar classes novas.
//    Adicionar "Blue" agora é UMA classe só, e ela combina com todas as formas.
let redCircle = Circle(color: Red())
redCircle.draw() // "Circle drawn in Red"

let greenSquare = Square(color: Green())
greenSquare.draw() // "Square drawn in Green"

//: [Next](@next)
