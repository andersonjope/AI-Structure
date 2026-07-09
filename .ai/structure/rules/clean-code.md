# Clean Code Rules

## Princípios

- Código deve ser simples, legível e intencional.
- Nomes devem revelar intenção.
- Métodos devem ser pequenos.
- Classes devem ter uma responsabilidade principal.
- Reduzir acoplamento.
- Aumentar coesão.

## Nomes

Prefira:

```java
calculateTotalAmount()
activateSubscription()
rejectPayment()
```

Evite:

```java
process()
doStuff()
handle()
manager()
```

## Métodos

- Um método deve fazer uma coisa.
- Evitar muitos parâmetros.
- Preferir objetos de comando quando houver muitos dados.
- Evitar efeitos colaterais ocultos.

## Classes

- Evitar God Class.
- Evitar Service gigante.
- Evitar Helper genérico.
- Separar responsabilidades.

## Comentários

Comentários devem explicar o porquê, não o óbvio.

## Proibido

- Código duplicado sem justificativa.
- Método longo com múltiplos níveis de abstração.
- Boolean parameter que muda completamente comportamento.
- Null sem tratamento explícito.
- Exceções genéricas sem contexto.
