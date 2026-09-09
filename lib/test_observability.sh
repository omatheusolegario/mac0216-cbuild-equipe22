#!/bin/bash
PROJECT_DIR="$PWD/tests/matheus"
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$PROJECT_DIR/logs"
EXECUTABLE="$BUILD_DIR/programa"
VERBOSE=0
DEBUG=0

SOURCE_FILES=("$PROJECT_DIR/src/operacoes.c" "$PROJECT_DIR/src/main.c")
HEADER_FILES=("$PROJECT_DIR/include/operacoes.h")

mkdir -p "$BUILD_DIR" "$LOG_DIR"

source ./lib/observability.sh
show_info

# log_begin "build"
# log_end "0"