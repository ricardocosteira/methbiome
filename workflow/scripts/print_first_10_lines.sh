#!/bin/bash
print_first_10_lines() {
  BLUE='\033[34m'
  RESET='\033[0m'
  echo -e "\nShowing first 10 lines of $1\n"
  head -n 10 "$1" | while IFS= read -r line; do
    echo -e "$BLUE $line $RESET"
  done
  echo -e "\n"
}
