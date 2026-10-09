<!-- TEMPLATE:ESQUELETO -->
# Backend Reference: Microservice Hexagonal ("Item Service")

Este documento é a referência mínima de um microservice Java/Spring Boot seguindo
`.ai/structure/rules/architecture.md`, `ddd.md` e `spring-boot.md`. Não é código
inventado: é uma versão simplificada e generalizada de um microservice real em
produção (`catalog-service`, do monorepo AgendaHub), com os campos específicos de
negócio removidos e o agregado renomeado para `Item` para ficar domain-agnostic.

Use isto como ponto de partida ao criar um microservice novo em
`apps/backend/services/<nome-do-servico>/`. Troque `Item` pelo nome do seu
agregado e `com.company.service` pelo pacote real do serviço.

## Regras aplicadas

- `.ai/structure/rules/architecture.md` — camadas e dependências permitidas.
- `.ai/structure/rules/ddd.md` — agregado, value object, invariantes.
- `.ai/structure/rules/spring-boot.md` — controllers, use cases, configuração.
- `.ai/structure/rules/api-contracts.md` — status HTTP e formato de erro.
- `.ai/structure/rules/mongodb.md` — modelagem de documento e índices.
- `.ai/structure/rules/tdd.md` e `testing.md` — testes de domínio e use case.
- `.ai/structure/rules/docker.md` — Dockerfile multi-stage.
- `.ai/structure/rules/standard-fields.md` — quando o agregado real tiver CPF, CNPJ, CEP ou telefone (o exemplo `Item` não tem).

## Estrutura de pastas

```text
apps/backend/services/<service>/
├── pom.xml
├── infra/
│   └── Dockerfile
└── src/
    ├── main/java/com/company/service/
    │   ├── ItemServiceApplication.java
    │   ├── domain/
    │   │   ├── model/
    │   │   │   ├── Item.java
    │   │   │   └── ItemStatus.java
    │   │   └── valueobject/
    │   │       └── Money.java
    │   ├── application/
    │   │   ├── command/
    │   │   │   ├── RegisterItemCommand.java
    │   │   │   └── UpdateItemCommand.java
    │   │   ├── dto/
    │   │   │   └── ItemResult.java
    │   │   ├── port/
    │   │   │   └── ItemRepository.java
    │   │   └── usecase/
    │   │       ├── ItemException.java
    │   │       └── ItemManagementUseCase.java
    │   ├── infrastructure/
    │   │   ├── config/
    │   │   │   └── ItemBeansConfiguration.java
    │   │   └── persistence/
    │   │       ├── ItemDocument.java
    │   │       └── MongoItemRepository.java
    │   └── interfaces/rest/
    │       ├── ItemController.java
    │       └── ItemExceptionHandler.java
    └── test/java/com/company/service/
        ├── domain/model/ItemTest.java
        └── application/usecase/ItemManagementUseCaseTest.java
```

## `pom.xml`

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.company</groupId>
        <artifactId>monorepo</artifactId>
        <version>0.0.1-SNAPSHOT</version>
        <relativePath>../../pom.xml</relativePath>
    </parent>

    <artifactId>item-service</artifactId>
    <name>item-service</name>
    <description>Referencia minima de microservice hexagonal.</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-mongodb</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

> Confirme o artifactId de `spring-boot-starter-web` contra a versão do Spring
> Boot Parent usada no seu monorepo antes de copiar — alguns projetos-fonte
> usaram um nome de starter diferente numa versão mais recente do framework;
> valide com `mvn dependency:tree` se tiver dúvida.

## Camada `domain`

```java
// domain/model/ItemStatus.java
package com.company.service.domain.model;

public enum ItemStatus {
    ATIVO,
    INATIVO
}
```

