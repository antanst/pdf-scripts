#!/usr/bin/env bash

usage() {
    echo `basename $0`: ERROR: $* >&2
    echo Syntax: `basename $0` "<fin1> <fin2> ... <fout>" >&2
    exit 1
}

# Check if all dependencies are installed.
DEPENDENCIES="gs"
for X in ${DEPENDENCIES}; do
    if ! [ -x "$(command -v ${X})" ]; then
        echo Dependency '"'"${X}"'"' not found. >&2
        exit 1
    fi
done

echo "Combining ${a[${#a[@]}-1]} => ${a[${#a[@]}-1]}" >&2

gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=final.pdf -dBATCH "${a[${#a[@]}-1]}"
