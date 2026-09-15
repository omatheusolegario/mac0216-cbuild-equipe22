run_project() {
    # Vericando se o caminho foi definido direito
    if [[ -z "${EXECUTABLE:-}" ]]; then
        printf 'Erro: o caminho do executável não foi definido.\n' >&2
        return 1
    fi
    
    debug_msg "Executável resolvido: $EXECUTABLE"

    # Verificando se o executável existe.
    if [[ ! -e "$EXECUTABLE" ]]; then
        printf 'Erro: executável não encontrado: %s\n' "$EXECUTABLE" >&2
        return 1
    fi

    # Evita tentar executar um diretório ou outro tipo de arquivo.
    if [[ ! -f "$EXECUTABLE" ]]; then
        printf 'Erro: o caminho não corresponde a um arquivo: %s\n' \
            "$EXECUTABLE" >&2
        return 1
    fi

    # Verifica a permissão de execução.
    if [[ ! -x "$EXECUTABLE" ]]; then
        printf 'Erro: arquivo sem permissão de execução: %s\n' \
            "$EXECUTABLE" >&2
        return 1
    fi

    verbose_msg "Executando: $EXECUTABLE"

    # Criei uma variavel local para ver o status
    local status

    # Executa o arquivo, e se ser certo, coloca status como 0.
    if "$EXECUTABLE"; then
        status=0
    else
    # Se nao funcionar, ele a função retorna o código de erro
        status=$?
        printf 'Erro: o programa terminou com código %d.\n' "$status" >&2
        return "$status"
    fi

    # registro quando funcionar
    if record_event run; then
        return 0
    else
    # Se nao funcionar, a função retorna o código de erro, que vai
    # indicar que nao foi possível rodar record_event
        status=$?
        printf 'Erro: o programa foi executado, mas não foi possível registrar o evento.\n' >&2
        return "$status"
    fi
}

clean_project() {
    :
}

rebuild_project() {
    :
}