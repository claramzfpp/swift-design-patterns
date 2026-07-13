//: [Previous](@previous)

import Foundation

/*
 Iterator Pattern — fornece uma forma de percorrer os elementos de uma coleção
 sem expor sua estrutura interna.
 Problema que resolve: elimina o acoplamento do cliente ao formato interno da coleção
 (array, lista, etc.) e evita duplicar a lógica de travessia em vários lugares.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Problema 1: estrutura interna exposta — qualquer um pode fazer playlist.songs[i]
// Problema 2: lógica de travessia misturada com lógica de negócio
// Problema 3: se mudar de array para outra estrutura, quebra tudo

class PlaylistBefore {
    var songs: [String] = [] // exposto — qualquer um acessa e modifica
    var artists: [String] = []
    var durations: [Double] = []
}

class MusicPlayerBefore {
    func playAll(playlist: PlaylistBefore) {
        // cliente acoplado ao array — sabe que é array, usa índice
        for i in 0..<playlist.songs.count {
            print("Tocando: \(playlist.songs[i]) - \(playlist.artists[i])")
        }
    }

    func playReverse(playlist: PlaylistBefore) {
        // duplica a lógica de travessia — agora em dois lugares
        var i = playlist.songs.count - 1
        while i >= 0 {
            print("Tocando: \(playlist.songs[i])")
            i -= 1
        }
    }

    func playFiltered(playlist: PlaylistBefore, artist: String) {
        // mais uma travessia duplicada
        for i in 0..<playlist.songs.count {
            if playlist.artists[i] == artist {
                print("Tocando: \(playlist.songs[i])")
            }
        }
    }
}

// Três problemas claros: estrutura interna exposta, lógica de travessia duplicada
// em três métodos, e cliente completamente acoplado ao array.

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Iterator Pattern
// ========================================================

// 1. O modelo
struct Song {
    let title: String
    let artist: String
    let duration: Double
}

// 2. O protocolo do Iterator
protocol SongIterator {
    func hasNext() -> Bool
    func next() -> Song
    func reset()
}

// 3. Iterators concretos — cada um encapsula uma forma de percorrer

class NormalIterator: SongIterator {
    private let songs: [Song]
    private var index = 0

    init(songs: [Song]) { self.songs = songs }

    func hasNext() -> Bool { return index < songs.count }
    func next() -> Song { let song = songs[index]; index += 1; return song }
    func reset() { index = 0 }
}

class ReverseIterator: SongIterator {
    private let songs: [Song]
    private var index: Int

    init(songs: [Song]) {
        self.songs = songs
        self.index = songs.count - 1
    }

    func hasNext() -> Bool { return index >= 0 }
    func next() -> Song { let song = songs[index]; index -= 1; return song }
    func reset() { index = songs.count - 1 }
}

class ShuffleIterator: SongIterator {
    private var songs: [Song]
    private var index = 0

    init(songs: [Song]) { self.songs = songs.shuffled() }

    func hasNext() -> Bool { return index < songs.count }
    func next() -> Song { let song = songs[index]; index += 1; return song }
    func reset() { songs = songs.shuffled(); index = 0 }
}

// 4. A coleção — estrutura interna completamente escondida
class Playlist {
    private var songs: [Song] = [] // privado — ninguém acessa diretamente

    func add(_ song: Song) { songs.append(song) }

    func normalIterator() -> SongIterator { return NormalIterator(songs: songs) }
    func reverseIterator() -> SongIterator { return ReverseIterator(songs: songs) }
    func shuffleIterator() -> SongIterator { return ShuffleIterator(songs: songs) }
}

// 5. Cliente — não sabe nada sobre a estrutura interna
class MusicPlayer {
    func play(iterator: SongIterator) {
        while iterator.hasNext() {
            let song = iterator.next()
            print("\(song.title) — \(song.artist)")
        }
    }
}

// Uso
let playlist = Playlist()
playlist.add(Song(title: "Bohemian Rhapsody", artist: "Queen", duration: 354))
playlist.add(Song(title: "Hotel California", artist: "Eagles", duration: 391))
playlist.add(Song(title: "Stairway to Heaven", artist: "Led Zeppelin", duration: 482))

let player = MusicPlayer()

print("--- Normal ---")
player.play(iterator: playlist.normalIterator())

print("--- Reverso ---")
player.play(iterator: playlist.reverseIterator())

print("--- Aleatório ---")
player.play(iterator: playlist.shuffleIterator())

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// BÔNUS: Iterator + Strategy juntos
// ========================================================
// Iterator e Strategy às vezes andam juntos: um decide COMO percorrer,
// o outro decide O QUE fazer com cada elemento.

// Strategy — define o que fazer com cada música
protocol PlaybackStrategy {
    func play(song: Song)
}

class NormalPlayback: PlaybackStrategy {
    func play(song: Song) {
        print("Tocando: \(song.title)")
    }
}

class CrossfadePlayback: PlaybackStrategy {
    func play(song: Song) {
        print("Crossfade → \(song.title)")
    }
}

class Preload: PlaybackStrategy {
    func play(song: Song) {
        print("Pré-carregando: \(song.title) (\(song.duration)s)")
    }
}

// Player usa Iterator (como percorrer) + Strategy (o que fazer com cada música)
class MusicPlayerV2 {
    private var strategy: PlaybackStrategy

    init(strategy: PlaybackStrategy) {
        self.strategy = strategy
    }

    func changeStrategy(_ new: PlaybackStrategy) {
        self.strategy = new
    }

    // Iterator decide a ordem — Strategy decide o que fazer com cada música
    func play(iterator: SongIterator) {
        while iterator.hasNext() {
            let song = iterator.next()
            strategy.play(song: song) // delega para a estratégia
        }
    }
}

// Uso — combinando os dois livremente
let playerV2 = MusicPlayerV2(strategy: NormalPlayback())

print("--- Normal + Crossfade ---")
playerV2.changeStrategy(CrossfadePlayback())
playerV2.play(iterator: playlist.normalIterator())

print("--- Aleatório + Pré-carregamento ---")
playerV2.changeStrategy(Preload())
playerV2.play(iterator: playlist.shuffleIterator())

print("--- Reverso + Normal ---")
playerV2.changeStrategy(NormalPlayback())
playerV2.play(iterator: playlist.reverseIterator())

//: [Next](@next)
