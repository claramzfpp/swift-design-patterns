//: [Previous](@previous)

import Foundation

/*
 Abstract Factory — cria FAMÍLIAS de objetos relacionados (botão, campo,
 checkbox) sem que o cliente conheça as classes concretas.
 Problema que resolve: garante que os componentes usados juntos pertençam
 à MESMA família (tudo iOS ou tudo Android), evitando misturas incoerentes.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Sem uma fábrica, o cliente monta a UI escolhendo cada componente
// na mão, com if/else. Nada garante consistência entre eles.

protocol ButtonBefore { func render() }
protocol TextFieldBefore { func render() }
protocol CheckboxBefore { func render() }

class iOSButtonBefore: ButtonBefore { func render() { print("Rendering iOS-style button") } }
class iOSTextFieldBefore: TextFieldBefore { func render() { print("Rendering iOS-style text field") } }
class iOSCheckboxBefore: CheckboxBefore { func render() { print("Rendering iOS-style checkbox") } }

class AndroidButtonBefore: ButtonBefore { func render() { print("Rendering Android-style button") } }
class AndroidTextFieldBefore: TextFieldBefore { func render() { print("Rendering Android-style text field") } }
class AndroidCheckboxBefore: CheckboxBefore { func render() { print("Rendering Android-style checkbox") } }

// Dor: cada componente é decidido separadamente por um if.
// Se o programador errar UM ramo, a tela mistura famílias:
// botão iOS + checkbox Android. E a lógica se repete em cada tela.
class ApplicationBefore {
    private let button: ButtonBefore
    private let textField: TextFieldBefore
    private let checkbox: CheckboxBefore

    init(platform: String) {
        if platform == "iOS" {
            self.button = iOSButtonBefore()
            self.textField = iOSTextFieldBefore()
            self.checkbox = AndroidCheckboxBefore() // erro fácil: checkbox Android num app iOS
        } else {
            self.button = AndroidButtonBefore()
            self.textField = AndroidTextFieldBefore()
            self.checkbox = AndroidCheckboxBefore()
        }
    }

    func renderUI() {
        button.render()
        textField.render()
        checkbox.render()
    }
}

print("App antigo (iOS) — repare na mistura de famílias:")
ApplicationBefore(platform: "iOS").renderUI()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Abstract Factory
// ========================================================

// 1. Produtos Abstratos — as interfaces de cada tipo de componente.
//    O cliente sempre fala com essas abstrações, nunca com o concreto.
protocol Button {
    func render()
}

protocol TextField {
    func render()
}

protocol Checkbox {
    func render()
}

// 2. Produtos Concretos — família iOS.
class iOSButton: Button {
    func render() {
        print("Rendering iOS-style button")
    }
}

class iOSTextField: TextField {
    func render() {
        print("Rendering iOS-style text field")
    }
}

class iOSCheckbox: Checkbox {
    func render() {
        print("Rendering iOS-style checkbox")
    }
}

// 2. Produtos Concretos — família Android.
class AndroidButton: Button {
    func render() {
        print("Rendering Android-style button")
    }
}

class AndroidTextField: TextField {
    func render() {
        print("Rendering Android-style text field")
    }
}

class AndroidCheckbox: Checkbox {
    func render() {
        print("Rendering Android-style checkbox")
    }
}

// 3. A Abstract Factory — declara um método de criação para CADA produto
//    da família. Ela é o contrato que amarra os componentes entre si.
protocol UIFactory {
    func createButton() -> Button
    func createTextField() -> TextField
    func createCheckbox() -> Checkbox
}

// 4. Fábricas Concretas — cada uma produz UMA família inteira e coerente.
//    Aqui é impossível vazar um checkbox Android numa fábrica iOS.
class iOSFactory: UIFactory {
    func createButton() -> Button {
        return iOSButton()
    }

    func createTextField() -> TextField {
        return iOSTextField()
    }

    func createCheckbox() -> Checkbox {
        return iOSCheckbox()
    }
}

class AndroidFactory: UIFactory {
    func createButton() -> Button {
        return AndroidButton()
    }

    func createTextField() -> TextField {
        return AndroidTextField()
    }

    func createCheckbox() -> Checkbox {
        return AndroidCheckbox()
    }
}

// 5. Cliente — recebe UMA fábrica e cria tudo por ela. Não há if de
//    plataforma espalhado e a família fica garantidamente consistente.
class Application {
    private let button: Button
    private let textField: TextField
    private let checkbox: Checkbox

    init(factory: UIFactory) {
        self.button = factory.createButton()
        self.textField = factory.createTextField()
        self.checkbox = factory.createCheckbox()
    }

    func renderUI() {
        button.render()
        textField.render()
        checkbox.render()
    }
}

// 6. Uso — trocar a família inteira é só trocar a fábrica passada.
print("\nCreating iOS App:")
let iosApp = Application(factory: iOSFactory())
iosApp.renderUI()
// Output: Rendering iOS-style button
//         Rendering iOS-style text field
//         Rendering iOS-style checkbox

print("\nCreating Android App:")
let androidApp = Application(factory: AndroidFactory())
androidApp.renderUI()
// Output: Rendering Android-style button
//         Rendering Android-style text field
//         Rendering Android-style checkbox

//: [Next](@next)
