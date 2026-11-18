# Препродта тексеру және QA жабу

Кезекшінің негізгі процедурасы. Нәтиже: run/commit/парақ нұсқасына байланған
evidence + «жабуға бола ма» деген нақты жауап. Канон: `docs/AGENT-FUNCTIONS.md`
§7–8, `docs/QA-REPORTING-CONTRACT.md`.

## 0. Кіріс

DV кілті керек. Жоқ болса — **сұра**, өзің таңдама.

## 1. Scope анықта

Jira subtask-тардан:

| Белгі | Қажет evidence |
|---|---|
| `[BACK]` | API evidence |
| `[FRONT]` | UI evidence |
| `[MOBILE]` / `[FLUTTER]` | қолмен mobile handoff + full-QA claim **блокталады** |
| бұлыңғыр | **ТОҚТА** — бар spec файлдарына қарап болжама |

## 2. Орта дайындығы

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run readiness:diagnose
```

Толық оқу: [env-readiness.md](env-readiness.md). `credential` / `test` /
`product` / `spec` / `unknown` категориясы — **fail-closed**, retry жоқ.

## 3. Детерминды gate + runtime

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:full -- DV-XXXX
```

Немесе қадамдап: [quality-gates.md](quality-gates.md) → содан кейін

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run verify-feature -- DV-XXXX
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run verify-feature -- DV-XXXX --file tests/ui/...  # нақты файл
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run verify-feature -- DV-XXXX --check              # қайта жүгірмей тексеру
```

`--check` тесттерді **қайта жүгіртпейді**, ағымдағы run нәтижесін валидациялайды.

## 4. Evidence нені байлайды

`runId` · Story · `preprod` ортасы · тест репосының commit SHA ·
Confluence тест-кейс парағының нұсқасы · файл/scope · TC · layer · статус ·
retry/flaky ақпараты. **TTL әдепкі 120 минут** — ескі evidence-пен жабуға
болмайды (адамға да қатысты).

## 5. Completion gate — бәрі бірден орындалуы керек

QA subtask-ты жабу және «толық тексерілді» деу тек мыналар қатар болғанда:

- [ ] бір **дәл** тест-кейс парағы (дубль жоқ)
- [ ] coverage complete
- [ ] қажетті API/UI layer-лер орындалған
- [ ] oracle және test-data gate өткен
- [ ] evidence ағымдағы run / commit / парақ нұсқасына және `preprod`-қа тиесілі
- [ ] кемінде бір passed тест бар
- [ ] `failed=0`, `skipped=0`, `flaky=0`
- [ ] әр автоматталған TC-де passed evidence бар
- [ ] mobile scope жоқ

Біреуі орындалмаса → `PARTIAL`. Ағымдағы run-дағы **бір retry-pass те** жабуды
блоктайды. Мәтінмен «бәрі жақсы» деп айтып gate-ті айналып өтуге тыйым.

## 6. Құлаған тест болса

Автоматты «қайта жүгіртіп көрейін» жоқ. [triage.md](triage.md) →
вердикт → керек болса [bug-report.md](bug-report.md).

Readiness өткеннен кейінгі assertion, coverage, skipped/flaky, product және
`UNKNOWN` құлауы **қайталанбайды** — олар fail-closed эскалация.

## 7. Есеп

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:report -- validate <report.json>
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:report -- render   <report.json>
```

Allure: `qa:full` өзі generate/validate/deploy жасайды; жеке керек болса
`npm run report:generate` → `npm run report:deploy`.

Жіберу — адамның растауымен. Қорытындыда міндетті: не тексерілді, қай gate,
қай evidence URL, **не тексерілмеді және неге**.

## Тоқтау шарттары

| Жағдай | Әрекет |
|---|---|
| Орта дайын емес (fail-closed) | ТОҚТА, [env-readiness.md](env-readiness.md) |
| Scope бұлыңғыр | ТОҚТА, Jira-ны нақтылауды сұра |
| Mobile scope бар | web бөлігін жаз, mobile handoff, «толық» демейсің |
| Evidence TTL өтті | қайта жүгірт, ескісімен жаппа |
| Бір retry-pass бар | `PARTIAL`, flaky деп тіркеу |
