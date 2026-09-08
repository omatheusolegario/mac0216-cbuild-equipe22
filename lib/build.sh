build_project() {
    for fonte in "${SOURCE_FILES[@]}"; do
        local nome_base
        nome_base=$(basename "$fonte")
        local nome_objeto
        nome_objeto="$BUILD_DIR/${nome_base%.c}.o"

        local precisa_compilar=0

        headers=$(grep -E '#include+ "[^"]+"' "$fonte" | cut -d'"' -f2)

        if [[ ! -f "$nome_objeto" ]]; then
            precisa_compilar=1
        elif [[ "$fonte" -nt "$nome_objeto" ]]; then
            precisa_compilar=1
        else
            for cabecalho in $headers; do
                if [[ "$cabecalho" -nt "$nome_objeto" ]]; then
                    precisa_compilar=1
                    break
                fi
            done
        fi

        if [[ $precisa_compilar -eq 1 ]]; then
            echo "Compilando $fonte..."
            clang -c "$fonte" -o "$nome_objeto" -O"$OPT_LEVEL" ${DEBUG:+-g} ${VERBOSE:+-v}
            if [[ $? -ne 0 ]]; then
                echo "Erro ao compilar $fonte"
                exit 1
            fi
        else
            echo "Arquivo objeto $nome_objeto está atualizado."
        fi
    done

    echo "Linkando arquivos objeto..."
    clang "${BUILD_DIR}"/*.o -o "$EXECUTABLE" ${DEBUG:+-g} ${VERBOSE:+-v}
    if [[ $? -ne 0 ]]; then
        echo "Erro ao linkar arquivos objeto"
        exit 1
    fi

    echo "Build concluído com sucesso. Executável: $EXECUTABLE"
}