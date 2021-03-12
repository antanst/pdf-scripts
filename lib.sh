#
# Remove double quotes from start and end of input
#
remove_double_quotes() {
    sed -e 's/^"//' -e 's/"$//' <<< "${1}"
}

#
# Generate random string of given length
#
random_string() {
    LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w "${1}" | head -n 1
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
# Get absolute path, base name and extension only for file
# See https://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
#
fullpath() {
    printf "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

basefilename() {
    filename=$(basename -- "${1}")
    printf "${filename%.*}"
}

extension() {
    filename=$(basename -- "${1}")
    printf "${filename##*.}"
}

#
# Check that a file exists and is readable
#
file_readable() {
    if [ -n "${1}" ] && [ ! -r "${1}" ]; then
	echo "Cannot read file ${1}"
	exit 1
    fi
}

#
# Test SSH access
#
l_test_ssh_access() {
    if ! ssh "${1}" true; then
        echo "Cannot access target via SSH" >&2
        exit 1
    fi
}

#
# File exists at path in host
#
lcopy() {
    scp -rv "${1}" "${2}:${3}"
}

#
# Line exists at file
#

