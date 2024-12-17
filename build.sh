#!/bin/bash

script_dir="$(dirname "$0")"

print_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  -h, --help      print help"
}

for arg in "$@"; do
    case "$1" in
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

if ! command -v iverilog >/dev/null 2>&1; then
    echo "iverilog is not available"
    exit 1
fi

extra_args=()

set -e

for file in $(find "$script_dir" -type f -name "*.v"); do
    echo Building $file
    src_dir=$(dirname "$file")
    src=$(basename "$file")
    dst_dir=$script_dir/build/$(realpath --relative-to="$script_dir" "$src_dir")
    mkdir -p $dst_dir > /dev/null 2>&1
    dst="$dst_dir/$(basename "$file" .v).vvp"
    pushd $src_dir > /dev/null 2>&1
    iverilog "${extra_args[@]}" -o "$dst" "$src";
    popd > /dev/null 2>&1
done

echo "Built all successfully."