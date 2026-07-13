//: [Previous](@previous)

//Before

// Problema 1: estrutura interna exposta — qualquer um pode fazer playlist.musicas[i]
// Problema 2: lógica de travessia misturada com lógica de negócio
// Problema 3: se mudar de array para outra estrutura, quebra tudo

class PlaylistBefore {
    var musicas: [String] = [] // exposto — qualquer um acessa e modifica
    var artistas: [String] = []
    var duracoes: [Double] = []
}

class PlayerMusicaBefore {
    func tocarTodas(playlist: PlaylistBefore) {
        // cliente acoplado ao array — sabe que é array, usa índice
        for i in 0..<playlist.musicas.count {
            print("Tocando: \(playlist.musicas[i]) - \(playlist.artistas[i])")
        }
    }
    
    func tocarReverso(playlist: PlaylistBefore) {
        // duplica a lógica de travessia — agora em dois lugares
        var i = playlist.musicas.count - 1
        while i >= 0 {
            print("Tocando: \(playlist.musicas[i])")
            i -= 1
        }
    }
    
    func tocarFiltrado(playlist: PlaylistBefore, artista: String) {
        // mais uma travessia duplicada
        for i in 0..<playlist.musicas.count {
            if playlist.artistas[i] == artista {
                print("Tocando: \(playlist.musicas[i])")
            }
        }
    }
}

//Três problemas claros: estrutura interna exposta, lógica de travessia duplicada em três métodos, e cliente completamente acoplado ao array.

//After

// 1. O modelo
struct Musica {
    let titulo: String
    let artista: String
    let duracao: Double
}

// 2. O protocolo do Iterator
protocol MusicaIterator {
    func temProximo() -> Bool
    func proximo() -> Musica
    func resetar()
}

// 3. Iterators concretos — cada um encapsula uma forma de percorrer

class IteratorNormal: MusicaIterator {
    private let musicas: [Musica]
    private var indice = 0
    
    init(musicas: [Musica]) { self.musicas = musicas }
    
    func temProximo() -> Bool { return indice < musicas.count }
    func proximo() -> Musica { let m = musicas[indice]; indice += 1; return m }
    func resetar() { indice = 0 }
}

class IteratorReverso: MusicaIterator {
    private let musicas: [Musica]
    private var indice: Int
    
    init(musicas: [Musica]) {
        self.musicas = musicas
        self.indice = musicas.count - 1
    }
    
    func temProximo() -> Bool { return indice >= 0 }
    func proximo() -> Musica { let m = musicas[indice]; indice -= 1; return m }
    func resetar() { indice = musicas.count - 1 }
}

class IteratorAleatorio: MusicaIterator {
    private var musicas: [Musica]
    private var indice = 0
    
    init(musicas: [Musica]) { self.musicas = musicas.shuffled() }
    
    func temProximo() -> Bool { return indice < musicas.count }
    func proximo() -> Musica { let m = musicas[indice]; indice += 1; return m }
    func resetar() { musicas = musicas.shuffled(); indice = 0 }
}

// 4. A coleção — estrutura interna completamente escondida
class Playlist {
    private var musicas: [Musica] = [] // privado — ninguém acessa diretamente
    
    func adicionar(_ musica: Musica) { musicas.append(musica) }
    
    func iteratorNormal() -> MusicaIterator { return IteratorNormal(musicas: musicas) }
    func iteratorReverso() -> MusicaIterator { return IteratorReverso(musicas: musicas) }
    func iteratorAleatorio() -> MusicaIterator { return IteratorAleatorio(musicas: musicas) }
}

// 5. Cliente — não sabe nada sobre a estrutura interna
class PlayerMusica {
    func tocar(iterator: MusicaIterator) {
        while iterator.temProximo() {
            let musica = iterator.proximo()
            print("▶️ \(musica.titulo) — \(musica.artista)")
        }
    }
}

// Uso
let playlist = Playlist()
playlist.adicionar(Musica(titulo: "Bohemian Rhapsody", artista: "Queen", duracao: 354))
playlist.adicionar(Musica(titulo: "Hotel California", artista: "Eagles", duracao: 391))
playlist.adicionar(Musica(titulo: "Stairway to Heaven", artista: "Led Zeppelin", duracao: 482))

let player = PlayerMusica()

print("--- Normal ---")
player.tocar(iterator: playlist.iteratorNormal())

print("--- Reverso ---")
player.tocar(iterator: playlist.iteratorReverso())

print("--- Aleatório ---")
player.tocar(iterator: playlist.iteratorAleatorio())

//-----------------------------------------------

// Iterator + Strategy, as vezes podem andar juntos

// Strategy — define o que fazer com cada música
protocol EstrategiaReproducao {
    func reproduzir(musica: Musica)
}

class ReproducaoNormal: EstrategiaReproducao {
    func reproduzir(musica: Musica) {
        print("▶️ Tocando: \(musica.titulo)")
    }
}

class ReproducaoComCrossfade: EstrategiaReproducao {
    func reproduzir(musica: Musica) {
        print("🎚 Crossfade → \(musica.titulo)")
    }
}

class PreCarregamento: EstrategiaReproducao {
    func reproduzir(musica: Musica) {
        print("⬇️ Pré-carregando: \(musica.titulo) (\(musica.duracao)s)")
    }
}

// Player usa Iterator (como percorrer) + Strategy (o que fazer com cada música)
class PlayerMusicaV2 {
    private var estrategia: EstrategiaReproducao
    
    init(estrategia: EstrategiaReproducao) {
        self.estrategia = estrategia
    }
    
    func trocarEstrategia(_ nova: EstrategiaReproducao) {
        self.estrategia = nova
    }
    
    // Iterator decide a ordem — Strategy decide o que fazer com cada música
    func tocar(iterator: MusicaIterator) {
        while iterator.temProximo() {
            let musica = iterator.proximo()
            estrategia.reproduzir(musica: musica) // delega para a estratégia
        }
    }
}

// Uso — combinando os dois livremente
let playerV2 = PlayerMusicaV2(estrategia: ReproducaoNormal())

print("--- Normal + Crossfade ---")
playerV2.trocarEstrategia(ReproducaoComCrossfade())
playerV2.tocar(iterator: playlist.iteratorNormal())

print("--- Aleatório + Pré-carregamento ---")
playerV2.trocarEstrategia(PreCarregamento())
playerV2.tocar(iterator: playlist.iteratorAleatorio())

print("--- Reverso + Normal ---")
playerV2.trocarEstrategia(ReproducaoNormal())
playerV2.tocar(iterator: playlist.iteratorReverso())
