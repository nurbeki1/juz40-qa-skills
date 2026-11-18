# Тест-кейстен Playwright автотест жазу

Нәтиже: feature branch + Draft MR, ішінде `@DV-XXXX` / `@TC-N` маркерленген,
gate-тен өткен тесттер. Канон: `agent/prompts/testcases-to-playwright.md`.

## Алдын ала

1. Тест-кейс парағы бекітілген (`spec-to-testcases.md` аяқталған).
2. [grounding.md](grounding.md) — API формасы, DTO, селектор/мәтін фактілері.
3. Scope Jira-дан: `[BACK]` → API, `[FRONT]` → UI, `[MOBILE]`/`[FLUTTER]` →
   mobile handoff (web-пен жабуға тыйым). Scope бұлыңғыр → **ТОҚТА**.

## Repo ережелері (қатаң)

- TypeScript, ESM (импортта `.js` суффикс), Playwright Test.
- **Барды қайта қолдан**: `src/pages/*` (Page Object), `src/fixtures/*`,
  `src/config/*`. Селекторды дубльдеме — Page Object-ке метод қос.
- Күтілетін мәндер — **спекадағы `businessValues`**, БД-дан алуға болмайды.
- Volatile деректер (ағымдағы ағымдар, id) — API клиент арқылы (`src/api/*`),
  хардкод жоқ.
- Рөл бойынша логин — фикстура арқылы, flow көшірілмейді.
- Селектор: `data-testid` артықшылықты; жоқ болса бар Page Object селекторлары.
- Көп тексеріс → `expect.soft(...)` түсіндірме message-пен.

## Oracle талабы (бұл жерде көп құлайды)

- Positive **API** кейсі: HTTP статустан **бөлек** response schema **және**
  business state/value инварианты. Тек «200 қайтты» жеткіліксіз.
- Positive **mutation**: `.agent007/qa-contracts/<DV-KEY>.json` ішіндегі
  `hooks.postconditionScript` арқылы cleanup-қа ДЕЙІН persistence тексеріледі.
- Grounding маппингі: `.agent007/oracle-contracts/<DV-KEY>.json` —
  requirement → нақты `TC-*` → Jira/Confluence URL + page version/updatedAt
  немесе immutable contract revision. **Тег өздігінен evidence емес.**
- Cross-service flow → `@cross-service` тегі + кемінде екі endpoint/source
  арасындағы consistency assertion.
- UI тест: бақыланатын web нәтижесі болуы керек (мәтін/күй/навигация).

## Test-data тазалығы

- Жасалған дерек retry/run арасында **уникал** болуы керек.
- Сәтті create → `finally`/hook ішінде **кепілді** cleanup.
- Shared entity өзгерсе → restore/rollback.
- Тест соңындағы қарапайым delete кепілді саналмайды.
- `.catch()` ішінде үнсіз cleanup (rethrow жоқ) — блокталады.
- Жазуға жетпей құлауы керек negative mutation-ға cleanup керек емес.

## Құрылым

```
tests/api/<domain>/<name>.spec.ts     # API
tests/ui/<domain>/<name>.spec.ts      # UI E2E
tests/.../<name>.data.ts              # күтілетін деректер
```

## Жазғаннан кейін — міндетті gate

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run coverage           -- DV-XXXX
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run test-quality       -- DV-XXXX
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run independence:audit -- DV-XXXX
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run oracle:audit       -- DV-XXXX
```

Толық түсіндірме: [quality-gates.md](quality-gates.md).

## Commit / MR

```bash
git switch -c feature/DV-XXXX-<қысқа-атау>
git commit -m "test(pw): DV-XXXX <не қосылды> (<TC-N...>)"
```

- Draft MR ашылады, **мерж адамның ісі** — өзіңше мержемейсің.
- Бір MR = бір фича/тапсырма. Қатысы жоқ кодты түртпе.
- MR сипаттамасында: қай TC жабылды, қай gate өтті, қалған `openQuestions`.
