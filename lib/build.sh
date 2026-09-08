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


    for fonte in "${SOURCE_FILES[@]}"; do
        #atribui um nome base único para cada fonte, de acordo com seu caminho relativo
        local nome_base="$(basename "$fonte" .c)_from_${fonte#$PROJECT_DIR/}"
        local nome_objeto="$BUILD_DIR/${nome_base}.o"

        objetos+=("$nome_objeto")

        local precisa_compilar=0

        #cria uma lista de todos .h que estão na fonte do loop atual
        local local_dependencias="$BUILD_DIR/${nome_base}_headers.txt"
        gcc -MM "$fonte" | sed 's/^[^:]*: //' | tr ' ' '\n' | grep '\.h$' > "$BUILD_DIR/${nome_base}_headers.txt"
        
        #verifica se o objeto existe, depois se o fonte é mais recente que o 
        #objeto e por fim se algum dos includes é mais novo que o objeto
        if [[ ! -f "$nome_objeto" ]]; then
            precisa_compilar=1
        elif [[ "$fonte" -nt "$nome_objeto" ]]; then
            precisa_compilar=1
        else
            for dependencia in "$(cat "$local_dependencias")"; do
                if [[ "$dependencia" -nt "$nome_objeto" ]]; then
                    precisa_compilar=1
                    break
                fi
            done
        fi

        #verifica se mudaram as flags de optimização
        if [[ ! -f "$BUILD_DIR/OPT_LEVEL.txt" || "$(<"$BUILD_DIR/OPT_LEVEL.txt")" != "$OPT_LEVEL" ]]; then
            precisa_compilar=1
        fi

        rm -f "$local_dependencias"

        #se precisa compilar, compila o fonte para objeto
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
    
    #linka todos objeto para criar o executavel
    echo "Linkando arquivos objeto..."
    gcc "${objetos[@]}" -o "$EXECUTABLE"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao linkar arquivos objeto"
        return 1
    fi 

    echo "$OPT_LEVEL" > "$BUILD_DIR/OPT_LEVEL.txt"

    echo "Build concluído com sucesso. Executável: $EXECUTABLE"
}