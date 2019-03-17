#!/usr/bin/env sh

usage() {
    echo `basename $0`: ERROR: $* >&2
    echo Syntax: `basename $0` "<fin> <from_page> <to_page> <fout>" >&2
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

# Check for correct number of arguments
[ $# -gt 4  -o $# -lt 4 ] && usage "Wrong number of arguments"

# Capture arguments to variables
#arg1=$1;shift
#[ $# -gt 0 ] && { arg2=$1;shift;}
#[ $# -gt 0 ] && { arg3=$1;shift;}
#[ $# -gt 0 ] && { arg4=$1;shift;}

# Check if input file exists
if ! [ -e "${1}" ]
then
    echo "$1 not found." >&2
    exit 1
fi

echo "Splitting $1 pages $2-$3 => $4" >&2

yes | gs -dBATCH -sOutputFile="$4" -dFirstPage="$2" -dLastPage="$3" -sDEVICE=pdfwrite "$1" >/dev/null 2>&1
