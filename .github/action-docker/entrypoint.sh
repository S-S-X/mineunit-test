#!/bin/bash

pushd "${INPUT_WORKING_DIRECTORY}"
set +eo pipefail
exec 3>&1
OUT="$(mineunit -c ${INPUT_MINEUNIT_ARGS} | tee >(cat - >&3); exit ${PIPESTATUS[0]})"
ERR=$?
exec 3>&-
grep_eronly=(grep '0 successes / 0 failures / [1-9] error.\? / 0 pending')
grep_nospec=(grep 'No test files found')
("${grep_eronly[@]}"<<<"$OUT" && "${grep_nospec[@]}"<<<"$OUT")&>/dev/null && echo "spec-missing=true" >> "$[GITHUB_OUTPUT}"
OUT="$(sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g'<<<"$OUT")"
printf 'stdout<<END-OF-MINEUNIT-CONTENT\n%s\nEND-OF-MINEUNIT-CONTENT' "${OUT}" >> "$[GITHUB_OUTPUT}"
popd
exit $ERR

# - id: mineunit-report
pushd "${INPUT_WORKING_DIRECTORY}"
mineunit -r
OUT="$(awk -v p=0 '/^----/{p++;next}p==2{exit}p' luacov.report.out | sort -hrk4)"
printf 'report<<END-OF-MINEUNIT-CONTENT\n%s\nEND-OF-MINEUNIT-CONTENT' "${OUT}" >> "$[GITHUB_OUTPUT}"
popd

# - id: mineunit-coverage
pushd "${INPUT_WORKING_DIRECTORY}"
echo "total=$(tail -n 2 luacov.report.out | grep ^Total | grep -o '[0-9.]\+%$')" >> "$[GITHUB_OUTPUT}"
awk -v p=0 '/^----/{p++;next}p==2{exit}p' luacov.report.out | sort -hrk4 > luacov.report.sum
echo "files=$(grep -cv '\s0\.00%' luacov.report.sum)/$(wc -l<luacov.report.sum)" >> "$[GITHUB_OUTPUT}"
popd

# - id: badge-wrapper-actions-issue-1
# name: Input wrapper while waiting for actions in actions feature
# shell: bash
# run: |
echo "badge-name=${INPUT_BADGE_NAME}" >> "$[GITHUB_OUTPUT}"
echo "badge-label=${INPUT_BADGE_LABEL}" >> "$[GITHUB_OUTPUT}"
echo "badge-color=${INPUT_BADGE_COLOR}" >> "$[GITHUB_OUTPUT}"
