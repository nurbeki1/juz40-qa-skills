# Спекадан тест-кейс шығару

Нәтиже: Confluence-те жарияланған, спеканың әр талабына трассирленген
executable тест-кейс парағы. Канондық шектеулер: `docs/test-case-quality.md`,
`docs/adr-grounded-testcase-compiler.md`.

## Шекара (ең маңызды)

Модель **артефакт жобалайды**, Node **валидациялап жариялайды**.
Confluence-ке қолмен жазуға, модельдің шығысын тікелей парақ қылуға тыйым.

## Процедура

### 1. Дереккөзді толық жина (discovery)

- Jira Story description + ішіндегі БАРЛЫҚ сілтеме
- негізгі Confluence Story құжаты + **балалық** беттер
- талаптар бөлініп кетсе — релевант sibling беттер
- бар болса Story-дың қазіргі тест-кейс парағы
- Jira subtask-тар және олардың типі/статусы → қажетті QA layer-лер

**Дайын спека белгісі:** Jira `Done` болуы, дизайн болуы немесе ұқсас парақ
болуы — дәлел ЕМЕС. Source құжатта frozen/ready маркері жоқ болса — **ТОҚТА**,
PM-ге сұрақ.

### 2. Бар парақты тап (дубль қаупі)

- Story-ға **дәл** сәйкестікті іздеу (тақырып ұқсастығы жеткіліксіз)
- 0 парақ → жаңа suite; 1 парақ → update target; **2+ → конфликт, ТОҚТА**

### 3. Grounding жина

[grounding.md](grounding.md) — API probe + backend DTO/enum/валидация + керек
болса БД. Күтілетін мәндер **спекадан** алынады (бизнес мәні), форма —
**фактіден**. Екеуі қайшы болса → `UNKNOWN`, эскалация.

### 4. Кейстерді жобала — міндетті техникалар

Барлығы болуы керек (жоқ болса валидация құлайды):

- positive / happy path
- negative валидация және қате кодтарының маппингі
- boundary / equivalence
- RBAC, ownership, IDOR
- state transitions, idempotency/concurrency, релевант болса timezone
- regression scope
- пайдаланушы мінезі үшін UI/E2E flow

Әр кейсте: `preconditions`, `steps`, `expected`, рөл, тип (`api|ui|both`),
`businessValues` (спекадан), `volatileData` (API-дан алынатын id/ағымдар),
priority. Спека толық емес жерде **ойдан шығармай** `openQuestions`-қа жаз.

Промпт форматы: `agent/prompts/spec-to-testcases.md`.

### 5. Жариялау (детерминды)

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run write-testcases
```

Жарияламас бұрын Node тексереді:

- спеканың әр талабы кемінде бір TC-мен жабылған
- әр TC-де preconditions + steps + expected бар
- сілтемелер мен endpoint-тер grounding pack-тен (ойдан шығарылмаған)
- міндетті техникалар бар
- coverage matrix-те бейтаныс rule/TC id жоқ

Renderer шығарады: негізгі executable кесте + coverage matrix + grounding
report/signature → Confluence storage XHTML.

> `coverage matrix` — «спека талабы → TC» трассировкасы. Ол **орындалатын
> кейстер тізімі емес**; coverage есебі тек негізгі кестеден оқылады.

### 6. Ескірген парақты жаңарту (stale update)

Lossless merge: талаптар мен кейстер жаңартылады, бар жолдардың **тарихи
execution нәтижелері сақталады**. Парақты қайта жасап, тарихты жоюға тыйым.

### 7. Қорытынды

- Confluence URL-ін Confluence жауабынан ал (қолмен құрастырма)
- Қалған `openQuestions` → PM-ге сұрақ ретінде шығар
- Mobile scope болса — handoff деп белгіле, «жабылды» деп айтпа

## Тоқтау шарттары

| Жағдай | Әрекет |
|---|---|
| Frozen/ready маркері жоқ | ТОҚТА, PM-ге сұрақ |
| 2+ үміткер парақ | ТОҚТА, конфликт |
| Спека мен факт қайшы | `UNKNOWN`, эскалация |
| Валидация құлады | Артефактты түзет, gate-ті жеңілдетпе |
