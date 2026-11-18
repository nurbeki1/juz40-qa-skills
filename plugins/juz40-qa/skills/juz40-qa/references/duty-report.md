# Кезекшілік / дейлик есебі

Канон: `docs/QA-REPORTING-CONTRACT.md`. Әдепкі режим — **жібермеу**: алдымен
мәтінді көрсет, адам растағанда ғана жібер.

## Дейлик

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run daily-report -- --dry    # тек көрсету
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run daily-report             # топик «Дейлик»
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run daily-report -- --user   # жекеге
```

Соңғы ~32 сағатты қамтиды (тәулік + қоры).

## Релиз снапшоты / дашборд

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run release:snapshot
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:report -- validate <report.json>
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run qa:report -- render   <report.json>
```

## Allure

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run report:generate
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run report:deploy
```

QA-report immutable run URL мен stable latest URL-дің **бір** full-QA
manifest-ке тиесілі екенін тексереді. Екі URL-ді араластырып жіберуге болмайды.

## Қай хабар қайда (агенттегі routing)

| Мазмұн | Бағыт |
|---|---|
| Тест-кейстер дайын / PM approval / mobile handoff | топик `Тест-кейсы` |
| Run нәтижесі + Allure | топик `Автотесты/результаты` |
| Product bug | топик `Баги` |
| Спека/Figma/дерек жоқ | топик `Продукт` |
| Дейлік статус | топик `Дейлик` |
| MR / `UNKNOWN` эскалация | личка |

Ескерту: бір типтегі қорытынды **бір рет** жіберіледі. Тыныш сағаттар
(20:00–09:00 Алматы) және демалыс — командалық хабар дүйсенбі таңертең кетеді.
Skill дедупті өзі жүргізмейді, сондықтан қайта жібермес бұрын тексер.

## Есептің міндетті құрамы

1. Қай DV-лер қаралды, қай статуста
2. Қай gate өтті / құлады (`PARTIAL` себебі)
3. Evidence/Allure сілтемесі
4. Ашылған/жабылған багтар
5. **Не тексерілмеді және неге** (mobile handoff, орта, спека жоқ)
6. Бұғаттаушылар және кімнен не күтіліп тұр
