# Mobile Reference: Feature Ionic Angular ("Items")

Este documento é a referência mínima de uma feature Ionic Angular seguindo
`.ai/structure/rules/ionic.md` e `.ai/structure/rules/frontend-state.md`. É uma
versão simplificada e generalizada de uma feature real em produção
(`products`, do app mobile do AgendaHub), com os campos específicos de negócio
removidos e renomeada para `items` para ficar domain-agnostic.

Use isto como ponto de partida ao criar uma feature nova em
`apps/mobile-app/src/app/features/<nome-da-feature>/`.

## Regras aplicadas

- `.ai/structure/rules/ionic.md` — estrutura de pastas, lazy loading, estado.
- `.ai/structure/rules/frontend-state.md` — estado de feature vs. estado global.
- `.ai/structure/rules/i18n.md` — tradução obrigatória de todo texto visível.
- `.ai/structure/rules/testing.md` — testes de componente e service.
- `.ai/structure/rules/standard-fields.md` — quando a feature real tiver CPF, CNPJ, CEP ou telefone (o exemplo `items` não tem).

## Estrutura de pastas

```text
apps/mobile-app/src/app/
├── core/
│   └── i18n/
│       ├── translations.ts        # chaves pt-BR / en-US
│       └── translate.pipe.ts
├── data-access/
│   ├── api/
│   │   ├── api-error.ts           # extrai code/message do erro padrao do backend
│   │   └── item-api.service.ts
│   └── models/
│       └── item.models.ts
└── features/
    └── items/
        ├── items.page.ts
        └── items.page.html
```

Estado local (aba selecionada, modal aberto) fica no componente. Estado de
feature (lista de items, formulário) fica no próprio `ItemsPage`/service da
feature — não vira store global sem justificativa (`frontend-state.md`).

## `data-access/models/item.models.ts`

```typescript
export interface ItemRequest {
  name: string;
  price: number;
}

export interface ItemResult {
  id: string;
  name: string;
  price: number;
  status: 'ATIVO' | 'INATIVO';
}
```

## `data-access/api/api-error.ts`

```typescript
import { HttpErrorResponse } from '@angular/common/http';

interface ApiErrorBody {
  code?: string;
  message: string;
}

export function getApiErrorMessage(
  error: unknown,
  fallback: string,
  translate?: (key: string) => string
): string {
  if (error instanceof HttpErrorResponse && hasApiErrorBody(error.error)) {
    if (error.error.code && translate) {
      const translated = translate(`errors.${error.error.code}`);
      if (translated !== `errors.${error.error.code}`) {
        return translated;
      }
    }
    return error.error.message;
  }
  return fallback;
}

function hasApiErrorBody(value: unknown): value is ApiErrorBody {
  return typeof value === 'object' && value !== null && 'message' in value && typeof value.message === 'string';
}
```

Este helper traduz o `code` estável do backend (`api-contracts.md`) por uma
chave `errors.CODE`, com fallback seguro para `message` — nunca cria lógica de
UI baseada no texto humano da mensagem (`i18n.md`).

## `data-access/api/item-api.service.ts`

```typescript
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ItemRequest, ItemResult } from '../models/item.models';

@Injectable({ providedIn: 'root' })
export class ItemApiService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiBaseUrl;

  listItems(): Observable<ItemResult[]> {
    return this.http.get<ItemResult[]>(`${this.baseUrl}/items`);
  }

  registerItem(request: ItemRequest): Observable<ItemResult> {
    return this.http.post<ItemResult>(`${this.baseUrl}/items`, request);
  }

  updateItem(id: string, request: ItemRequest): Observable<ItemResult> {
    return this.http.put<ItemResult>(`${this.baseUrl}/items/${encodeURIComponent(id)}`, request);
  }

  inactivateItem(id: string): Observable<void> {
    return this.http.patch<void>(`${this.baseUrl}/items/${encodeURIComponent(id)}/inactivate`, {});
  }

  activateItem(id: string): Observable<void> {
    return this.http.patch<void>(`${this.baseUrl}/items/${encodeURIComponent(id)}/activate`, {});
  }
}
```

