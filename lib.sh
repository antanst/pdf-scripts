# All those functions are portable and should
# work across all UNIX systems using Bash.

#
# Generate random string of given length
#
random_string() {
    cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w "${1}" | head -n 1
}

#
# Check if all dependencies are installed.
#
check_depends() {
    for X in ${1}; do
        if ! [ -x "$(command -v ${X})" ]; then
            echo Dependency '"'"${X}"'"' not found. >&2
            exit 1
        fi
    done
}

#
# Get absolute path for file
# See https://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
#
fullpath() {
    printf "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

#
# Check that a file exists and is readable
#
file_readable() {
    if [ ! -z "${1}" ] && [ ! -r "${1}" ]; then
	echo "Cannot read file ${1}"
	exit 1
    fi
}

