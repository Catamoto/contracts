# justfile documentation https://just.systems/man/en/chapter_1.html
# justfile cheatsheet https://cheatography.com/linux-china/cheat-sheets/justfile/

default:
  @just --choose

install:
  forge install

lint:
  #!/bin/bash
  set -euxo pipefail
  # https://www.linuxjournal.com/content/globstar-new-bash-globbing-option
  solhint src/**/*.sol --config .solhint.json

document:
  forge doc

read-docs:
  forge doc --serve

setup:
  #!/bin/bash
  npm
  forge install
  forge compile

build:
  forge build

test:
  forge test

gas:
  forge snapshot

tree:
  bulloak scaffold ./test/concrete/**/**/*.tree -s 0.8.24 -w
  forge fmt

tree-check:
  bulloak check ./test/concrete/**/**/*.tree
  forge fmt

tree-fix:
  bulloak check ./test/concrete/**/**/*.tree --fix
  forge fmt
