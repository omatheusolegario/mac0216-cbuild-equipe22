#!/opt/homebrew/bin/bash

PROJECT_DIR="$PWD/tests/mgolegario"
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$PROJECT_DIR/logs"
EXECUTABLE="$BUILD_DIR/programa"
OPT_LEVEL=0
VERBOSE=1
DEBUG=0

SOURCE_FILES=("$PROJECT_DIR/soma.c" "$PROJECT_DIR/main.c" "$PROJECT_DIR/subtracao.c")
HEADER_FILES=("$PROJECT_DIR/operacoes.h")

mkdir -p "$BUILD_DIR" "$LOG_DIR"

verbose_msg(){ 
    if [[ "$VERBOSE" -eq 1 ]];then
        echo "$1"
    fi
    return 0
}
debug_msg(){
     if [[ "$DEBUG" -eq 1 ]];then
        echo "$1"
    fi
    return 0
}
record_event(){ :; }

source ./lib/build.sh
build_project