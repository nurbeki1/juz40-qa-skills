#!/usr/bin/env bash
# Skill preflight: ортаны ӨЗІ тауып, ӨЗІ шешеді. Пайдаланушыдан жол сұрамайды.
#
#   bash preflight.sh
#
# Шығыс: MODE + сол режимде нақты не істеуге болатыны + келесі команда.
# Exit: 0 FULL · 2 SETUP · 3 TESTS_ONLY · 4 BOOTSTRAP
set -uo pipefail

say() { printf '%s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

SEARCH_DIRS=(
  "$HOME" "$HOME/Desktop" "$HOME/Development" "$HOME/Developer"
  "$HOME/projects" "$HOME/work" "$HOME/repos" "$HOME/Documents"
)

# --- орkестратор репосын тап: package.json ішінде name=juz40-aqa-agent007 ---
find_orchestrator() {
  if [ -n "${AGENT_ORCHESTRATOR_PATH:-}" ] && [ -f "$AGENT_ORCHESTRATOR_PATH/package.json" ]; then
    printf '%s' "$AGENT_ORCHESTRATOR_PATH"; return 0
  fi
  local d hit
  for d in "${SEARCH_DIRS[@]}"; do
    [ -d "$d" ] || continue
    hit="$(find "$d" -maxdepth 4 -name package.json -path '*juz40-aqa-agent007*' \
            -not -path '*/node_modules/*' -print -quit 2>/dev/null)" || true
    [ -n "$hit" ] && { printf '%s' "$(dirname "$hit")"; return 0; }
  done
  return 1
}

# --- Playwright тест репосын тап ---
find_test_repo() {
  if [ -n "${TEST_REPO_PATH:-}" ] && [ -d "$TEST_REPO_PATH/playwright" ]; then
    printf '%s' "$TEST_REPO_PATH"; return 0
  fi
  local d hit
  for d in "${SEARCH_DIRS[@]}"; do
    [ -d "$d" ] || continue
    hit="$(find "$d" -maxdepth 4 -type d -name playwright -path '*juz40-aqa-repo*' \
            -not -path '*/node_modules/*' -print -quit 2>/dev/null)" || true
    [ -n "$hit" ] && { printf '%s' "$(dirname "$hit")"; return 0; }
  done
  return 1
}

ORCH="$(find_orchestrator || true)"
TREPO="$(find_test_repo || true)"

say ""
say "SKILL PREFLIGHT"
say ""

# --- базалық құралдар ---
MISSING_TOOLS=""
for t in node npm git; do have "$t" || MISSING_TOOLS="$MISSING_TOOLS $t"; done
if [ -n "$MISSING_TOOLS" ]; then
  say "[FAIL] құрал жетіспейді:$MISSING_TOOLS"
  say "    →  орнат та қайта іске қос (node LTS, git)"
  say ""
  say "MODE: BOOTSTRAP"
  exit 4
fi
say "[OK  ] node $(node -v) · npm $(npm -v)"

# --- репозиторийлер ---
if [ -n "$ORCH" ]; then say "[OK  ] орkестратор: $ORCH"; else say "[ЖОҚ ] орkестратор репосы табылмады (juz40-aqa-agent007)"; fi
if [ -n "$TREPO" ]; then say "[OK  ] тест репосы:  $TREPO"; else say "[ЖОҚ ] тест репосы табылмады (juz40-aqa-repo)"; fi

# --- орkестратор дайындығы ---
NEED_INSTALL=0; NEED_ENV=0
if [ -n "$ORCH" ]; then
  [ -d "$ORCH/node_modules" ] || NEED_INSTALL=1
  [ -f "$ORCH/.env" ] || NEED_ENV=1
  [ "$NEED_INSTALL" = 1 ] && say "[ЖОҚ ] node_modules орнатылмаған"
  [ "$NEED_ENV" = 1 ] && say "[ЖОҚ ] .env жоқ"
fi
say ""

# --- режимді шеш ---
if [ -z "$ORCH" ] && [ -z "$TREPO" ]; then
  say "MODE: BOOTSTRAP — ешнәрсе табылмады"
  say ""
  say "Не істеу керек (бір рет):"
  say "  git clone <juz40-aqa-agent007 URL>"
  say "  git clone <juz40-aqa-repo URL>"
  say "  сосын осы preflight-ты қайта іске қос — қалғанын өзі табады."
  say ""
  say "URL-ді білмесең: команда лидінен сұра (GitLab juz40 тобы)."
  exit 4
fi

if [ -z "$ORCH" ]; then
  say "MODE: TESTS_ONLY — gate командалары жоқ, бірақ жұмыс істеуге болады"
  say ""
  say "ҚОЛЖЕТІМДІ: grounding (API probe, продукт коды), спека оқу және тест-кейс жобалау,"
  say "            Playwright тест жазу және жүгірту, триаж талдауы, Figma сверкасы (MCP арқылы)."
  say "ҚОЛЖЕТІМСІЗ: coverage/oracle/independence аудиті, evidence верификациясы,"
  say "            Confluence-ке кейс жариялау, Jira баг renderer-і, QA жабу шешімі."
  say ""
  say "Сондықтан: нәтижені 'тексерілді' деп жариялама — gate өтпеді."
  say "Толық режимге өту: git clone <juz40-aqa-agent007 URL> → preflight-ты қайта іске қос."
  [ -n "$TREPO" ] && say "" && say "  export TEST_REPO_PATH=\"$TREPO\""
  exit 3
fi

if [ "$NEED_INSTALL" = 1 ] || [ "$NEED_ENV" = 1 ]; then
  say "MODE: SETUP — орkестратор бар, дайындау керек"
  say ""
  [ "$NEED_INSTALL" = 1 ] && say "  npm --prefix \"$ORCH\" ci"
  if [ "$NEED_ENV" = 1 ]; then
    say "  cp \"$ORCH/.env.example\" \"$ORCH/.env\""
    say "  # сосын .env ішіне ӨЗ токендеріңді қой (references/auth.md)"
  fi
  say ""
  say "  export AGENT_ORCHESTRATOR_PATH=\"$ORCH\""
  [ -n "$TREPO" ] && say "  export TEST_REPO_PATH=\"$TREPO\""
  say ""
  say "Содан кейін: npm --prefix \"$ORCH\" run auth:check -- --probe"
  exit 2
fi

# --- FULL: авторизацияны сол жерде тексер ---
say "MODE: FULL — барлық процедура қолжетімді"
say ""
say "  export AGENT_ORCHESTRATOR_PATH=\"$ORCH\""
[ -n "$TREPO" ] && say "  export TEST_REPO_PATH=\"$TREPO\""
say ""
AGENT_ORCHESTRATOR_PATH="$ORCH" TEST_REPO_PATH="${TREPO:-}" \
  npm --prefix "$ORCH" run --silent auth:check -- --probe 2>&1 | sed 's/^/  /'
AUTH_EXIT=${PIPESTATUS[0]}
[ "$AUTH_EXIT" = 0 ] || exit 2
exit 0
