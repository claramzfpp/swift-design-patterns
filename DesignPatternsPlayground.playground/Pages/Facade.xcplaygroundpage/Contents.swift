//: [Previous](@previous)

import Foundation

/*
 Facade — expõe uma interface única e simples para um subsistema complexo.
 Problema que resolve: em vez de o cliente conhecer e orquestrar várias
 classes na ordem certa, ele faz uma só chamada e a Facade cuida do resto.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Os subsistemas existem do mesmo jeito, mas AQUI ninguém os esconde.
// (sufixo "0" só para não colidir com a seção DEPOIS)

class BufferServiceBefore {
    func start(url: String) { print("Buffer iniciado") }
    func stop() { print("Buffer parado") }
}

class VideoDecoderBefore {
    func configure(resolution: String) { print("Decoder configurado: \(resolution)") }
    func play() { print("Reproduzindo vídeo") }
    func stop() { print("Vídeo parado") }
}

class AudioProcessorBefore {
    func configure(channels: Int) { print("Áudio configurado: \(channels) canais") }
    func mute() { print("Áudio mutado") }
}

class DRMValidatorBefore {
    func validateLicense(videoId: String) -> Bool {
        print("Licença validada para \(videoId)")
        return true
    }
}

class AnalyticsServiceBefore {
    func logStart(videoId: String) { print("Analytics: início \(videoId)") }
    func logEnd(videoId: String) { print("Analytics: fim \(videoId)") }
}

// O CLIENTE precisa conhecer os 5 subsistemas e chamá-los na ordem exata.
// Dor real:
//  - acoplamento: a tela depende de DRM, Buffer, Decoder, Audio e Analytics;
//  - ordem frágil: se você validar o DRM depois do play, ou esquecer o buffer,
//    tudo quebra — e o compilador não avisa;
//  - repetição: essa mesma sequência precisa ser copiada em todo lugar que dá play.
let bufferBefore = BufferServiceBefore()
let decoderBefore = VideoDecoderBefore()
let audioBefore = AudioProcessorBefore()
let drmBefore = DRMValidatorBefore()
let analyticsBefore = AnalyticsServiceBefore()

let videoIdBefore = "123"
if drmBefore.validateLicense(videoId: videoIdBefore) {   // 1. tem que vir primeiro
    bufferBefore.start(url: "www")               // 2. depois o buffer
    decoderBefore.configure(resolution: "hd")    // 3. configurar o decoder
    audioBefore.configure(channels: 2)           // 4. configurar o áudio
    analyticsBefore.logStart(videoId: videoIdBefore) // 5. registrar métrica
    decoderBefore.play()                         // 6. só então dar play
} else {
    print("Licença inválida")
}
// Errar qualquer passo dessa lista = bug silencioso.

// ========================================================
// DEPOIS — com a Facade
// ========================================================

// 1. Os subsistemas — cada um com sua responsabilidade
class BufferService {
    func start(url: String) { print("Buffer iniciado") }
    func stop() { print("Buffer parado") }
}

class VideoDecoder {
    func configure(resolution: String) { print("Decoder configurado: \(resolution)") }
    func play() { print("Reproduzindo vídeo") }
    func stop() { print("Vídeo parado") }
}

class AudioProcessor {
    func configure(channels: Int) { print("Áudio configurado: \(channels) canais") }
    func mute() { print("Áudio mutado") }
}

class DRMValidator {
    func validateLicense(videoId: String) -> Bool {
        print("Licença validada para \(videoId)")
        return true
    }
}

class AnalyticsService {
    func logStart(videoId: String) { print("Analytics: início \(videoId)") }
    func logEnd(videoId: String) { print("Analytics: fim \(videoId)") }
}

// 2. A Facade — interface simplificada que orquestra os subsistemas.
//    Toda a ordem correta fica encapsulada AQUI, num lugar só.
class VideoPlayerFacade {
    private let buffer = BufferService()
    private let decoder = VideoDecoder()
    private let audio = AudioProcessor()
    private let drm = DRMValidator()
    private let analytics = AnalyticsService()

    func play(videoId: String, url: String) {
        guard drm.validateLicense(videoId: videoId) else {
            print("Licença inválida")
            return
        }
        buffer.start(url: url)
        decoder.configure(resolution: "hd")
        audio.configure(channels: 2)
        analytics.logStart(videoId: videoId)
        decoder.play()
    }

    func stop(videoId: String) {
        decoder.stop()
        buffer.stop()
        analytics.logEnd(videoId: videoId)
    }

    func mute() {
        audio.mute()
    }
}

// 3. Uso — o cliente só conhece a Facade e faz UMA chamada.
//    Sem risco de errar a ordem, sem acoplamento aos subsistemas.
let player = VideoPlayerFacade()
player.play(videoId: "123", url: "www")
player.mute()
player.stop(videoId: "123")

//: [Next](@next)
