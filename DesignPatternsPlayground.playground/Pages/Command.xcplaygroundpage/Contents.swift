//: [Previous](@previous)

import Foundation

/*
 Command — encapsula uma ação em um objeto, para que o invocador não precise
 conhecer o que a ação faz de verdade.
 Problema que resolve: a view (invocador) fica acoplada a cada ação concreta;
 adicionar um novo tipo de device obriga a editar o botão da view.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Aqui a MainView decide, dentro do próprio botão, O QUE fazer para cada tipo de
// device usando um if/else. A view conhece luz, tomada e todo device que existir.

enum DeviceTypeBefore {
    case light
    case plug
}

final class MainViewBefore {
    var deviceType: DeviceTypeBefore
    var isLightOn = false
    var isPlugOn = false

    init(deviceType: DeviceTypeBefore) {
        self.deviceType = deviceType
    }

    func buttonAction() {
        // o botão precisa saber o tipo de cada device e a regra de cada um
        if deviceType == .light {
            isLightOn.toggle()
            print(isLightOn ? "A luz está ligada" : "A luz está desligada")
        } else if deviceType == .plug {
            isPlugOn.toggle()
            print(isPlugOn ? "A tomada está ligada" : "A tomada está desligada")
        }
        // Problemas:
        // - a view (invocador) está acoplada a cada ação concreta
        // - adicionar um device novo = editar este if/else de novo
        // - impossível "injetar" um comando diferente sem tocar na view
    }
}

let lightBefore = MainViewBefore(deviceType: .light)
lightBefore.buttonAction() // "A luz está ligada"

let plugBefore = MainViewBefore(deviceType: .plug)
plugBefore.buttonAction() // "A tomada está ligada"

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Command
// ========================================================

// 1. O protocolo Command — todo comando concreto respeita esta interface
protocol Action {
    func changeCurrentState()
    func makeRefreshCall()
}

// 2. Comando concreto — a luz sabe SÓ da sua própria regra
final class ChangeLightAction: Action {
    var light: Bool

    init(light: Bool) {
        self.light = light
    }

    func changeCurrentState() {
        if light {
            light = false
            print("A luz está desligada")
        } else {
            light = true
            print("A luz está ligada")
        }
    }

    func makeRefreshCall() {
        print("Execute refresh")
    }
}

// 3. Outro comando concreto — a tomada também respeita o mesmo protocolo
final class ChangePlugAction: Action {
    var doorlock: Bool

    init(doorlock: Bool) {
        self.doorlock = doorlock
    }

    func changeCurrentState() {
        if doorlock {
            doorlock = false
            print("A porta está aberta")
        } else {
            doorlock = true
            print("A porta está fechada")
        }
    }

    func makeRefreshCall() {
        print("Execute refresh")
    }
}

// 4. O Invoker — a view só chama a ação, sem saber o que ela faz por dentro
final class MainView { // Invoker - chama a ação que precisa ser executada
    var action: Action

    init(action: Action) {
        self.action = action
    }

    func buttonAction() {
        action.changeCurrentState()
    }

    func refresh() {
        action.makeRefreshCall()
    }
}

// 5. Uso — podemos injetar QUALQUER comando no invocador,
//    desde que ele respeite o protocolo Action
let lightAction = ChangeLightAction(light: false)

var mainView = MainView(action: lightAction)

mainView.buttonAction()
mainView.refresh()


//-----

import SwiftUI

// 6. O mesmo Command aplicado no mundo SwiftUI.
//    DeviceCardView é um Invoker VISUAL genérico: recebe qualquer `Action`
//    e a "cara" do device (deviceUI) sem saber qual comando é de fato.
struct DeviceCardView<Content: View>: View {
    let title: String
    let action: Action
    let deviceUI: Content // aqui injetamos a "cara" do device

    init(title: String, action: Action, @ViewBuilder deviceUI: () -> Content) {
        self.title = title
        self.action = action
        self.deviceUI = deviceUI()
    }

    var body: some View {
        VStack {
            Text(title).font(.headline)

            deviceUI // a view específica (luz, tomada, etc)

            HStack {
                // os botões só disparam o comando — não conhecem a regra concreta
                Button("Toggle") { action.changeCurrentState() }
                Button("Refresh") { action.makeRefreshCall() }
            }
        }
    }
}

// 7. Exemplo de uso: cada card injeta um comando diferente na MESMA view
struct HomeView: View {
    var body: some View {
        HStack {
            // Card de Luz
            DeviceCardView(title: "Luz Sala", action: ChangeLightAction(light: false)) {
                Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
            }

            // Card de Tomada
            DeviceCardView(title: "Tomada Cozinha", action: ChangePlugAction(doorlock: false)) {
                Image(systemName: "powerplug").foregroundColor(.blue)
            }
        }
    }
}

//: [Next](@next)
