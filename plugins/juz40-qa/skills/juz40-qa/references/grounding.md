# Grounding — болжам емес, ФАКТ бойынша жұмыс істеу

Бұл барлық процедураның негізі. Спека ниетті сипаттайды; код пен тірі жүйе —
шындық. Екеуінің арасындағы айырма — дәл баг тұратын жер. **Жауаптың формасын,
өрістің мәнін, статус-кодты немесе контрактты ойдан шығаруға тыйым. Тексер.**

Канондық мәтін: `agent/skills/grounding.md`.

## Қашан міндетті

- Кез келген тест-кейс немесе автотест жазудан **бұрын**.
- Әр құлаған тестті триаж жасағанда — **вердикт шығарғанға дейін**.
- «API шынымен осылай ма» деп өзіңмен таласқанда — болжамай, дёрни.

## Үш дереккөз (арзаннан қымбатқа)

### 1. Тірі API — бірінші рефлекс

```bash
cd "$TEST_REPO_PATH/playwright"
scripts/ground.sh <METHOD> <path> [role]
scripts/ground.sh GET /v1/student/payments student
```

Нақты көр: өріс аттары, типтер, nesting, null-дар, қате кодтары, құқық кодтары
(401/403). Нәтижені кейс/спека басына «сверено curl <env> <дата>» деп жаз.

### 2. Продукт коды (read-only клондар) — контракт кодтан

```bash
grep -rn "<endpoint|өріс|enum>" "$CONTEXT_BACKEND/src"
```

- `$CONTEXT_BACKEND` (juz40) — контроллер/сервис/DTO/enum/валидация/статус/feature-флаг
- `$CONTEXT_FRONTEND` (juz40-front) — селектор/мәтін/роут
- `$CONTEXT_MOBILE` (juz40-mobile) — мобайл

Спека бұлыңғыр болса код дәлірек. Кодта жоқ мінез-құлыққа тест жазба.
**Тек оқу — коммит/пуш ЖОҚ.** Клон жоқ болса (`auth:check` SKIP берсе) —
API probe-пен шектел және белгісіздікті ашық жаз.
Метадеректерді жаңарту: `npm run sync-context`.

### 3. Read-only БД — күйдің ground truth-ы

```bash
scripts/ground-db.sh "select score, max_score from question_progress where submission_id='...'"
```

API жауабы жеткіліксіз болғанда («шынымен не жазылды?»). Тек оқу, тек
staging/preprod, `AGENT_DB_URL` керек. Жоқ болса қадам скипается.

## Қосымша дереккөздер

- **Jira/Confluence** — business intent, acceptance criteria.
- **Figma** — дизайн күйі және UI мәтіні → [figma-check.md](figma-check.md).
- **Read-only Elastic** — requestId, 5xx, stacktrace (`ELASTIC_URL` болса).

## Ереже

Қолжетімсіз optional дереккөзді **болжаммен алмастырмайды**. Қалған
дереккөздермен жалғастыр; бірақ онсыз сенімді вердикт шықпайтын болса —
completion-ды блоктап, адамға эскалация жаса (`UNKNOWN`).