Nenhum componente deve chamar `HttpClient` diretamente — sempre por este
service tipado (`ionic.md`).

## `features/items/items.page.ts`

```typescript
import { ChangeDetectionStrategy, ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { IonicModule } from '@ionic/angular';
import { finalize } from 'rxjs';

import { getApiErrorMessage } from '../../data-access/api/api-error';
import { ItemApiService } from '../../data-access/api/item-api.service';
import { ItemRequest, ItemResult } from '../../data-access/models/item.models';
import { LanguageService } from '../../core/i18n/language.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  standalone: true,
  imports: [IonicModule, ReactiveFormsModule, TranslatePipe],
  templateUrl: './items.page.html',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class ItemsPage implements OnInit {
  private readonly fb = inject(NonNullableFormBuilder);
  private readonly itemApi = inject(ItemApiService);
  private readonly cdr = inject(ChangeDetectorRef);
  private readonly languageService = inject(LanguageService);

  readonly form = this.fb.group({
    name: ['', [Validators.required]],
    price: [0, [Validators.required, Validators.min(0)]]
  });

  items: ItemResult[] = [];
  editingItemId: string | null = null;
  isLoading = false;
  isSubmitting = false;
  errorMessage = '';
  successMessage = '';

  ngOnInit(): void {
    this.loadItems();
  }

  loadItems(): void {
    this.errorMessage = '';
    this.isLoading = true;
    this.itemApi.listItems()
      .pipe(finalize(() => {
        this.isLoading = false;
        this.cdr.markForCheck();
      }))
      .subscribe({
        next: (items) => (this.items = items),
        error: (error: unknown) => {
          this.errorMessage = getApiErrorMessage(error, this.translate('items.loadError'), (key) => this.translate(key));
        }
      });
  }

  edit(item: ItemResult): void {
    this.editingItemId = item.id;
    this.successMessage = '';
    this.errorMessage = '';
    this.form.setValue({ name: item.name, price: item.price });
  }

  cancelEdit(): void {
    this.editingItemId = null;
    this.form.reset({ name: '', price: 0 });
  }

  submit(): void {
    this.errorMessage = '';
    this.successMessage = '';
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const request: ItemRequest = this.form.getRawValue();
    const operation = this.editingItemId
      ? this.itemApi.updateItem(this.editingItemId, request)
      : this.itemApi.registerItem(request);

    this.isSubmitting = true;
    operation
      .pipe(finalize(() => {
        this.isSubmitting = false;
        this.cdr.markForCheck();
      }))
      .subscribe({
        next: () => {
          this.successMessage = this.editingItemId ? this.translate('items.savedUpdated') : this.translate('items.savedCreated');
          this.cancelEdit();
          this.loadItems();
        },
        error: (error: unknown) => {
          this.errorMessage = getApiErrorMessage(error, this.translate('items.saveError'), (key) => this.translate(key));
        }
      });
  }

  inactivate(item: ItemResult): void {
    this.itemApi.inactivateItem(item.id).subscribe({
      next: () => {
        this.successMessage = this.translate('items.inactivated');
        this.loadItems();
      },
      error: (error: unknown) => {
        this.errorMessage = getApiErrorMessage(error, this.translate('items.inactivateError'), (key) => this.translate(key));
        this.cdr.markForCheck();
      }
    });
  }

  trackByItemId(_: number, item: ItemResult): string {
    return item.id;
  }

  private translate(key: string): string {
    return this.languageService.translate(key);
  }
}
```

## `features/items/items.page.html` (estrutura mínima de estados)

