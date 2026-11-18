---
name: juz40-qa
description: >
  Juz40 QA/AQA процедуралары: Confluence спекасынан тест-кейс жазу, Playwright
  автотест жазу, препродта тексеру және QA жабу, құлаған тестті триаж жасау,
  Jira баг ашу, coverage/oracle/test-data gate-терін тексеру, Figma дизайн
  сверкасы, препрод ортасының дайындығын диагностикалау, кезекшілік/дейлик есебі.
  Use when working a DV- Jira story as QA or AQA — writing or updating test cases
  from a spec, writing or repairing Playwright API/UI tests, verifying a feature on
  preprod, closing a QA subtask, triaging a failed test, filing a product bug,
  auditing test quality gates, comparing UI against a Figma design, diagnosing a
  broken preprod environment, or preparing a duty report. Триггерлер: "тест-кейс
  жаз", "спекадан кейс шығар", "препродта тексер", "QA жаб", "тест құлады",
  "баг аш", "дизайнмен салыстыр", "препрод сынды", "кезекшілік есебі", DV-XXXX.
---

# Juz40 QA — процедуралар жинағы

Бұл skill Agent 007 орындайтын QA/AQA жұмысын **адам басқаратын** нұсқаға
көшіреді. Барлық сапа тексерісі (gate) бұрынғыдай детерминды Node командалары
арқылы жүреді — skill оларды қайта жазбайды, шақырады. Канондық мінез-құлық:
`docs/AGENT-FUNCTIONS.md`.

---

## 0-қадам: авторизация (МІНДЕТТІ, өткізіп жіберуге болмайды)

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run auth:check
# күмән болса немесе токен ескірген сияқты болса:
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run auth:check -- --probe
```

- `AUTH_STATUS: READY` → жалғастыр.
- `AUTH_STATUS: BLOCKED` → **ТОҚТА.** Шығыстағы `→` жолын пайдаланушыға
  көрсет те, кіруін сұра. Браузер логинін мен істей алмаймын — адам `/mcp`
  арқылы немесе `.env` арқылы өзі кіреді. Кіргеннен кейін қайта іске қос.
- Жартылай деректермен жалғастыруға, жоқ дереккөзді болжаумен алмастыруға ТЫЙЫМ.

Толығырақ (қай интеграция кімнің атынан жазады, MCP vs токен):
[references/auth.md](references/auth.md)

---

## 1-қадам: қай процедура керек

| Жағдай / сұраныс | Файл |
|---|---|
| «Бұл фичаға тест-кейс жаз», спека дайын | [references/spec-to-testcases.md](references/spec-to-testcases.md) |
| «Осы кейстерге автотест жаз», TC → Playwright | [references/autotest-write.md](references/autotest-write.md) |
| «Препродта тексер», «QA жабуға бола ма» | [references/preprod-verify.md](references/preprod-verify.md) |
| «Тест құлады», «бұл баг па, тест пе» | [references/triage.md](references/triage.md) |
| «Баг аш», `PRODUCT_BUG` вердикті шықты | [references/bug-report.md](references/bug-report.md) |
| «Ревьюге бергенге дейін тексер», gate аудиті | [references/quality-gates.md](references/quality-gates.md) |
| «Дизайнмен сәйкес пе», UI мәтін/макет сверкасы | [references/figma-check.md](references/figma-check.md) |
| «Препрод сынды», «аккаунт кірмейді», тест ортадан құлап жатыр | [references/env-readiness.md](references/env-readiness.md) |
| Кезекшілік/дейлик есебі, релиз снапшоты | [references/duty-report.md](references/duty-report.md) |
| Кез келген тексеруден бұрын факт керек | [references/grounding.md](references/grounding.md) |

**Grounding — бәрінің астындағы базалық қадам.** Тест-кейс жазу, автотест жазу
және триаж оны оқымай басталмайды.

Кезекші (QA duty) күнделікті тізбегі: `env-readiness` → `preprod-verify` → `duty-report`.

---

## Сұйылтуға БОЛМАЙТЫН ережелер

Бұл ережелер агентте де, skill-де де бірдей. Бұзылса — жұмыс нәтижесі жарамсыз.

1. **Продукт коды, БД, Elastic, Figma — тек оқу.** Ешқашан коммит/пуш жасама.
2. **Gate-ті жеңілдетуге тыйым.** coverage, oracle, test-data, scope, runtime
   evidence — «жасыл болсын» деп әлсіретуге болмайды.
3. **`PRODUCT_BUG`-ты grounding дәлелінсіз `STALE_TEST` қылуға тыйым.**
   Тестті продукт багының астына бейімдеу = багты жасыру, ең ауыр қате.
4. **Mobile scope-ты web арқылы «толық тексерілді» деп жабуға тыйым** — handoff.
5. **Тест өзгерісі тек feature branch + Draft MR.** Skill ешқашан мерж жасамайды
   (агенттегі `AGENT_AUTOMERGE` адамға қатысты емес).
6. **Сыртқы жазуды (Confluence/Jira) renderer арқылы ғана жаса.** Қолмен жазылған
   description, raw Jira POST/PUT — тыйым.
7. **Секретті баспа, чатқа сұрама, репоға жазба.** Тек env атауын айт.
8. **Белгісіздікті болжаумен жаппа.** Дереккөз жоқ/қайшы болса → `UNKNOWN` →
   адамға эскалация.

---

## Ортақ орнату

Екі жолды бір рет орнат (shell профиліне қосуға болады):

```bash
# Агент репосының клоны — gate командалары осы жерден шақырылады
export AGENT_ORCHESTRATOR_PATH="<juz40-aqa-agent007 жолы>"
# Playwright тест репосының клоны
export TEST_REPO_PATH="<juz40-aqa-repo жолы>"
```

Орнатылмаған болса — пайдаланушыдан сұра, болжамай.

Команда шаблоны (қай жерде тұрсаң да жұмыс істейді):

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run <script> -- DV-XXXX
```

Grounding клондарының метадеректерін жаңарту: `npm run sync-context`.

---

## Нәтижені қалай хабарлау

- Telegram/Jira-ға жіберу **әдепкіде жоқ**. Алдымен мәтінді дайында, пайдаланушыға
  көрсет, растағаннан кейін ғана жібер.
- Дейлик есебі: `npm run daily-report -- --dry` (жібермей, тек көрсетеді).
- Қорытындыда міндетті: не тексерілді, қай gate өтті, қай evidence бар,
  не тексерілмей қалды және неге.
