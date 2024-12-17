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

rm -Rdf $script_dir/build