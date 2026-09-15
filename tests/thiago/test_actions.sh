#!/usr/bin/env bash

# Testes das funçoes run_project, clean_project e rebuild_project

#!/usr/bin/env bash

# Este teste deve ser executado na raiz do repositório.
source lib/actions.sh

# Substitutos das funções que serão feitas pelo Matheus.
evento=""

verbose_msg() {
    :
}

debug_msg() {
    :
}

record_event() {
    evento="$1"
}

# Pasta temporária para os programas de teste.
pasta_teste=$(mktemp -d)


# criei essa variável para no fim verificar se teve algum erro
# e avisar se teve
erros=0

# Teste 1 - se executa com sucesso

cat > "$pasta_teste/programa_ok.sh" <<'EOF'
#!/usr/bin/env bash
echo "Programa executado"
EOF

chmod +x "$pasta_teste/programa_ok.sh"

EXECUTABLE="$pasta_teste/programa_ok.sh"
evento=""

run_project > "$pasta_teste/saida.txt" 2> /dev/null

codigo=$?
saida=$(cat "$pasta_teste/saida.txt")

if [[ $codigo -eq 0 &&
      "$saida" == "Programa executado" &&
      "$evento" == "run" ]]; then

    echo "PASSOU: programa executado com sucesso"
else
    echo "FALHOU: programa executado com sucesso"
    erros=$((erros + 1))
fi

# Teste 2 - quando o exe nao existe

EXECUTABLE="$pasta_teste/nao_existe"
evento=""

run_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -ne 0 && -z "$evento" ]]; then
    echo "PASSOU: executável inexistente"
else
    echo "FALHOU: executável inexistente"
    erros=$((erros + 1))
fi

# Teste 3 - quando o exe não tem permissão

cat > "$pasta_teste/sem_permissao.sh" <<'EOF'
#!/usr/bin/env bash
echo "Este programa não deveria executar"
EOF

chmod -x "$pasta_teste/sem_permissao.sh"

EXECUTABLE="$pasta_teste/sem_permissao.sh"
evento=""

run_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -ne 0 && -z "$evento" ]]; then
    echo "PASSOU: arquivo sem permissão"
else
    echo "FALHOU: arquivo sem permissão"
    erros=$((erros + 1))
fi

# teste 4 - quando o programa retorna erro

cat > "$pasta_teste/programa_erro.sh" <<'EOF'
#!/usr/bin/env bash
exit 7
EOF

chmod +x "$pasta_teste/programa_erro.sh"

EXECUTABLE="$pasta_teste/programa_erro.sh"
evento=""

run_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 7 && -z "$evento" ]]; then
    echo "PASSOU: código de erro foi preservado"
else
    echo "FALHOU: código de erro foi preservado"
    erros=$((erros + 1))
fi

# teste 5 - entrada e saída do programa

cat > "$pasta_teste/programa_entrada.sh" <<'EOF'
#!/usr/bin/env bash

read nome
echo "Olá, $nome!"
EOF

chmod +x "$pasta_teste/programa_entrada.sh"

EXECUTABLE="$pasta_teste/programa_entrada.sh"
evento=""

run_project <<< "Thiago" \
    > "$pasta_teste/saida.txt" \
    2> /dev/null

codigo=$?
saida=$(cat "$pasta_teste/saida.txt")

if [[ $codigo -eq 0 && "$saida" == "Olá, Thiago!" ]]; then
    echo "PASSOU: entrada e saída preservadas"
else
    echo "FALHOU: entrada e saída preservadas"
    erros=$((erros + 1))
fi

# Remove os arquivos temporários.
rm -rf -- "$pasta_teste"

# Resultado final.
echo

if [[ $erros -eq 0 ]]; then
    echo "Todos os testes passaram."
    exit 0
else
    echo "$erros teste(s) falharam."
    exit 1
fi