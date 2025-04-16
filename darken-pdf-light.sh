#!/usr/bin/env bash
set -euo pipefail
LC_ALL=C # For portability

# Get this script's folder
BASEDIR=$(dirname "$0")

# Load library with common functions
# shellcheck source=./lib.sh
. "${BASEDIR}/lib.sh"

usage() {
    echo "$(basename "$0")": ERROR: "$*" >&2
    echo Syntax: "$(basename "$0")" "<fin> <fout>" >&2
    exit 1
}

# Check for correct number of arguments
[ $# -gt 2 ] || [ $# -lt 2 ] && usage "Wrong number of arguments"

check_depends "hexdump gs pdfinfo awk expr parallel convert"
file_readable "${1}"

# Random folder within /tmp to house temp files
WORKDIR=/tmp/$(hexdump -n 12 -v -e '/1 "%02X"' /dev/urandom)

# Make sure we clean up after ourselves.
# See https://www.shellscript.sh/trap.html
trap cleanup 1 2 3 6
cleanup() {
  echo "Cleaning up."
  rm -rf "${WORKDIR}"
}

mkdir -p "$WORKDIR"
echo "Working dir: ${WORKDIR}" >&2
NUM_OF_PAGES=5 #How many pages we should split the PDF into
PAGE_FIRST=1
PAGE_LAST=$NUM_OF_PAGES
INDEX=0

# Get number of pages of PDF
TOTAL_PAGES=$(pdfinfo "${1}" | grep Pages | awk '{print $2}')
echo "Total pages: ${TOTAL_PAGES}" >&2

# Split PDF to smaller PDFs
echo "Splitting PDF..." 2>&1
COMMANDS=""
while [ "${PAGE_FIRST}" -le "${TOTAL_PAGES}" ]
do
    COMMANDS=${COMMANDS}" '""${BASEDIR}/split-pdf.sh \"${1}\" ${PAGE_FIRST} ${PAGE_LAST} $WORKDIR/p${INDEX}.pdf 2>/dev/null""'"
    PAGE_FIRST=$(expr "$PAGE_LAST" + 1)
    PAGE_LAST=$(expr "$PAGE_FIRST" + "$NUM_OF_PAGES")
    INDEX=$(expr "${INDEX}" + 1)
done

eval "parallel --bar ::: ${COMMANDS}" # See https://stackoverflow.com/questions/7454526/variable-containing-multiple-args-with-quotes-in-bash

# Convert each PDF to images,
# darken images, and combine
# darkened images to new PDFs
COMMANDS1=""
COMMANDS3=""
for file in "${WORKDIR}"/p*.pdf;
do
    DIR="${WORKDIR}/$(basename "${file}" .pdf)"
    mkdir -p "${DIR}"
    COMMANDS1=${COMMANDS1}" '""convert -colorspace Gray -density 300 -gamma 0.9 -alpha remove \"${file}\" ${DIR}/output-%05d.png""'"
    COMMANDS3=${COMMANDS3}" '""convert ${DIR}/output*.png ${WORKDIR}/dark-$(basename "${file}" .pdf).pdf""'"
done

echo "Splitting PDFs to images..." >&2
eval "nice parallel --bar ::: ${COMMANDS1}"
echo "Merging images to PDFs..." >&2
eval "nice parallel --bar ::: ${COMMANDS3}"

# Combine PDFs back to one
# Possible compression levels, from worst quality to best: 'screen', 'ebook', 'printer', 'prepress'
echo "Combining final PDF..." >&2
nice `which gs` -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="${2}" -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dBATCH `find ${WORKDIR} -maxdepth 1 -name "dark-*pdf" | sort -V | paste -sd ' ' -` >/dev/null 2>&1

# Clean up after ourselves
#cleanup
exit 0

echo "Done!" >&2
