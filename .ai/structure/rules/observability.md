# Observability Rules

## Pilares

Todo microservice deve ter:

- Logs estruturados.
- Métricas.
- Traces distribuídos quando houver chamada entre serviços.
- Health checks.

## Logs

Logs devem conter:

- correlationId
- serviceName
- operation
- entityId quando aplicável
- userId quando seguro e permitido
- status
- durationMs em operações relevantes

## Métricas

Métricas recomendadas:

- Latência por endpoint.
- Taxa de erro.
- Throughput.
- Tempo de chamada externa.
- Tempo de query MongoDB quando crítico.
- Consumo de eventos.
- Falhas de eventos.

## Tracing

- Propagar correlationId.
- Propagar traceId.
- Instrumentar chamadas HTTP externas.
- Instrumentar mensageria quando aplicável.

## Health checks

Health deve verificar:

- Aplicação.
- MongoDB.
- Broker de mensagens, se usado.
- Dependências críticas, quando viável.

## Proibido

- Log sem contexto.
- Logar dados sensíveis.
- Capturar exceção e ignorar.
- Métricas com cardinalidade explosiva.
