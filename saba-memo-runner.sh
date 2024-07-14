#!/bin/bash
# saba memo runner
# Run commands using the host memo of Mackerel
#
# Copyright 2024 Kenshi Muto
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

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
    elif [[ $line == "_CLEAR_LOCK" ]]; then
      [[ "$DEBUG" ]] && echo "DEBUG:_CLAER_LOCK"
      rm -f *.lock
    fi
  done
}
