//: [Previous](@previous)

import Foundation

/*
 Composite — trata um GRUPO de objetos igual a um objeto único, pela mesma interface.
 Problema que resolve: o cliente não precisa saber se está falando com um provider
 só ou com vários; ele chama track() uma vez e o grupo se encarrega de repassar.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// SDKs de terceiros: não temos controle sobre a API deles.
struct FirebaseBefore { //não temos controle
    func trackEvent(name: String) {
        print("Firebase: \(name)")
    }
}

struct AmplitudeBefore { //não temos controle
    func trackEvent(name: String) {
        print("Amplitude: \(name)")
    }
}

// Sem Composite, a própria View precisa conhecer CADA provider e chamar um por um.
// A dor: cada provider novo obriga a editar o onAppear (e todo lugar que faz tracking).
struct ContentViewBefore {
    let firebase = FirebaseBefore()
    let amplitude = AmplitudeBefore()

    func onAppear() {
        // tenho que lembrar de chamar TODOS, manualmente:
        firebase.trackEvent(name: "ContentView did appear")
        amplitude.trackEvent(name: "ContentView did appear")
        // adicionou Mixpanel? mixpanel.trackEvent(...) aqui também.
        // adicionou outra tela? repetir tudo de novo.
    }
}

let viewBefore = ContentViewBefore()
viewBefore.onAppear()

// ========================================================
// DEPOIS — com o Composite
// ========================================================

// SDKs de terceiros — não temos controle sobre a API deles.
struct Firebase { //não temos controle
    func trackEvent(name: String) {
        print("Firebase: \(name)")
    }
}

struct Amplitude { //não temos controle - novo
    func trackEvent(name: String) {
        print("Amplitude: \(name)")
    }
}

// 1. A interface comum — tanto uma folha quanto o grupo a implementam.
protocol Analytics {
    func track(name: String)
}

// 2. As "folhas" — adaptadores que temos controle, cada um embrulha um SDK.
struct FirebaseAnalytics: Analytics { //temos controle
    let firebase: Firebase = Firebase()

    func track(name: String) {
        firebase.trackEvent(name: name)
    }
}

struct AmplitudeAnalytics: Analytics { //temos controle
    let amplitude: Amplitude = Amplitude()

    func track(name: String) {
        amplitude.trackEvent(name: name)
    }
}

// 3. O Composite — é um Analytics que CONTÉM vários Analytics.
//    Como implementa a mesma interface, o cliente o trata igual a uma folha.
struct AnalyticsComposite: Analytics { // "árvore que conecta tudo"
    let analytics: [Analytics]

    func track(name: String) {
        // repassa a chamada para cada filho — o cliente nem sabe quantos são.
        for analytics in self.analytics {
            analytics.track(name: name)
        }
    }
}

// 4. O cliente — depende só de Analytics. Não sabe (nem precisa) se é um ou vários.
struct ContentView {
    let analyticsHandler: Analytics

    func onAppear() {
        analyticsHandler.track(name: "ContentView did appear")
    }
}

// 5. Uso — monto o grupo uma vez; adicionar um provider novo é só incluir na lista.
let analytics: [Analytics] = [FirebaseAnalytics(), AmplitudeAnalytics()]
let handler = AnalyticsComposite(analytics: analytics)

let view = ContentView(analyticsHandler: handler)
view.onAppear()

// A mesma View também aceita um provider único, sem mudar nada:
let view2 = ContentView(analyticsHandler: FirebaseAnalytics())



//: [Next](@next)
