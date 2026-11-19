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

Claude Code терминалында екі команда:

```
/plugin marketplace add nurbeki1/juz40-qa-skills
/plugin install juz40-qa@juz40-qa
```

Болды — логин де, токен де, клон да керек емес. Тексеру: `/plugin list`.

Жаңартуға: `/plugin update juz40-qa`.

Презентация (15 слайд, PDF қоса): [docs/skill-presentation.html](docs/skill-presentation.html) · [juz40-qa-skill.pdf](docs/juz40-qa-skill.pdf) · [онлайн](https://claude.ai/code/artifact/8e99db9f-96f3-4521-93b7-c6631f0b9529)

Қалай жұмыс істейтінін көрнекі түсіндіру (диаграммалармен):
[docs/how-it-works.html](docs/how-it-works.html) · [онлайн нұсқасы](https://claude.ai/code/artifact/4062e86a-c5e3-430a-a417-87a1d8d711d8)

## Жұмысқа дайындық

Қолмен жол орнату, README оқу керек емес — skill қосылған бойда ортаны **өзі
тексереді**:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/preflight.sh"
```

Скрипт репозиторийлерді іздеп табады, не жетіспейтінін айтады және режимді
шешеді:

| MODE | Мағынасы | Не болады |
|---|---|---|
| `FULL` | екі репо + токен дайын | барлық 11 процедура ашық |
| `SETUP` | репо бар, `npm ci` / `.env` жетіспейді | дайын командалар беріледі |
| `TESTS_ONLY` | орkестратор репосы жоқ | тест жазу/жүгірту бар, **gate жоқ** — нәтиже «тексерілді» деп жарияланмайды |
| `BOOTSTRAP` | жаңа машина | клондау нұсқауы |

Режим шекаралары: `references/bootstrap.md`. Токен/авторизация: `references/auth.md`
(өз токеніңмен — сервис токенімен емес).

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