```java
// domain/valueobject/Money.java
package com.company.service.domain.valueobject;

import java.math.BigDecimal;
import java.math.RoundingMode;

public record Money(BigDecimal value) {

    public Money {
        if (value == null) {
            throw new IllegalArgumentException("Valor e obrigatorio");
        }
        if (value.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Valor nao pode ser negativo");
        }
        value = value.setScale(2, RoundingMode.HALF_UP);
    }

    public static Money of(BigDecimal value) {
        return new Money(value);
    }
}
```

```java
// domain/model/Item.java
package com.company.service.domain.model;

import com.company.service.domain.valueobject.Money;
import java.math.BigDecimal;
import java.util.UUID;

public class Item {

    private final UUID id;
    private String name;
    private Money price;
    private ItemStatus status;

    private Item(UUID id, String name, Money price, ItemStatus status) {
        this.id = id;
        this.name = requireText(name, "Nome e obrigatorio");
        this.price = requirePrice(price);
        this.status = status == null ? ItemStatus.ATIVO : status;
    }

    public static Item register(String name, BigDecimal price) {
        return new Item(UUID.randomUUID(), name, Money.of(price), ItemStatus.ATIVO);
    }

    public static Item restore(UUID id, String name, BigDecimal price, ItemStatus status) {
        return new Item(id, name, Money.of(price), status);
    }

    public void update(String name, BigDecimal price) {
        this.name = requireText(name, "Nome e obrigatorio");
        this.price = Money.of(price);
    }

    public void inactivate() {
        this.status = ItemStatus.INATIVO;
    }

    public void activate() {
        this.status = ItemStatus.ATIVO;
    }

    public UUID id() {
        return id;
    }

    public String name() {
        return name;
    }

    public Money price() {
        return price;
    }

    public ItemStatus status() {
        return status;
    }

    private static String requireText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
        return value.trim();
    }

    private static Money requirePrice(Money value) {
        if (value == null) {
            throw new IllegalArgumentException("Valor e obrigatorio");
        }
        return value;
    }
}
```

Pontos que a regra `ddd.md` exige e este exemplo demonstra:

- Construtor privado + factory methods (`register`/`restore`) — nunca `new Item(...)` fora da classe.
- `Money` é um Value Object imutável que valida a si mesmo no construtor compacto.
- Nenhum import de Spring, MongoDB ou Jackson no pacote `domain`.
- Mudança de estado (`inactivate`/`activate`) via método de comportamento, não setter público.

## Camada `application`

```java
// application/command/RegisterItemCommand.java
package com.company.service.application.command;

import java.math.BigDecimal;

public record RegisterItemCommand(String name, BigDecimal price) {
}
```

```java
// application/command/UpdateItemCommand.java
package com.company.service.application.command;

import java.math.BigDecimal;

public record UpdateItemCommand(String name, BigDecimal price) {
}
```

```java
// application/dto/ItemResult.java
package com.company.service.application.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record ItemResult(UUID id, String name, BigDecimal price, String status) {
}
```

```java
// application/port/ItemRepository.java
package com.company.service.application.port;

import com.company.service.domain.model.Item;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ItemRepository {

    void save(Item item);

    Optional<Item> findById(UUID id);

    List<Item> findAll();
}
```

```java
// application/usecase/ItemException.java
package com.company.service.application.usecase;

public class ItemException extends RuntimeException {

    public ItemException(String message) {
        super(message);
    }
}
```

