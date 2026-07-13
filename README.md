# Swift Design Patterns Playground

Um Swift Playground de estudo com os principais **design patterns** (GoF e afins), cada um explicado no formato **ANTES → DEPOIS**: o código *sem* o pattern (mostrando o problema) e o código *com* o pattern aplicado (mostrando como ele resolve).

As explicações estão em **português** e os identificadores (classes, métodos, variáveis) em **inglês**.

## Como abrir

1. Clone o repositório:
   ```bash
   git clone https://github.com/claramzfpp/swift-design-patterns.git
   ```
2. Abra `DesignPatternsPlayground.playground` no **Xcode**.
3. Navegue entre os patterns pela lista de páginas (Project Navigator) ou pelos links **Previous/Next** no rodapé de cada página.

## Como cada página é organizada

```swift
/*
 Nome do Pattern — o que ele faz.
 Problema que resolve: ...
*/

// ==== ANTES — sem o pattern (o problema) ====
// código que ilustra a dor: acoplamento, duplicação, if/else que cresce...
// os tipos desta seção têm sufixo `Before` para não colidir com a seção de baixo.

// ==== DEPOIS — com o pattern ====
// o pattern aplicado, com comentários numerados explicando cada peça.
```

## Índice

### Fundamento
| Página | Ideia |
|--------|-------|
| [Encapsulamento](DesignPatternsPlayground.playground/Pages/Encapsulamento.xcplaygroundpage/Contents.swift) | Separar DTO (formato da API) do modelo de domínio; esconder regra de negócio atrás de uma interface. |

### Criacionais
| Página | Ideia |
|--------|-------|
| [Factory Method](DesignPatternsPlayground.playground/Pages/FactoryMethod.xcplaygroundpage/Contents.swift) | Delega a criação do objeto a subclasses/fábricas, sem acoplar o cliente ao tipo concreto. |
| [Abstract Factory](DesignPatternsPlayground.playground/Pages/AbstractFactory.xcplaygroundpage/Contents.swift) | Cria famílias de objetos relacionados (ex: UI iOS vs Android) de forma consistente. |
| [Builder](DesignPatternsPlayground.playground/Pages/Builder.xcplaygroundpage/Contents.swift) | Constrói um objeto complexo passo a passo, evitando o init telescópico. |
| [Prototype](DesignPatternsPlayground.playground/Pages/Prototype.xcplaygroundpage/Contents.swift) | Cria novos objetos clonando um já configurado, em vez de recriar do zero. |
| [Singleton](DesignPatternsPlayground.playground/Pages/Singleton.xcplaygroundpage/Contents.swift) | Garante uma única instância compartilhada globalmente. |

### Estruturais
| Página | Ideia |
|--------|-------|
| [Adapter](DesignPatternsPlayground.playground/Pages/Adapter.xcplaygroundpage/Contents.swift) | Faz uma interface incompatível (SDK legado/terceiro) funcionar com a interface que o app espera. |
| [Bridge](DesignPatternsPlayground.playground/Pages/Bridge.xcplaygroundpage/Contents.swift) | Separa abstração e implementação para variarem de forma independente (evita explosão de subclasses). |
| [Composite](DesignPatternsPlayground.playground/Pages/Composite.xcplaygroundpage/Contents.swift) | Trata um grupo de objetos do mesmo jeito que um objeto único. |
| [Decorator](DesignPatternsPlayground.playground/Pages/Decorator.xcplaygroundpage/Contents.swift) | Adiciona comportamento empilhando "embrulhos", sem modificar o objeto original. |
| [Facade](DesignPatternsPlayground.playground/Pages/Facade.xcplaygroundpage/Contents.swift) | Uma interface simples que esconde a orquestração de vários subsistemas. |
| [Flyweight](DesignPatternsPlayground.playground/Pages/Flyweight.xcplaygroundpage/Contents.swift) | Compartilha o estado comum entre muitos objetos para economizar memória. |
| [Proxy](DesignPatternsPlayground.playground/Pages/Proxy.xcplaygroundpage/Contents.swift) | Controla o acesso a um objeto (carregamento preguiçoso, permissão) através de um substituto. |

### Comportamentais
| Página | Ideia |
|--------|-------|
| [Chain of Responsibility](DesignPatternsPlayground.playground/Pages/ChainOfResponsibility.xcplaygroundpage/Contents.swift) | Passa a requisição por uma corrente de handlers até um deles tratar. |
| [Command](DesignPatternsPlayground.playground/Pages/Command.xcplaygroundpage/Contents.swift) | Encapsula uma ação como objeto, injetável em quem a executa. |
| [Iterator](DesignPatternsPlayground.playground/Pages/Iterator.xcplaygroundpage/Contents.swift) | Percorre uma coleção sem expor a estrutura interna dela. |
| [Mediator](DesignPatternsPlayground.playground/Pages/Mediator.xcplaygroundpage/Contents.swift) | Centraliza a comunicação entre componentes num mediador, em vez de eles se referenciarem direto. |
| [Memento](DesignPatternsPlayground.playground/Pages/Memento.xcplaygroundpage/Contents.swift) | Salva e restaura o estado de um objeto sem expor seus detalhes internos. |
| [Observer](DesignPatternsPlayground.playground/Pages/Observer.xcplaygroundpage/Contents.swift) | Notifica automaticamente vários interessados quando um objeto muda de estado. |
| [State](DesignPatternsPlayground.playground/Pages/State.xcplaygroundpage/Contents.swift) | O objeto muda de comportamento conforme o estado, sem if/else gigante. |
| [Strategy](DesignPatternsPlayground.playground/Pages/Strategy.xcplaygroundpage/Contents.swift) | Algoritmos intercambiáveis injetados em tempo de execução. |
| [Template Method](DesignPatternsPlayground.playground/Pages/TemplateMethod.xcplaygroundpage/Contents.swift) | Define o esqueleto de um algoritmo e deixa as subclasses preencherem passos específicos. |
| [Visitor](DesignPatternsPlayground.playground/Pages/Visitor.xcplaygroundpage/Contents.swift) | Adiciona novas operações a uma hierarquia de tipos sem modificá-los. |

### Arquitetural
| Página | Ideia |
|--------|-------|
| [Repository](DesignPatternsPlayground.playground/Pages/Repository.xcplaygroundpage/Contents.swift) | Abstrai a origem dos dados (rede, cache, banco) atrás de uma interface. |

---

Feito para estudo pessoal de Swift e arquitetura. 🦸
