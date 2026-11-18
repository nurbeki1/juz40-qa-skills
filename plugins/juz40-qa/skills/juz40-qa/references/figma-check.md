# Figma дизайн сверкасы

Figma — **тек оқу**. Мақсат: UI продуктің макет/спекаға сәйкестігін дәлелдеу.
Клиент: `src/figma.ts` (REST, `FIGMA_TOKEN`), немесе Figma MCP (өз логині).

## Командалар

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run figma -- files                      # рөл → fileKey
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run figma -- texts  <role|fileKey> <nodeId>
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run figma -- export <role|fileKey> <nodeId> [out.png]
```

`role` ∈ student | curator | methodist | headteacher | admin (немесе 22-таңбалы
fileKey). `nodeId` — Confluence спекасындағы «Дизайн» сілтемесінен
(`?node-id=123-456` → `123-456` немесе `123:456`, автонормализация).

## Процедура (арзаннан қымбатқа)

### 1. Дизайн сілтемесін **спекадан** ал

Есте сақтаудан/іздеуден алуға тыйым. Спекада сілтеме жоқ болса — бұл
**product gap**: PM-ге сұрақ («Продукт» арнасы), өзің макет іздеп кетпе.

### 2. Мәтін сверкасы — БІРІНШІ (детерминды, арзан)

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run figma -- texts student 123-456
```

→ тірі беттің мәтіндерімен салыстыр (Playwright DOM). i18n, copy, батырма
атауы, реттілік, қазақша/орысша айырмасы — **суретсіз** табылады. Практикада
айырма көбінесе осы жерден шығады.

### 3. Содан кейін визуал

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run figma -- export student 123-456 /tmp/figma-x.png
```

+ Playwright скриншоты → екеуін де `Read` жасап **құрылымдық** салыстыр:
элемент бар/жоқ, күй (disabled/empty/error), иерархия, реттілік, layout.

⚠️ **Pixel-perfect салыстыру ЕМЕС.** Шрифт рендері, anti-aliasing, динамикалық
дата үнемі өзгереді. Пиксель регрессиясы — басқа механизм:

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run visual:compare  -- <reference.png> <actual.png> [diff.png] [maxDiffRatio]
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run visual:baseline -- <init|compare|approve|mask> DV-KEY screen variant [png]
```

Ол Playwright скриншоты ↔ бекітілген baseline (маска + approval) үшін,
Figma ↔ прод үшін емес.

### 4. Вердикт дисциплинасы

| Жағдай | Вердикт |
|---|---|
| Спека + Figma келіседі, прод басқаша | **PRODUCT_BUG** → `[Bug][Front][Visual\|A11y\|Responsive]` |
| Спека мен Figma бір-біріне қарсы | **UNKNOWN** → эскалация (екеуі бірдей авторитетті) |
| Figma ескі, прод жаңа спека бойынша | баг емес → дизайнерге/PM-ге сигнал |
| Тек эстетика («ұнамайды») | баг емес — тексерілетін oracle жоқ |

### 5. Evidence

Баг есебіне: Figma node URL-і, экспорт PNG жолы, тірі скриншот, viewport,
Playwright командасы. Контракт бойынша кемінде бір тірі HTTPS сілтеме міндетті.

## MCP нұсқасы

Figma MCP (`get_design_context`, `get_screenshot`, `get_variable_defs`) токен
талап етпейді және дизайн токендерін (түс/spacing/өлшем) береді — адам
сессиясында артығырақ. Бірақ CI-да жүрмейді, сондықтан REST жолы қалады:
қайсысы қолжетімді — соны қолдан, таңдауыңды есепте жаз.

## Шектеулер

- Figma-ға жазу, комментарий қалдыру, макетті өзгерту — **ТЫЙЫМ**.
- Дизайнды «мақұлдау» skill-дің құзыретінде емес.
- Экспорт PNG дискіге жазылады — орын жоқ болса алдымен тазалау керек.
