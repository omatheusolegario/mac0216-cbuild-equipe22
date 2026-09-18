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


# Testes da segunda função - clean_project()

# teste 6 - clean remove build, mas preserva outros arquivos

PROJECT_DIR="$pasta_teste/projeto"
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$BUILD_DIR/objetos"
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/include"
mkdir -p "$LOG_DIR"

touch "$BUILD_DIR/programa"
touch "$BUILD_DIR/objetos/main.o"
touch "$PROJECT_DIR/src/main.c"
touch "$PROJECT_DIR/include/main.h"
touch "$LOG_DIR/events.log"

clean_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 0 &&
      ! -e "$BUILD_DIR" &&
      -f "$PROJECT_DIR/src/main.c" &&
      -f "$PROJECT_DIR/include/main.h" &&
      -f "$LOG_DIR/events.log" ]]; then

    echo "PASSOU: clean remove build e preserva os outros arquivos"
else
    echo "FALHOU: clean remove build e preserva os outros arquivos"
    erros=$((erros + 1))
fi

# teste 7 - limpar um projeto que já está limpo

# BUILD_DIR já foi removido pelo teste anterior.
clean_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 0 ]]; then
    echo "PASSOU: clean funciona quando o projeto já está limpo"
else
    echo "FALHOU: clean funciona quando o projeto já está limpo"
    erros=$((erros + 1))
fi


# teste 8 - recusar diretório fora do projeto

PROJECT_DIR="$pasta_teste/projeto"
BUILD_DIR="$pasta_teste/diretorio_fora"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$BUILD_DIR"
touch "$BUILD_DIR/arquivo_importante.txt"

clean_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -ne 0 &&
      -f "$BUILD_DIR/arquivo_importante.txt" ]]; then

    echo "PASSOU: clean recusa diretório fora do projeto"
else
    echo "FALHOU: clean recusa diretório fora do projeto"
    erros=$((erros + 1))
fi

# teste 9 -  não apagar logs que estejam dentro de build

PROJECT_DIR="$pasta_teste/projeto_com_logs"
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$BUILD_DIR/logs"

mkdir -p "$LOG_DIR"
touch "$LOG_DIR/events.log"

clean_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -ne 0 &&
      -f "$LOG_DIR/events.log" ]]; then

    echo "PASSOU: clean protege o diretório de logs"
else
    echo "FALHOU: clean protege o diretório de logs"
    erros=$((erros + 1))
fi

## Agora os testes da terceira funçao minha - rebuild

# Funções falsas usadas para testar rebuild_project.

ordem=""
resultado_clean=0
resultado_build=0

clean_project() {
    ordem="${ordem}clean;"
    return "$resultado_clean"
}

build_project() {
    ordem="${ordem}build;"
    return "$resultado_build"
}

# teste 10 - clean e build funcionam

ordem=""
resultado_clean=0
resultado_build=0

rebuild_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 0 && "$ordem" == "clean;build;" ]]; then
    echo "PASSOU: rebuild executou clean e depois build"
else
    echo "FALHOU: rebuild não executou clean e build corretamente"
    erros=$((erros + 1))
fi

# teste 11 - clean falha e build não deve ser chamado

ordem=""
resultado_clean=4
resultado_build=0

rebuild_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 4 && "$ordem" == "clean;" ]]; then
    echo "PASSOU: rebuild parou quando clean falhou"
else
    echo "FALHOU: rebuild tentou continuar depois da falha de clean"
    erros=$((erros + 1))
fi

# teste 12 - clean funciona, mas build falha

ordem=""
resultado_clean=0
resultado_build=7

rebuild_project > /dev/null 2> /dev/null
codigo=$?

if [[ $codigo -eq 7 && "$ordem" == "clean;build;" ]]; then
    echo "PASSOU: rebuild preservou o erro de build"
else
    echo "FALHOU: rebuild não tratou corretamente o erro de build"
    erros=$((erros + 1))
fi

# Remove os arquivos temporários
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