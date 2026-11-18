# Препрод ортасының дайындығын диагностикалау

Мақсат: «тест құлады» мен «орта сынды» деген екеуін ажырату. Құлаудың себебі
ортада болса, триаж жасаудың да, баг ашудың да мәні жоқ.

## Команда

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run readiness:diagnose
# балама атауы: npm run preprod:context
```

Claude-сыз **төрт тәуелсіз** тексеріс:

1. preprod UI artifact
2. API auth boundary
3. төрт рөл credential жұбы (Student / Methodist / Parent / Admin)
4. deploy-trigger метадеректері

Нәтиже: `environment-diagnosis.json` артефакті + `ENVIRONMENT_DIAGNOSIS=<json>`
машина маркері.

## Контракт өрістері

`category` · `code` · `owner` · `retryable` · `reason` · `action` · `evidence`

## Retry саясаты (қатаң)

| Категория | Әрекет |
|---|---|
| `dns` / `infra` / `deploy` | readiness кезінде **шектеулі** retry рұқсат |
| `credential` | **fail-closed** — retry жоқ, аккаунтты түзету керек |
| `test` | fail-closed — тест жағында мәселе |
| `product` | fail-closed. **Тек** UI/API readiness өткеннен кейінгі runtime evidence-тен кейін қойылады |
| `spec` | fail-closed — спека жоқ/бұлыңғыр |
| `unknown` | fail-closed — эскалация |

«Қайта жүгіртіп көрейін» деп циклге түсуге тыйым: readiness өткеннен кейінгі
assertion, coverage, skipped/flaky, product және `UNKNOWN` құлаулары
автоматты қайталанбайды.

## Қосымша тексерістер

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run auth:check -- --probe   # интеграциялар
node scripts/check-preprod-context.mjs                              # препрод контексті
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run ui:coverage              # UI declaration аудиті
```

## Кезекшіге шешім кестесі

| Белгі | Қадам |
|---|---|
| Барлық рөл кірмейді | `credential` — аккаунт/парольді жаңартуды сұра, DevOps-қа |
| UI ашылмайды, API тірі | deploy немесе frontend — deploy метадеректерін көрсет |
| Жалғыз рөл кірмейді | сол аккаунт — жеке мәселе, қалған scope-ты жалғастыруға болады |
| Бәрі OK, бірақ тест құлайды | орта айыпты емес → [triage.md](triage.md) |

## Қорытынды

Диагноз мәтінін (`category` + `owner` + `action`) өзгертпей хабарла. «Шамасы
препрод сынған» деген болжамды өзіңнен қоспа — артефактіде жазылғанды айт.