```html
<ion-header>
  <ion-toolbar>
    <ion-title>{{ 'items.title' | translate }}</ion-title>
  </ion-toolbar>
</ion-header>

<ion-content>
  <!-- loading -->
  <ion-spinner *ngIf="isLoading"></ion-spinner>

  <!-- error -->
  <ion-text color="danger" *ngIf="errorMessage">{{ errorMessage }}</ion-text>

  <!-- success -->
  <ion-text color="success" *ngIf="successMessage">{{ successMessage }}</ion-text>

  <!-- empty -->
  <ion-text *ngIf="!isLoading && items.length === 0">{{ 'items.empty' | translate }}</ion-text>

  <!-- success com dados -->
  <ion-list *ngIf="!isLoading && items.length > 0">
    <ion-item *ngFor="let item of items; trackBy: trackByItemId">
      <ion-label>{{ item.name }} — {{ item.price | currency }}</ion-label>
      <ion-badge [color]="item.status === 'ATIVO' ? 'success' : 'medium'">{{ item.status }}</ion-badge>
    </ion-item>
  </ion-list>

  <form [formGroup]="form" (ngSubmit)="submit()">
    <ion-input formControlName="name" [label]="'items.name' | translate"></ion-input>
    <ion-input formControlName="price" type="number" [label]="'items.price' | translate"></ion-input>
    <ion-button type="submit" [disabled]="isSubmitting">{{ 'common.save' | translate }}</ion-button>
  </form>
</ion-content>
```

Os 4 estados obrigatórios de `frontend-state.md` — **loading, empty, success,
error** — estão todos representados. Nenhum texto visível está hardcoded; tudo
passa por `| translate` (`i18n.md`).

## `core/i18n/translations.ts` (chaves da feature)

```typescript
export const TRANSLATIONS: Record<'pt-BR' | 'en-US', Record<string, string>> = {
  'pt-BR': {
    'items.title': 'Itens',
    'items.name': 'Nome',
    'items.price': 'Preço',
    'items.empty': 'Nenhum item cadastrado.',
    'items.loadError': 'Não foi possível carregar os itens.',
    'items.saveError': 'Não foi possível salvar o item.',
    'items.savedCreated': 'Item criado com sucesso.',
    'items.savedUpdated': 'Item atualizado com sucesso.',
    'items.inactivateError': 'Não foi possível inativar o item.',
    'items.inactivated': 'Item inativado.'
  },
  'en-US': {
    'items.title': 'Items',
    'items.name': 'Name',
    'items.price': 'Price',
    'items.empty': 'No items registered.',
    'items.loadError': 'Could not load items.',
    'items.saveError': 'Could not save item.',
    'items.savedCreated': 'Item created successfully.',
    'items.savedUpdated': 'Item updated successfully.',
    'items.inactivateError': 'Could not inactivate item.',
    'items.inactivated': 'Item inactivated.'
  }
};
```

## Teste de componente (`items.page.spec.ts`) — esqueleto

```typescript
describe('ItemsPage', () => {
  it('should load items and expose them for the template', () => {
    // arrange: mock ItemApiService.listItems() com of([...])
    // act: chamar ngOnInit()
    // assert: expect(component.items).toEqual([...])
  });

  it('should show error message when loading fails', () => {
    // arrange: mock listItems() com throwError(...)
    // act / assert: expect(component.errorMessage).not.toBe('')
  });
});
```

Cenários mínimos exigidos por `testing.md`: sucesso, erro, e — quando a feature
tiver formulário — validação. E2E só é obrigatório para fluxos principais como
login e pedido (`testing.md`), não para toda feature CRUD.

## Checklist de adaptação para uma feature real

- [ ] Renomear `items`/`Item` para o conceito real da feature.
- [ ] Trocar os campos do formulário e do `*Request`/`*Result` pelos reais.
- [ ] Adicionar `AuthSessionService`/guarda de permissão se a feature exigir papel específico.
- [ ] Se algum campo for CPF, CNPJ, CEP ou telefone, aplicar máscara e validação de `standard-fields.md`.
- [ ] Registrar a rota com lazy loading no roteador do app (`ionic.md`).
- [ ] Adicionar todas as chaves de tradução em `pt-BR` e `en-US` antes de abrir PR (`i18n.md`).

## O que este esqueleto deliberadamente não cobre

- Autenticação/guarda de rota (veja `core/auth/auth.guard.ts` no projeto real).
- Máscaras de campo (CPF/CNPJ/CEP/telefone) — veja `standard-fields.md`.
- Paginação ou busca — a lista aqui é simples e completa em uma página.
- Upload de imagem ou campos ricos além de texto/número.