```java
// application/usecase/ItemManagementUseCase.java
package com.company.service.application.usecase;

import com.company.service.application.command.RegisterItemCommand;
import com.company.service.application.command.UpdateItemCommand;
import com.company.service.application.dto.ItemResult;
import com.company.service.application.port.ItemRepository;
import com.company.service.domain.model.Item;
import java.util.List;
import java.util.UUID;

public class ItemManagementUseCase {

    private final ItemRepository itemRepository;

    public ItemManagementUseCase(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    public ItemResult register(RegisterItemCommand command) {
        Item item = Item.register(command.name(), command.price());
        itemRepository.save(item);
        return toResult(item);
    }

    public List<ItemResult> list() {
        return itemRepository.findAll().stream().map(this::toResult).toList();
    }

    public ItemResult findById(UUID id) {
        return toResult(findItem(id));
    }

    public ItemResult update(UUID id, UpdateItemCommand command) {
        Item item = findItem(id);
        item.update(command.name(), command.price());
        itemRepository.save(item);
        return toResult(item);
    }

    public void inactivate(UUID id) {
        Item item = findItem(id);
        item.inactivate();
        itemRepository.save(item);
    }

    public void activate(UUID id) {
        Item item = findItem(id);
        item.activate();
        itemRepository.save(item);
    }

    private Item findItem(UUID id) {
        return itemRepository.findById(id).orElseThrow(() -> new ItemException("Item nao encontrado"));
    }

    private ItemResult toResult(Item item) {
        return new ItemResult(item.id(), item.name(), item.price().value(), item.status().name());
    }
}
```

Note que `ItemManagementUseCase` não tem nenhuma anotação Spring — é POJO puro,
testável sem `ApplicationContext`. O wiring acontece na camada `infrastructure`.

## Camada `infrastructure`

```java
// infrastructure/persistence/ItemDocument.java
package com.company.service.infrastructure.persistence;

import com.company.service.domain.model.Item;
import com.company.service.domain.model.ItemStatus;
import java.math.BigDecimal;
import java.util.UUID;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Document("items")
class ItemDocument {

    @Id
    private String id;
    @Indexed
    private String name;
    private BigDecimal price;
    @Indexed
    private ItemStatus status;

    static ItemDocument fromDomain(Item item) {
        ItemDocument document = new ItemDocument();
        document.id = item.id().toString();
        document.name = item.name();
        document.price = item.price().value();
        document.status = item.status();
        return document;
    }

    Item toDomain() {
        return Item.restore(UUID.fromString(id), name, price, status);
    }
}
```

```java
// infrastructure/persistence/MongoItemRepository.java
package com.company.service.infrastructure.persistence;

import com.company.service.application.port.ItemRepository;
import com.company.service.domain.model.Item;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

@Repository
class MongoItemRepository implements ItemRepository {

    private final MongoTemplate mongoTemplate;

    MongoItemRepository(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    @Override
    public void save(Item item) {
        mongoTemplate.save(ItemDocument.fromDomain(item));
    }

    @Override
    public Optional<Item> findById(UUID id) {
        return Optional.ofNullable(mongoTemplate.findById(id.toString(), ItemDocument.class))
            .map(ItemDocument::toDomain);
    }

    @Override
    public List<Item> findAll() {
        return mongoTemplate.find(new Query().with(Sort.by(Sort.Direction.ASC, "name")), ItemDocument.class)
            .stream()
            .map(ItemDocument::toDomain)
            .toList();
    }
}
```

```java
// infrastructure/config/ItemBeansConfiguration.java
package com.company.service.infrastructure.config;

import com.company.service.application.port.ItemRepository;
import com.company.service.application.usecase.ItemManagementUseCase;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class ItemBeansConfiguration {

    @Bean
    ItemManagementUseCase itemManagementUseCase(ItemRepository itemRepository) {
        return new ItemManagementUseCase(itemRepository);
    }
}
```

`@Indexed` em `name` e `status` porque são os campos de filtro/ordenação mais
prováveis — ajuste conforme as queries reais do seu serviço (`mongodb.md`).

## Camada `interfaces`

