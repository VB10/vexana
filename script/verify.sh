#!/usr/bin/env bash
#
# vexana doğrulama script'i
#
#   ./script/verify.sh            analyze + test + web/wasm derlemeleri
#   ./script/verify.sh --quick    sadece analyze + test (derleme yok, ~20sn)
#   ./script/verify.sh --verbose  tüm çıktıyı ekrana bas
#
# Neden bu script var:
#   1) PATH'teki `dart` çoğu makinede Flutter'ın dart'ı DEĞİL (homebrew'un
#      bağımsız Dart SDK'sı olabilir). O zaman `dart run melos ...` şu hatayı
#      verir: "flutter_test from sdk which doesn't exist". Script Flutter'ın
#      kendi dart'ını bulup onu kullanır.
#   2) Test çıktısı, kasten 401 üreten refresh-token testleri yüzünden kırmızı
#      "⛔ Error ⛔" kutularıyla dolu. Bunlar BEKLENEN çıktı, hata değil.
#      Script çıktıyı log'a alır, sadece gerçekten başarısız olursa gösterir.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

QUICK=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    -q | --quick) QUICK=true ;;
    -v | --verbose) VERBOSE=true ;;
    -h | --help)
      sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Bilinmeyen seçenek: $arg (--help ile kullanımı gör)"
      exit 2
      ;;
  esac
done

if [[ -t 1 ]]; then
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
  DIM=$'\033[2m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; DIM=''; BOLD=''; RESET=''
fi

# ---------------------------------------------------------------- toolchain --

FLUTTER="$(command -v flutter || true)"
if [[ -z "$FLUTTER" ]]; then
  echo "${RED}flutter PATH'te bulunamadı.${RESET}"
  exit 1
fi

# Flutter'ın kendi dart'ı `flutter` ile aynı klasörde durur.
DART="$(dirname "$FLUTTER")/dart"
if [[ ! -x "$DART" ]]; then
  # flutter symlink ise gerçek kökü sor.
  FLUTTER_ROOT="$("$FLUTTER" --version --machine 2>/dev/null |
    sed -n 's/.*"flutterRoot": *"\([^"]*\)".*/\1/p')"
  DART="$FLUTTER_ROOT/bin/dart"
fi
if [[ ! -x "$DART" ]]; then
  echo "${RED}Flutter'ın dart'ı bulunamadı. PATH'teki dart kullanılacak.${RESET}"
  DART="$(command -v dart)"
fi

LOG_DIR="$REPO_ROOT/.verify-logs"
rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"

FAILED=()
TEST_COUNT=""

# ------------------------------------------------------------------- helper --

run_step() {
  local name="$1"
  shift
  local slug
  slug="$(echo "$name" | tr -cd '[:alnum:]')"
  local log="$LOG_DIR/$slug.log"

  printf "  %-34s" "$name"

  if [[ "$VERBOSE" == true ]]; then
    printf "\n"
    if "$@" 2>&1 | tee "$log"; then :; fi
    local status=${PIPESTATUS[0]}
  else
    "$@" >"$log" 2>&1
    local status=$?
  fi

  if [[ $status -eq 0 ]]; then
    printf "%sPASS%s\n" "$GREEN" "$RESET"
  else
    printf "%sFAIL%s\n" "$RED" "$RESET"
    FAILED+=("$name|$log")
  fi
  return 0
}

melos_analyze() { "$DART" run melos run analyze; }
melos_test() { "$DART" run melos run test; }
build_example_wasm() { (cd packages/vexana/example && "$FLUTTER" build web --wasm); }
build_playground() { (cd apps/playground && "$FLUTTER" build web); }

# --------------------------------------------------------------------- run ---

echo
echo "${BOLD}vexana doğrulama${RESET}"
echo "${DIM}  dart    : $DART${RESET}"
echo "${DIM}  flutter : $FLUTTER${RESET}"
echo "${DIM}  loglar  : .verify-logs/${RESET}"
echo

run_step "Statik analiz (--fatal-infos)" melos_analyze
run_step "Testler" melos_test

# Test sayısını log'dan çek.
if [[ -f "$LOG_DIR/Testler.log" ]]; then
  TEST_COUNT="$(grep -oE '\+[0-9]+: All tests passed' "$LOG_DIR/Testler.log" |
    tail -1 | grep -oE '[0-9]+')"
fi

if [[ "$QUICK" == false ]]; then
  run_step "example · web derleme (wasm)" build_example_wasm
  if [[ -d "apps/playground" ]]; then
    run_step "playground · web derleme" build_playground
  fi
else
  printf "  %-34s%sATLANDI%s ${DIM}(--quick)%s\n" \
    "Web derlemeleri" "$YELLOW" "$RESET" "$RESET"
fi

# ------------------------------------------------------------------ özet -----

echo
if [[ -n "$TEST_COUNT" ]]; then
  echo "  ${DIM}geçen test: ${TEST_COUNT}${RESET}"
fi

if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "  ${GREEN}${BOLD}Hepsi geçti.${RESET}"
  echo
  echo "  ${DIM}Not: test çıktısındaki kırmızı '⛔ Error ⛔' kutuları ve 401${RESET}"
  echo "  ${DIM}yığın izleri BEKLENEN çıktıdır — refresh-token testleri bunları${RESET}"
  echo "  ${DIM}kasten üretir. Yukarıda PASS yazıyorsa sorun yok.${RESET}"
  echo
  exit 0
fi

echo "  ${RED}${BOLD}${#FAILED[@]} adım başarısız:${RESET}"
echo
for entry in "${FAILED[@]}"; do
  name="${entry%%|*}"
  log="${entry##*|}"
  echo "  ${RED}✗ $name${RESET}"
  echo "  ${DIM}  log: ${log/#$REPO_ROOT\//}${RESET}"
  echo
  sed 's/^/      /' <(tail -25 "$log")
  echo
done
exit 1
