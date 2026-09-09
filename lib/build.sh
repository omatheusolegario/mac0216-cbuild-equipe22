build_project() {

    #verifica se o gcc existe no sistema
    if command -v gcc >/dev/null 2>&1; then
        echo "GCC encontrado."
    else
        echo "Erro: Compilador GCC não encontrado. Por favor, instale o GCC para continuar."
        return 1
    fi
    
    #verifica se existem arquivos fonte
    if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
        echo "Nenhum arquivo fonte especificado." >&2
        return 1
    fi


    #array para armazenar os arquivos .o
    local -a objetos=()
    local forcar_recompilacao=0

   #verifica se mudaram as flags de optimização
    if [[ ! -f "$BUILD_DIR/OPT_LEVEL.txt" || "$(<"$BUILD_DIR/OPT_LEVEL.txt")" != "$OPT_LEVEL" ]]; then
            echo "Nível de otimização mudou. Forçando recompilação de todos os arquivos fonte."
            forcar_recompilacao=1
            if ! rm -f "$BUILD_DIR/OPT_LEVEL.txt"; then
                echo "Erro ao remover arquivo de nível de otimização antigo" >&2
                return 1
            fi
    fi

    for fonte in "${SOURCE_FILES[@]}"; do
        #atribui um nome base único para cada fonte, de acordo com seu caminho relativo
        local caminho_relativo="${fonte#"$PROJECT_DIR/"}"
        local nome_base="${caminho_relativo%.c}"
        local nome_objeto="$BUILD_DIR/${nome_base}.o"
        local nome_dep="$BUILD_DIR/${nome_base}.d"
        objetos+=("$nome_objeto")

        if ! mkdir -p "$(dirname "$nome_objeto")"; then
            echo "Erro ao criar diretório para $nome_objeto" >&2
            return 1
        fi

        local precisa_compilar="$forcar_recompilacao"

        if [[ ! -f "$nome_objeto" || ! -f "$nome_dep" ]] ; then
            precisa_compilar=1
        fi
        
        if [[ $precisa_compilar -eq 0 ]]; then
            if ! make -f - -q 2>dev/null <<
            EOF
            OBJ := $nome_objeto
            SRC := $fonte
            DEP := $nome_dep

            \$(OBJ): \$(SRC)
            -include \$(DEP)
            EOF
            then
                precisa_compilar=1
            fi
        fi


        #se precisa compilar, compila o fonte para objeto
        if [[ $precisa_compilar -eq 1 ]]; then
            echo "Compilando $fonte..."
            gcc -c -I "$PROJECT_DIR/include" -MMD -MP "$fonte" -O"$OPT_LEVEL" -o "$nome_objeto"
            if [[ $? -ne 0 ]]; then
                echo "Erro ao compilar $fonte" >&2
                return 1
            fi
        else
            echo "Arquivo objeto $nome_objeto está atualizado."
        fi
    done
    
    #linka todos objeto para criar o executavel
    echo "Linkando arquivos objeto..."
    gcc "${objetos[@]}" -o "$EXECUTABLE"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao linkar arquivos objeto"
        return 1
    fi 

    if ! echo "$OPT_LEVEL" > "$BUILD_DIR/OPT_LEVEL.txt"; then
        echo "Erro ao salvar nível de otimização" >&2
        return 1
    fi

    echo "Build concluído com sucesso. Executável: $EXECUTABLE"
}