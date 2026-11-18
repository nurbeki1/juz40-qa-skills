# Jira баг ашу

Тек `verdict = PRODUCT_BUG` және сенімділік жоғары болғанда.
Қызыл тест регрессия дәлелі болып қалады: assertion-ды әлсіретпе, күтілетінді
продуктке бейімдеме. Канон: `agent/prompts/jira-bug.md`, `src/bug-report.ts`.

## Жалғыз рұқсат етілген workflow

1. Ағымдағы Story-дың балалық issue-лары арасында **дубльді тексер**.
2. Толық `BugReport` JSON жина (интерфейс — `src/bug-report.ts`).
3. Детерминды валидация:
   ```bash
   npm --prefix "$AGENT_ORCHESTRATOR_PATH" run bug:report -- validate bug-report.json
   ```
4. Jira-ға тек renderer арқылы:
   ```bash
   npm --prefix "$AGENT_ORCHESTRATOR_PATH" run bug:report -- create bug-report.json
   npm --prefix "$AGENT_ORCHESTRATOR_PATH" run bug:report -- update DV-XXXX bug-report.json
   ```

**Raw Jira POST/PUT және қолмен жазылған description — ТЫЙЫМ.** Renderer Story
sub-task жасайды, parent-ті сақтайды, assignee-ді тірі Jira issue бойынша
қайта тексереді.

## Міндетті контракт

- Summary API: `[Bug][Back|Infra][layer] METHOD /path → нақты симптом`
- Summary UI: `[Bug][Front|Mobile][A11y|Responsive|Visual] нақты симптом`
- Дәл **бір** product area: `Front` | `Back` | `Mobile` | `Infra`
- Environment, рөл, секрет емес аккаунт идентификаторы
- Кемінде бір нақты precondition + екі қайталанатын қадам, нақты/динамикалық object ID-мен
- API: көшіріп қоюға дайын `curl` (`Authorization: Bearer <TOKEN>`);
  UI-only: browser URL, viewport, Playwright командасы
- Actual: статус/body немесе browser симптомы, timestamp, қайталанғыштық N/N,
  бар болса duration/requestId
- Expected + спека/контракт дереккөзіне сілтеме
- User/release impact және регрессия шығу тегі
- Нақты код аймағы: файл/метод/native query (read-only grounding-пен табылған)
- Grounding командасы, кемінде екі әрекет және нәтижесі
- Evidence: тест spec + кемінде бір **тірі HTTPS** сілтеме (Allure/pipeline/issue)
- Labels: `agent007`, `aqa`, environment. Priority — severity триажынан

## Багты бақылау

```bash
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run bug-track <BUG-KEY> <STORY-KEY> [TC]
npm --prefix "$AGENT_ORCHESTRATOR_PATH" run bug-track -- --reconcile
```

Баг `Done` болғанда — regression: grounded қайта жүгірту; `fixme` алып тастау
**тек pass болғаннан кейін**.
