//: [Previous](@previous)

import Foundation

/*
 Template Method — define o esqueleto de um algoritmo numa classe base e deixa
 as subclasses sobrescreverem apenas os passos que variam, sem mudar a estrutura.
 Problema que resolve: elimina a duplicação da mesma sequência de passos em várias
 classes. A ordem do algoritmo fica num lugar só; cada variação implementa só o que muda.
*/

// ========================================================
// ANTES — sem o pattern (o problema)
// ========================================================
// Cada relatório repete a mesma estrutura (buscar, processar, formatar, imprimir).
// Só o passo de formatação muda, mas todo o esqueleto é copiado e colado.
// Se a ordem dos passos mudar, é preciso editar TODAS as classes.

class PDFReportBefore {
    func generate() {
        // passo 1
        let data = fetchData()
        // passo 2
        let processed = processData(data)
        // passo 3 — único para PDF
        let formatted = "=== PDF ===\n\(processed)"
        // passo 4
        print(formatted)
    }

    private func fetchData() -> String { return "dados brutos" }
    private func processData(_ data: String) -> String { return data.uppercased() }
}

class ExcelReportBefore {
    func generate() {
        // mesma estrutura duplicada
        let data = fetchData()
        let processed = processData(data)
        // passo 3 — único para Excel
        let formatted = "COL_A,COL_B\n\(processed)"
        print(formatted)
    }

    private func fetchData() -> String { return "dados brutos" }
    private func processData(_ data: String) -> String { return data.uppercased() }
}

// Uso — cada classe carrega sua própria cópia do algoritmo
PDFReportBefore().generate()
ExcelReportBefore().generate()

///--------------------------------------------------------------------------------------------------------------------------

// ========================================================
// DEPOIS — com o Template Method
// ========================================================

// 1. A classe base define o "template": o método generate() é FINAL — ele é o
//    esqueleto fixo do algoritmo e não pode ser sobrescrito. Ele chama os passos
//    na ordem correta; alguns são hooks opcionais, outro é obrigatório.
class ReportBase {
    final func generate() {
        beforeGenerate()      // hook — opcional
        let data = fetchData()
        let formatted = format(data)
        afterFormat()         // hook — opcional
        processData(formatted)
    }

    // 2. Hooks com implementação padrão vazia — a subclasse sobrescreve se quiser.
    func beforeGenerate() {}
    func afterFormat() {}

    // 3. Passo obrigatório — cada subclasse DEVE fornecer a sua formatação.
    func format(_ data: String) -> String {
        fatalError("Subclasses devem implementar")
    }

    // 4. Passos fixos, iguais para todos os relatórios — ficam só aqui.
    private func fetchData() -> String {
        return "dados brutos"
    }

    private func processData(_ data: String) -> String {
        print(data.uppercased())
        return data.uppercased()
    }
}

// 5. Subclasse — sobrescreve apenas o que varia (o hook e o passo obrigatório),
//    reaproveitando todo o esqueleto de generate().
class WatermarkedReport: ReportBase {
    override func afterFormat() {
        print("Marca d'agua adicionada")
    }

    override func format(_ data: String) -> String {
        return "=== PDF ===\n\(data)"
    }
}

// 6. Uso — instancia a subclasse e chama o template; a ordem dos passos está
//    garantida pela classe base.
let report = WatermarkedReport()
report.generate()

//: [Next](@next)
