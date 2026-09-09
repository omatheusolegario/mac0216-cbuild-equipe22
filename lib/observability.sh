show_info() {
    #conta o número de arquivos .c e .h
    echo "Número de arquivos: $((${#SOURCE_FILES[@]}+${#HEADER_FILES[@]}))"

    #conta o número de caracteres \n nos arquivos .c e .h
    local line_count=0
    for file in ${SOURCE_FILES[@]}; do
        ((line_count+=$(wc -l < $file)))
    done

    for file in ${HEADER_FILES[@]}; do
        ((line_count+=$(wc -l < $file)))
    done

    echo "Número de linhas: $line_count"

    #ve o tamanho do executável, se existir
    if [[ -f "$EXECUTABLE" ]]; then
        echo "Tamanho do executável: $(wc -c < $EXECUTABLE) bytes"
    else
        echo "Tamanho do executável indisponível"
    fi


    local Comp_Data=""
    #acha a última compilação com sucesso no log. Imprime data e horário
    if [[ -f "$LOG_DIR/operations.log" ]]; then
        Comp_Data=$(grep -e "Comando: build" -e "Comando: rebuild" $LOG_DIR/operations.log | grep "Código de retorno: 0" | tail -n 1 | cut -d '-' -f 1)
    fi

    if [[ -n $Comp_Data ]]; then
        echo "Data da última compilação: $Comp_Data"
    else
        echo "Data da última compilação indispońivel"
    fi

    #mesma coisa para execução
    if [[ -f "$LOG_DIR/operations.log" ]]; then
        Comp_Data=$(grep "Comando: run" $LOG_DIR/operations.log | grep "Código de retorno: 0" | tail -n 1 | cut -d '-' -f 1)
    fi

    if [[ -n $Comp_Data ]]; then
        echo "Data da última execução: $Comp_Data"
    else
        echo "Data da última execução indispońivel"
    fi
}

log_begin() {
    #deixa salvo o comando e o horário de execução para o log_end usar depois
    Log_Comando=$1
    Log_Start_Time=$(date +%s%N)
    Log_Time_Formatted=$(date "+%d/%m/%y %H:%M:%S")
}

log_end() {
    local Log_Codigo=$1
    mkdir -p "$LOG_DIR"
    #calcula o tempo de execução
    local Log_Tempo_Nano=$(($(date +%s%N)-$Log_Start_Time))
    local Log_Execucao="$(($Log_Tempo_Nano / 1000000000)).$(printf "%03d" "$((($Log_Tempo_Nano / 1000000) % 1000))")"
    
    #o log chama operations.log. Exemplo do formato de uma linha do log: 09/09/26 16:04:49 - Comando: build - Tempo de execução: 0.005 - Código de retorno: 0 - Erro:
    echo "$Log_Time_Formatted - Comando: $Log_Comando - Tempo de execução: $Log_Execucao - Código de retorno: $Log_Codigo - Erro:" >> $LOG_DIR/operations.log
    

    #falta achar a mensagem de erro
}