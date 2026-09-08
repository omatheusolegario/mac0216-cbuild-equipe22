#!/bin/bash

PROJECT_DIR="$PWD/tests/mgolegario"
BUILD_DIR="$PROJECT_DIR/build"
LOG_DIR="$PROJECT_DIR/logs"
EXECUTABLE="$BUILD_DIR/programa"
OPT_LEVEL=0
VERBOSE=0
DEBUG=0

SOURCE_FILES=("$PROJECT_DIR/operacoes.c" "$PROJECT_DIR/main.c")
HEADER_FILES=("$PROJECT_DIR/operacoes.h")

mkdir -p "$BUILD_DIR" "$LOG_DIR"

verbose_msg(){ :; }
debug_msg(){ :; }
record_event(){ :; }

source ./lib/build.sh
build_project