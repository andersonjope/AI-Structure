# AI Operating Model

Esta pasta define o modelo operacional para agentes de IA trabalharem neste monorepo com consistência técnica, contexto de negócio e rastreabilidade de decisões.

## Ordem de leitura

Para qualquer tarefa relevante, uma IA deve seguir esta ordem:

1. Ler `AGENTS.md` ou o arquivo de entrada equivalente da ferramenta.
2. Ler `.ai/structure/agents/README.md` para escolher os papéis especializados.
3. Ler `.ai/context/` para entender produto, bounded contexts, integrações, requisitos não funcionais e ADRs.
4. Ler `.ai/structure/rules/` conforme a área afetada.
5. Usar `.ai/structure/templates/` quando criar ou alterar contratos, ADRs, eventos, microservices, use cases ou planos de teste.

## Estrutura

```text
.ai/
├── context/          # contexto do produto, arquitetura, integrações e ADRs
└── structure/
    ├── agents/       # papéis especializados e roteamento operacional
    ├── rules/        # regras técnicas e arquiteturais por área
    └── templates/    # modelos para artefatos recorrentes
```

## Como aplicar em uma tarefa

1. Identificar o app, serviço, bounded context ou camada afetada.
2. Selecionar os agentes mínimos necessários em `.ai/structure/agents/README.md`.
3. Consultar regras específicas da área.
4. Registrar premissas quando o contexto de negócio estiver incompleto.
5. Implementar a menor alteração suficiente.
6. Validar com testes proporcionais ao risco.
7. Reportar Definition of Done, impactos e riscos residuais.

## Portabilidade para outros projetos

Esta estrutura pode ser reutilizada em outros projetos, desde que seja adaptada em três camadas:

- **Universal**: agentes, Definition of Done, modelo de ADR (`.ai/structure/templates/adr-template.md`), templates de contrato, segurança, testes, clean code, observabilidade, documentação (`rules/documentation.md`) e pipeline de CI/deploy (`rules/ci.md`, `rules/deploy.md`, com os respectivos templates).
- **Stack-specific**: regras de Spring Boot, MongoDB, Ionic Angular, Docker e padrões de monorepo.
- **Product-specific**: contexto de negócio, bounded contexts, linguagem ubíqua, integrações, requisitos não funcionais e ADRs reais.

Todo o conteúdo em `.ai/context/` (exceto `ADR-000-template.md`) é hoje um
**exemplo ilustrativo** preenchido com o produto de referência (AgendaHub) —
cada arquivo tem um aviso "Exemplo ilustrativo" no topo. Ao adotar este
template para um projeto novo (ver `README.md` > "Como usar este repositório
para iniciar um novo projeto"), substitua esse conteúdo pelo contexto real do
seu produto e remova os avisos.

Ao usar esta estrutura como base para outro projeto:

1. Substituir `.ai/context/` (business-context, bounded-contexts, ubiquitous-language, integration-map, ADRs reais) antes de implementar funcionalidades.
2. Remover ou substituir regras de stack que não se aplicam.
3. Revisar `.ai/structure/templates/` para os contratos e tecnologias do novo projeto.
4. Criar ADRs reais para decisões arquiteturais já tomadas, usando `.ai/structure/templates/adr-template.md`.
5. Garantir que `AGENTS.md`, `CLAUDE.md` e instruções do Copilot apontem para `.ai/`.

## Regras de manutenção

- Sempre atualizar `.ai/context/` quando um bounded context, integração ou serviço mudar.
- Sempre atualizar `.ai/structure/rules/` quando um padrão técnico virar obrigatório.
- Sempre criar ADR quando uma decisão arquitetural relevante for tomada ou substituída.
- Não duplicar regras longas em arquivos de entrada de ferramentas; manter a regra central em `.ai/structure/rules/` e apenas referenciar.
- Após alterar qualquer arquivo em `.ai/` ou nos entry points (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/`), rodar `scripts/validate-ai-structure.sh` antes de abrir PR. O CI roda o mesmo script automaticamente via `.github/workflows/validate-ai-structure.yml`.
