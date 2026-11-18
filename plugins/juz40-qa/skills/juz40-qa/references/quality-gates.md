# Сапа gate-тері — ревьюге бергенге дейінгі аудит

Барлығы LLM-сіз, детерминды. Қымбат preprod run-нан **бұрын** орындалады:
белгілі сапа кемшілігі `PARTIAL` болады да, браузер жүгірмейді.

## Бір командамен бәрі

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:full -- DV-XXXX
```

`qa:full` тізбегі: `coverage` → `test-quality` → `independence:audit` →
`oracle:audit` → (өтсе) `qa:run` → Allure generate → validate → deploy-report →
`qa:check`. Арзан аудиттердің **барлығы** жүреді (біреуі құласа да) — толық
қарыз суреті бірден көрінеді. Exit `4` = `PARTIAL`.

## Жеке-жеке

| Команда | Нені блоктайды |
|---|---|
| `run coverage -- DV-XXXX` | TC ↔ Playwright трассировкасы: missing/extra TC, қай layer жоқ. TC-ID **тек негізгі executable кестеден** оқылады (coverage matrix, архив, коммент — есепке алынмайды). AST арқылы нақты `test()` декларациялары табылады; active / conditional skip / static skip-fixme / manual-only ажыратылады |
| `run test-quality -- DV-XXXX` | assertion-сыз тест; тек HTTP статус тексеретін positive API; acceptance 5xx; success/error статусты бір уақытта қабылдау; «500 емес» деген әлсіз шарт; бақыланатын нәтижесі жоқ UI тест |
| `run oracle:audit -- DV-XXXX` | response schema мен business invariant бөлек дәлелденбеуі; `.agent007/oracle-contracts/DV-XXXX.json`-да requirement → TC → grounded source байланысының жоқтығы; source-та page version/revision жоқтығы; postcondition hook жоқ positive mutation; `@cross-service`-та екінші source жоқтығы; manifest ішінде токен/секрет болуы |
| `run independence:audit -- DV-XXXX` | `serial`, mutating `beforeAll`, кеш shared `afterAll` cleanup. Тізім seed-пен араластырылып, әр тест standalone жүгіреді, сосын `2 workers × 2 repeat`, `retries=0` |
| `run ui:coverage` | 91 declaration, 10 файл, suite классификациясы, P0/P1 journey матрицасы. Мерзімі өткен quarantine (owner + 20+ таңба reason + болашақ `expiresAt` міндетті) аудитті құлатады |

## Негативтерге рұқсат етілген ерекшелік

Negative/RBAC flow-да **дәл статус oracle-і** жарамды — себебі тексерілетін
нәрсе дәл сол статус.

## Ереже

Gate құласа — **кодты түзет, gate-ті түзетпе**. Шектеуді өзгерту қажет деп
ойласаң, алдымен ол шектеуді айналып өтетінін көрсететін regression test жаз
(`docs/` талабы), сосын талқыла.