```java
// interfaces/rest/ItemController.java
package com.company.service.interfaces.rest;

import com.company.service.application.command.RegisterItemCommand;
import com.company.service.application.command.UpdateItemCommand;
import com.company.service.application.dto.ItemResult;
import com.company.service.application.usecase.ItemManagementUseCase;
import java.math.BigDecimal;
import java.net.URI;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/items")
class ItemController {

    private final ItemManagementUseCase itemManagementUseCase;

    ItemController(ItemManagementUseCase itemManagementUseCase) {
        this.itemManagementUseCase = itemManagementUseCase;
    }

    @PostMapping
    ResponseEntity<ItemResult> register(@RequestBody ItemRequest request) {
        ItemResult result = itemManagementUseCase.register(new RegisterItemCommand(request.name(), request.price()));
        return ResponseEntity.created(URI.create("/api/v1/items/" + result.id())).body(result);
    }

    @GetMapping
    ResponseEntity<List<ItemResult>> list() {
        return ResponseEntity.ok(itemManagementUseCase.list());
    }

    @GetMapping("/{id}")
    ResponseEntity<ItemResult> findById(@PathVariable UUID id) {
        return ResponseEntity.ok(itemManagementUseCase.findById(id));
    }

    @PutMapping("/{id}")
    ResponseEntity<ItemResult> update(@PathVariable UUID id, @RequestBody ItemRequest request) {
        return ResponseEntity.ok(itemManagementUseCase.update(id, new UpdateItemCommand(request.name(), request.price())));
    }

    @PatchMapping("/{id}/inactivate")
    ResponseEntity<Void> inactivate(@PathVariable UUID id) {
        itemManagementUseCase.inactivate(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/activate")
    ResponseEntity<Void> activate(@PathVariable UUID id) {
        itemManagementUseCase.activate(id);
        return ResponseEntity.noContent().build();
    }

    record ItemRequest(String name, BigDecimal price) {
    }
}
```

```java
// interfaces/rest/ItemExceptionHandler.java
package com.company.service.interfaces.rest;

import com.company.service.application.usecase.ItemException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
class ItemExceptionHandler {

    @ExceptionHandler({ItemException.class, IllegalArgumentException.class})
    ResponseEntity<ErrorResponse> handleBusinessException(RuntimeException exception) {
        HttpStatus status = "Item nao encontrado".equals(exception.getMessage()) ? HttpStatus.NOT_FOUND : HttpStatus.BAD_REQUEST;
        return ResponseEntity.status(status).body(new ErrorResponse(errorCode(exception.getMessage()), exception.getMessage()));
    }

    private String errorCode(String message) {
        return switch (message) {
            case "Item nao encontrado" -> "ITEM_NOT_FOUND";
            case "Nome e obrigatorio" -> "ITEM_NAME_REQUIRED";
            case "Valor e obrigatorio" -> "MONEY_REQUIRED";
            case "Valor nao pode ser negativo" -> "MONEY_NEGATIVE";
            default -> "VALIDATION_ERROR";
        };
    }

    record ErrorResponse(String code, String message) {
    }
}
```

O formato de erro (`code` + `message`) segue `.ai/structure/rules/api-contracts.md`.
Controller e handler são `class`/`record` package-private — não há motivo para
serem `public` fora do pacote `interfaces.rest`.

## Testes

```java
// test/domain/model/ItemTest.java
package com.company.service.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class ItemTest {

    @Test
    void shouldRegisterActiveItemWhenDataIsValid() {
        Item item = Item.register("Item A", new BigDecimal("10.00"));

        assertThat(item.id()).isNotNull();
        assertThat(item.name()).isEqualTo("Item A");
        assertThat(item.price().value()).isEqualByComparingTo("10.00");
        assertThat(item.status()).isEqualTo(ItemStatus.ATIVO);
    }

    @Test
    void shouldRejectBlankName() {
        assertThatThrownBy(() -> Item.register(" ", new BigDecimal("10.00")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Nome e obrigatorio");
    }

    @Test
    void shouldRejectNegativePrice() {
        assertThatThrownBy(() -> Item.register("Item", new BigDecimal("-0.01")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Valor nao pode ser negativo");
    }

    @Test
    void shouldInactivateAndReactivateItem() {
        Item item = Item.register("Item", new BigDecimal("10.00"));

        item.inactivate();
        assertThat(item.status()).isEqualTo(ItemStatus.INATIVO);

        item.activate();
        assertThat(item.status()).isEqualTo(ItemStatus.ATIVO);
    }
}
```

