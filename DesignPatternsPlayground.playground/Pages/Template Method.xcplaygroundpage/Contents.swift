//: [Previous](@previous)

import Foundation

// Sem Template Method — estrutura duplicada em cada classe
class RelatorioPDF {
    func gerar() {
        // passo 1
        let dados = buscarDados()
        // passo 2
        let processados = processarDados(dados)
        // passo 3 — único para PDF
        let formatado = "=== PDF ===\n\(processados)"
        // passo 4
        print(formatado)
    }
    
    private func buscarDados() -> String { return "dados brutos" }
    private func processarDados(_ dados: String) -> String { return dados.uppercased() }
}

class RelatorioExcel {
    func gerar() {
        // mesma estrutura duplicada
        let dados = buscarDados()
        let processados = processarDados(dados)
        // passo 3 — único para Excel
        let formatado = "COL_A,COL_B\n\(processados)"
        print(formatado)
    }
    
    private func buscarDados() -> String { return "dados brutos" }
    private func processarDados(_ dados: String) -> String { return dados.uppercased() }
}

//-------------------------

class RelatorioBase {
    final func gerar() {
        antesDeGerar()      // hook — opcional
        let dados = buscarDados()
        let formatado = formatar(dados)
        depoisDeFormatar()  // hook — opcional
        processarDados(formatado)
    }
    
    // hooks com implementação padrão vazia
    func antesDeGerar() {}
    func depoisDeFormatar() {}
    
    // passo obrigatório
    func formatar(_ dados: String) -> String {
        fatalError("Subclasses devem implementar")
    }
    
    private func buscarDados() -> String {
        return "dados brutos"
    }
    
    private func processarDados(_ dados: String) -> String {
        return dados.uppercased()
    }
}

class RelatorioComMarcaDagua: RelatorioBase {
    override func depoisDeFormatar() {
        print("💧 Marca d'água adicionada")
    }
    
    override func formatar(_ dados: String) -> String {
        return "=== PDF ===\n\(dados)"
    }
}

//: [Next](@next)
