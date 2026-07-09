# Performance Rules

## Backend

- Usar paginação em listagens.
- Evitar carregar documentos completos sem necessidade.
- Usar projections quando possível.
- Evitar N+1 de chamadas HTTP entre serviços.
- Definir timeout em chamadas externas.
- Cachear dados de baixa volatilidade.
- Evitar serialização de objetos gigantes.

## MongoDB

- Toda query crítica precisa de índice.
- Avaliar explain plan para queries lentas.
- Evitar regex não indexável.
- Evitar skip profundo.
- Criar índices compostos conforme padrão de filtro e ordenação.

## Ionic

- Lazy loading obrigatório.
- Evitar bundles grandes.
- Evitar imports que prejudiquem tree-shaking.
- Usar imagens otimizadas.
- Evitar renderização desnecessária de listas grandes.
- Usar virtual scroll quando necessário.

## Microservices

- Evitar chamadas síncronas em cascata.
- Usar eventos para desacoplamento.
- Evitar payloads grandes.
- Medir antes de otimizar.

## Proibido

- Otimização prematura complexa.
- Cache sem estratégia de invalidação.
- Query sem limite em coleção grande.
- Endpoint que retorna massa de dados sem paginação.
