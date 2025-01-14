#!/bin/bash

script_dir="$(dirname "$0")"

print_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --src=<path/to/src>         path to a verilog source file"
    echo "  -h, --help                  print help"
}

SRC=
for arg in "$@"; do
    case "$1" in
        --src=*)
            SRC=${arg:6}
            ;;
        -h|--help)
            print_help
            ;;
        *)
            echo "Invalid option: $1"
            print_help
            exit 1
            ;;
    esac
done

SRC_DIR=$(dirname "$SRC")
BUILD_DIR="${SRC_DIR//src/build}"
SRC_FILE=$(basename "$SRC")
VVP="$BUILD_DIR/${SRC_FILE//.v/.vvp}"

if [ ! -e $VVP ]; then
    echo "missing $VVP"
    exit 1
fi

vvp ${VVP}
