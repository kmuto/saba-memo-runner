#!/bin/bash
# saba memo runner
# Copyright 2024 Kenshi Muto
#
# do something using the host memo of Mackerel
#
declare -A config
DEBUG=

case "$1" in
  -v) DEBUG=1
      ;;
  *)
      ;;
esac

if [ ! -f saba-memo-runner.conf ]; then
  echo "Aborted: missing saba-memo-runner.conf in current folder."
  exit 1
fi
. saba-memo-runner.conf || exit 1

RESULT=$(mkr status -v --jq '.memo')
[[ $? -ne 0 ]] && exit 1
[[ "$DEBUG" ]] && echo "DEBUG:memo:${RESULT}"

echo "$RESULT" | {
  while read line; do
    if [[ $line =~ ^([[:alnum:]]|_)+$ &&
          -n "${config["$line"]}" &&
          ! -f "${line}.lock" ]]; then
      [[ "$DEBUG" ]] && echo "DEBUG:${line}:${config["$line"]}"
      bash -c "${config["$line"]}" &
    elif [[ $line == "CLEAR_LOCK" ]]; then
      [[ "$DEBUG" ]] && echo "DEBUG:CLAER_LOCK"
      rm -f *.lock
    fi
  done
}
