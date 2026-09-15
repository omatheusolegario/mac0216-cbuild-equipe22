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
    # Verifica se os diretórios necessários foram definidos.
    if [[ -z "${PROJECT_DIR:-}" ]]; then
        printf 'Erro: o diretório do projeto não foi definido.\n' >&2
        return 1
    fi

    if [[ -z "${BUILD_DIR:-}" ]]; then
        printf 'Erro: o diretório de compilação não foi definido.\n' >&2
        return 1
    fi

    # Vou proteger contra a remoção de um diretório perigoso.
    # BUILD_DIR deve estar dentro de PROJECT_DIR.
    if [[ "$BUILD_DIR" == "/" ||
          "$BUILD_DIR" == "$PROJECT_DIR" ||
          "$BUILD_DIR" != "$PROJECT_DIR"/* ]]; then

        printf 'Erro: diretório de compilação inválido: %s\n' \
            "$BUILD_DIR" >&2

        return 1
    fi

    # Não permite apagar o diretório de logs caso ele esteja
    # dentro do diretório de compilação.
    if [[ -n "${LOG_DIR:-}" &&
          ( "$LOG_DIR" == "$BUILD_DIR" || "$LOG_DIR" == "$BUILD_DIR"/* ) ]]; then
        printf 'Erro: o diretório de logs está dentro de build.\n' >&2
        return 1
    fi

    debug_msg "Diretório que será removido: $BUILD_DIR"

    # Se build não existe, o projeto já está limpo.
    if [[ ! -e "$BUILD_DIR" ]]; then
        verbose_msg "O projeto já está limpo."
        return 0
    fi

    # BUILD_DIR deve ser realmente um diretório.
    if [[ ! -d "$BUILD_DIR" ]]; then
        printf 'Erro: BUILD_DIR não corresponde a um diretório: %s\n' \
            "$BUILD_DIR" >&2

        return 1
    fi

    verbose_msg "Removendo arquivos de compilação."

    if rm -rf -- "$BUILD_DIR"; then
        return 0
    else
        printf 'Erro: não foi possível limpar o diretório: %s\n' \
            "$BUILD_DIR" >&2

        return 1
    fi
}

rebuild_project() {
    local status

    verbose_msg "Reconstruindo o projeto."

    # tenta limpar o projeto.
    if clean_project; then
        debug_msg "Limpeza concluída. Iniciando compilação."
    else
        status=$?

        printf 'Erro: não foi possível limpar o projeto antes da compilação.\n' >&2

        return "$status"
    fi

    # Somente compila se a limpeza funcionou.
    if build_project; then
        return 0
    else
        status=$?

        printf 'Erro: não foi possível compilar o projeto novamente.\n' >&2

        return "$status"
    fi
}