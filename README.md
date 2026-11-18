# juz40-qa-skills

Juz40 QA/AQA процедураларының Claude Code plugin-і. Agent 007 автономды
орындайтын жұмысты **адам басқаратын** нұсқаға көшіреді: барлық сапа тексерісі
(gate) бұрынғыдай детерминды Node командалары арқылы жүреді, skill оларды
қайта жазбайды — шақырады.

Дереккөз (source of truth): `juz40-aqa-agent007` репосы,
`.claude/skills/juz40-qa/`. Бұл репо — **тарату** арнасы.

## Ішінде не бар

| Процедура | Файл |
|---|---|
| Авторизация preflight (кім, қайдан, кімнің атынан) | `references/auth.md` |
| Grounding — факт бойынша жұмыс | `references/grounding.md` |
| Спека → Confluence тест-кейс парағы | `references/spec-to-testcases.md` |
| Тест-кейс → Playwright автотест | `references/autotest-write.md` |
| Сапа gate-тері (coverage / oracle / independence) | `references/quality-gates.md` |
| Препродта тексеру + QA жабу шарттары | `references/preprod-verify.md` |
| Құлаған тестті триаж + self-heal | `references/triage.md` |
| Jira баг ашу контракты | `references/bug-report.md` |
| Figma дизайн сверкасы | `references/figma-check.md` |
| Препрод ортасын диагностикалау | `references/env-readiness.md` |
| Кезекшілік / дейлик есебі | `references/duty-report.md` |

Кезекші тізбегі: `env-readiness` → `preprod-verify` → `duty-report`.

## Орнату

```
/plugin marketplace add nurbeki1/juz40-qa-skills
/plugin install juz40-qa@juz40-qa
```

Репо **private** — сондықтан орнатар алдында GitHub-қа кіру керек
(`gh auth login` немесе SSH кілт) және репоға рұқсат берілуі керек.

## Жұмысқа дайындық

1. Екі репоны клонда: `juz40-aqa-agent007` (орkестратор) және
   `juz40-aqa-repo` (Playwright тесттері).
2. Жолдарды орнат:
   ```bash
   export AGENT_ORCHESTRATOR_PATH="<juz40-aqa-agent007 жолы>"
   export TEST_REPO_PATH="<juz40-aqa-repo жолы>"
   ```
3. Орkестратор репосында `.env` толтыр (`references/auth.md` бойынша —
   **өз токендеріңмен**, сервис токенімен емес).
4. Тексер:
   ```bash
   npm --prefix "$AGENT_ORCHESTRATOR_PATH" run auth:check -- --probe
   ```
   `AUTH_STATUS: READY` шықпаса — skill жұмысты бастамайды, қай токен
   жетіспейтінін айтады.

## Қолдану

Claude Code-та жай тілмен айт — skill өзі қосылады:

- «DV-5877-ге тест-кейс жаз»
- «DV-5877-ні препродта тексер, QA жабуға бола ма»
- «бұл тест құлады, баг па тест пе»
- «дизайнмен сәйкес пе»
- «кезекшілік есебін дайында»

## Жаңарту

Өзгертуді **дереккөз репосында** жаса (`juz40-aqa-agent007`), сосын:

```bash
bash scripts/install-qa-skill.sh --plugin   # осы репоға sync
```

Содан кейін осы репоны коммит/пуш жаса. Қызметкерлер: `/plugin update juz40-qa`.

## Шектеулер

- Бұл plugin мерж жасамайды, продукт кодын өзгертпейді, Figma-ға жазбайды.
- Gate-терді жеңілдетуге тыйым: coverage, oracle, test-data, scope, runtime
  evidence. Құласа — кодты түзету керек, gate-ті емес.
- Mobile scope-ты web арқылы «толық тексерілді» деп жабуға тыйым.
- Секрет бұл репода жоқ және болмауы керек.
