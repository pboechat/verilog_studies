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

mkdir -p "$script_dir"

extra_args=()

set -e

for file in "$script_dir"/*.vl; do
    iverilog "${extra_args[@]}" -o "$script_dir/build/$(basename "$file" .vl).vvp" "$file"; 
done

echo "Built all successfully."