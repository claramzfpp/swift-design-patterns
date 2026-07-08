//: [Previous](@previous)

import Foundation

/*
 Adapter — faz uma interface incompatível funcionar com a interface que seu app espera.
 Problema que resolve: você tem um SDK legado/de terceiro com assinatura própria, mas
 o app fala em outro "idioma". O Adapter traduz um no outro, sem espalhar conversões.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// O app espera algo que saiba fazer log(_:), mas tudo o que existe é este SDK
// legado, com uma assinatura totalmente diferente (writeEntry(text:severity:)).
// (sufixo "Before" só para não colidir com a seção DEPOIS)

class LegacyLoggerBefore {
    // API do SDK legado: nome e parâmetros que NÃO batem com o que o app quer
    func writeEntry(text: String, severity: Int) {
        print("[LEGADO][\(severity)] \(text)")
    }
}

// O cliente (ex: um termostato da casa inteligente) quer só "logar uma mensagem",
// mas é obrigado a conhecer o SDK e traduzir a chamada na mão, toda vez.
class ThermostatBefore {
    private let logger = LegacyLoggerBefore()

    func setTemperature(_ celsius: Int) {
        // conversão espalhada: em todo ponto que loga, repito o mapeamento
        // "mensagem -> text + severity". Se a API do SDK mudar, quebra em vários lugares.
        logger.writeEntry(text: "Temperatura ajustada para \(celsius)°C", severity: 1)
    }
}

// Uso — o cliente fica acoplado ao formato do SDK legado
ThermostatBefore().setTemperature(22)

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Adapter
// ========================================================

// 1. A interface que o app REALMENTE espera — simples e no idioma do app.
protocol Logger {
    func log(_ message: String)
}

// 2. O código legado permanece intocado — não podemos (ou não queremos) mudá-lo.
class LegacyLogger {
    func writeEntry(text: String, severity: Int) {
        print("[LEGADO][\(severity)] \(text)")
    }
}

// 3. O Adapter conforma ao protocolo Logger e, por dentro, TRADUZ a chamada
//    para o formato do SDK legado. A conversão vive num lugar só.
class LegacyLoggerAdapter: Logger {
    private let legacy: LegacyLogger

    init(legacy: LegacyLogger = LegacyLogger()) {
        self.legacy = legacy
    }

    func log(_ message: String) {
        // adapta a interface esperada (log) para a interface incompatível (writeEntry)
        legacy.writeEntry(text: message, severity: 1)
    }
}

// 4. O cliente agora só conhece o protocolo Logger — nada do SDK legado vaza aqui.
//    Trocar o SDK por outro = criar outro Adapter, sem tocar no Thermostat.
class Thermostat {
    private let logger: Logger

    init(logger: Logger) { self.logger = logger }

    func setTemperature(_ celsius: Int) {
        logger.log("Temperatura ajustada para \(celsius)°C")
    }
}

// 5. Uso — injeta-se o Adapter onde o app pede um Logger.
let thermostat = Thermostat(logger: LegacyLoggerAdapter())
thermostat.setTemperature(22)  // [LEGADO][1] Temperatura ajustada para 22°C

//: [Next](@next)
