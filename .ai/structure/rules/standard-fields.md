# Standard Fields Rules

## Objetivo

Padronizar entrada, exibicao, contratos e validacao dos campos CPF, CNPJ, CEP e telefone.

## Regra geral

- Interfaces visuais devem aplicar mascara durante digitacao e exibicao.
- A mascara nao substitui validacao de formato, tamanho ou digitos verificadores quando aplicavel.
- Frontend deve remover a mascara antes de enviar o valor para a API.
- APIs, eventos, dominio e persistencia devem usar o valor canonico sem pontuacao.
- Backend deve validar novamente o valor recebido e rejeitar caracteres nao permitidos.
- Logs devem seguir `.ai/structure/rules/security.md` e nunca expor CPF ou outro dado pessoal completo.

## Formatos padrao

| Campo | Mascara de apresentacao | Valor canonico aceito |
|---|---|---|
| CPF | `000.000.000-00` | Exatamente 11 digitos numericos |
| CNPJ | `AA.AAA.AAA/AAAA-00` | Exatamente 14 caracteres; letras ASCII maiusculas e numeros nas 12 primeiras posicoes, e numeros nas 2 ultimas |
| CEP | `00000-000` | Exatamente 8 digitos numericos |
| Telefone fixo | `(00) 0000-0000` | Exatamente 10 digitos numericos, incluindo DDD |
| Telefone celular | `(00) 00000-0000` | Exatamente 11 digitos numericos, incluindo DDD |

`A` representa caractere alfanumerico. Entradas alfabeticas de CNPJ devem ser normalizadas para maiusculas antes do envio e da validacao.

## Frontend Ionic Angular

- Usar `inputmode="numeric"` para CPF, CEP e telefone.
- Impedir ou remover caracteres nao numericos em CPF, CEP e telefone.
- Permitir somente letras e numeros no CNPJ e normalizar letras para maiusculas.
- Aplicar mascara sem armazenar pontuacao no modelo enviado para a API.
- Exibir erro claro para formato, tamanho ou validacao invalida.
- Criar testes para digitacao, colagem, remocao da mascara e payload enviado.

## APIs e dominio

- Documentar no OpenAPI o formato canonico aceito, exemplos sem mascara e restricoes.
- Nao aceitar pontuacao nos payloads, salvo contrato legado explicitamente documentado.
- Usar DTOs tipados e validacao de borda para formato e tamanho.
- Proteger validacoes de negocio, como digitos verificadores, em Value Objects quando o campo fizer parte do dominio.
- Preservar compatibilidade de contratos existentes; mudancas de formato devem ser versionadas quando forem breaking changes.

## Cenarios minimos de teste

- Aceita valor canonico valido.
- Rejeita pontuacao no payload da API.
- Rejeita tamanho incorreto.
- Rejeita caracteres nao permitidos.
- CNPJ aceita letras e numeros nas posicoes permitidas e normaliza letras para maiusculas.
- Frontend aplica a mascara correta e envia o valor sem mascara.
