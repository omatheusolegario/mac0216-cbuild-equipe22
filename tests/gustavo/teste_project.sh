#!/usr/bin/env bash

source ./lib/project.sh || exit 1

test_dir="$(mktemp -d)" || exit 1

mkdir -p \
    "$test_dir/src/subpasta" \
    "$test_dir/include" \
    "$test_dir/build" \
    "$test_dir/logs" || exit 1

touch "$test_dir/src/main.c"
touch "$test_dir/src/subpasta/arquivo com espaco.c"
touch "$test_dir/include/calculos.h"

touch "$test_dir/build/ignorar.c"
touch "$test_dir/logs/ignorar.h"

printf 'EXECUTABLE=teste\n' > "$test_dir/.cbuild.conf"

if ! project_init "$test_dir"; then
    printf 'FALHA: project_init não conseguiu preparar o projeto.\n' >&2
    exit 1
fi

if ((${#SOURCE_FILES[@]} != 2)); then
    printf 'FALHA: esperadas duas fontes.\n' >&2
    exit 1
fi

if ((${#HEADER_FILES[@]} != 1)); then
    printf 'FALHA: esperado um cabeçalho.\n' >&2
    exit 1
fi

if [[ "$EXECUTABLE" != "$PROJECT_DIR/build/teste" ]]; then
    printf 'FALHA: executável diferente do configurado.\n' >&2
    exit 1
fi

printf 'OK: preparação básica do projeto.\n'

for file in "${SOURCE_FILES[@]}"; do
    printf 'Fonte: %s\n' "$file"
done

printf 'Pasta temporária para inspeção: %s\n' "$test_dir"