```java
// test/application/usecase/ItemManagementUseCaseTest.java
package com.company.service.application.usecase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.company.service.application.command.RegisterItemCommand;
import com.company.service.application.command.UpdateItemCommand;
import com.company.service.application.dto.ItemResult;
import com.company.service.application.port.ItemRepository;
import com.company.service.domain.model.Item;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ItemManagementUseCaseTest {

    private final InMemoryItemRepository repository = new InMemoryItemRepository();
    private final ItemManagementUseCase useCase = new ItemManagementUseCase(repository);

    @Test
    void shouldRegisterItem() {
        ItemResult result = useCase.register(new RegisterItemCommand("Item", new BigDecimal("10.00")));

        assertThat(result.id()).isNotNull();
        assertThat(result.status()).isEqualTo("ATIVO");
        assertThat(repository.findById(result.id())).isPresent();
    }

    @Test
    void shouldRejectUnknownItemWhenUpdating() {
        UUID id = UUID.randomUUID();

        assertThatThrownBy(() -> useCase.update(id, new UpdateItemCommand("Item", new BigDecimal("10.00"))))
            .isInstanceOf(ItemException.class)
            .hasMessage("Item nao encontrado");
    }

    private static class InMemoryItemRepository implements ItemRepository {

        private final List<Item> items = new ArrayList<>();

        @Override
        public void save(Item item) {
            items.removeIf(current -> current.id().equals(item.id()));
            items.add(item);
        }

        @Override
        public Optional<Item> findById(UUID id) {
            return items.stream().filter(item -> item.id().equals(id)).findFirst();
        }

        @Override
        public List<Item> findAll() {
            return items;
        }
    }
}
```

Repare no padrão de teste exigido por `tdd.md`: **nenhum mock de domínio** — o
teste de use case usa um repositório fake em memória, não Mockito. Mockito fica
reservado para dependências técnicas de infraestrutura, não para o próprio
agregado.

## `infra/Dockerfile`

```dockerfile
# ── Estágio 1: build ──────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21-alpine AS build
WORKDIR /workspace
COPY pom.xml .
COPY services/item-service/ services/item-service/
RUN mvn -pl services/item-service dependency:go-offline -q
RUN mvn -pl services/item-service package -DskipTests -q

# ── Estágio 2: runtime ────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=build /workspace/services/item-service/target/*.jar app.jar
USER appuser
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

Padrão completo (compose, nginx, variáveis obrigatórias) em `.ai/structure/rules/docker.md`.

## Checklist de adaptação para um serviço real

- [ ] Renomear `Item`/`item` para o agregado real do bounded context.
- [ ] Trocar `com.company.service` pelo pacote real (`com.<empresa>.<servico>`).
- [ ] Ajustar campos e invariantes do agregado para a regra de negócio real.
- [ ] Definir índices Mongo pelas queries reais, não só por convenção (`mongodb.md`).
- [ ] Adicionar autenticação/autorização (`security.md`) — este exemplo não tem.
- [ ] Adicionar correlationId, logs estruturados e métricas (`observability.md`) — este exemplo não tem.
- [ ] Se o agregado tiver CPF, CNPJ, CEP ou telefone, seguir `standard-fields.md`.
- [ ] Preencher `.ai/structure/templates/microservice-template.md` para o serviço real.
- [ ] Registrar bounded context em `.ai/context/bounded-contexts.md`.

## O que este esqueleto deliberadamente não cobre

- Eventos de domínio (veja `.ai/structure/templates/domain-event-template.md`).
- Segurança JWT/headers de gateway (veja `.ai/structure/rules/security.md`).
- Resiliência entre serviços — timeout, retry, circuit breaker (veja `.ai/structure/rules/microservices.md`).
- OpenAPI/Swagger — adicionar `springdoc-openapi` quando o contrato for público.

Manter o exemplo mínimo é intencional: o objetivo é mostrar a forma das camadas,
não resolver todos os cross-cutting concerns de uma vez.
