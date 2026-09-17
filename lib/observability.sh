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

    #garante que operations.log existe
    mkdir -p "$LOG_DIR"
    touch "$LOG_DIR/operations.log"

    #acha a última compilação com sucesso no log. Imprime data e horário
    local Comp_Data=""
    if [[ -f "$LOG_DIR/operations.log" ]]; then
        Comp_Data=$(grep -e "Comando: build" -e "Comando: rebuild" $LOG_DIR/operations.log | grep "Código de retorno: 0" | tail -n 1 | cut -d '-' -f 1)
    fi
    if [[ -n $Comp_Data ]]; then
        echo "Data da última compilação: $Comp_Data"
    else
        echo "Data da última compilação indispońivel"
    fi

    #acha a última execução com sucesso no log. Imprime data e horário
    if [[ -f "$LOG_DIR/operations.log" ]]; then
        Comp_Data=$(grep "Comando: run" $LOG_DIR/operations.log | grep "Código de retorno: 0" | tail -n 1 | cut -d '-' -f 1)
    fi
    if [[ -n $Comp_Data ]]; then
        echo "Data da última execução: $Comp_Data"
    else
        echo "Data da última execução indispońivel"
    fi
    return 0
}

log_begin() {
    #deixa salvo o comando executado e o horário de execução para o log_end usar depois
    Log_Comando=$1
    Log_Start_Time=$(date +%s%N)
    Log_Time_Formatted=$(date "+%d/%m/%y %H:%M:%S")
    return 0
}

log_end() {
    #ve se houve sucesso ou falha
    local Log_Codigo=$1

    #garante que o diretório dos logs existe
    mkdir -p "$LOG_DIR"

    #calcula o tempo de execução
    local Log_Tempo_Nano=$(($(date +%s%N)-$Log_Start_Time))
    local Log_Execucao="$(($Log_Tempo_Nano / 1000000000)).$(printf "%03d" "$((($Log_Tempo_Nano / 1000000) % 1000))")"
    
    #o arquivo de log chama operations.log. Exemplo do formato de uma linha do log: 09/09/26 16:04:49 - Comando: build - Tempo de execução: 0.005 - Código de retorno: 0 - Erro:
    echo "$Log_Time_Formatted - Comando: $Log_Comando - Tempo de execução: $Log_Execucao - Código de retorno: $Log_Codigo - Erro:" >> $LOG_DIR/operations.log
    

    #falta achar a mensagem de erro
    return 0
}

generate_report() {
    #garante que operations.log existe
    mkdir -p "$LOG_DIR"
    touch "$LOG_DIR/operations.log"

    #cria o relatório com o número total de operações, de operações sucedidas/fracassadas, de compilações e execuções
    echo "Relatório das operações" > $LOG_DIR/report.txt
    echo -e "\nTotal de operações: $(wc -l < $LOG_DIR/operations.log)" >> $LOG_DIR/report.txt
    echo "Operações bem sucedidas: $(grep "Código de retorno: 0" < $LOG_DIR/operations.log | wc -l)" >> $LOG_DIR/report.txt
    echo "Operações fracassadas: $(grep "Código de retorno: 1" < $LOG_DIR/operations.log | wc -l)" >> $LOG_DIR/report.txt
    echo -e "\nCompilações: $(grep "Código de retorno: 0" < $LOG_DIR/operations.log | grep -e "Comando: build" -e "Comando: rebuild" | wc -l)" >> $LOG_DIR/report.txt
    echo "Execuções: $(grep "Código de retorno: 0" < $LOG_DIR/operations.log | grep "Comando: run" | wc -l)" >> $LOG_DIR/report.txt
    return 0
}

verbose_msg() { 
    #imprime as mensagens verbose, caso a opção verbose esteja sendo usada
    if [[ "$VERBOSE" -eq 1 ]];then
        echo "$1"
    fi
    return 0
}

debug_msg() {
    #imprime as mensagens de debug, caso a opção debug esteja sendo usada
     if [[ "$DEBUG" -eq 1 ]];then
        echo "DEBUG: $1"
    fi
    return 0
}