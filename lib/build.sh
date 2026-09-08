build_project() {
    local -a objetos=()
    for fonte in "${SOURCE_FILES[@]}"; do
        local nome_base
        nome_base=$(basename "$fonte")
        local nome_objeto
        nome_objeto="$BUILD_DIR/${nome_base%.c}.o"

        objetos+=("$nome_objeto")

        local precisa_compilar=0

        dependencias_locais=$(grep -E '#include+ "[^"]+"' "$fonte" | cut -d'"' -f2)

        if [[ ! -f "$nome_objeto" ]]; then
            precisa_compilar=1
        elif [[ "$fonte" -nt "$nome_objeto" ]]; then
            precisa_compilar=1
        else
            for cabecalho in "${HEADER_FILES[@]}"; do
                if [[ "$cabecalho" -nt "$nome_objeto" ]]; then
                    precisa_compilar=1
                    break
                fi
            done
        fi

        if [[ $precisa_compilar -eq 1 ]]; then
            echo "Compilando $fonte..."
            gcc -c "$fonte" -O"$OPT_LEVEL" -o "$nome_objeto"
            if [[ $? -ne 0 ]]; then
                echo "Erro ao compilar $fonte"
                return 1
            fi
        else
            echo "Arquivo objeto $nome_objeto está atualizado."
        fi
    done
    
    echo "Linkando arquivos objeto..."
    gcc "${objetos[@]}" -o "$EXECUTABLE"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao linkar arquivos objeto"
        return 1
    fi

    echo "Build concluído com sucesso. Executável: $EXECUTABLE"
}