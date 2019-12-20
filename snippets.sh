#
# Capture arguments to variables
#
#arg1=$1;shift
#[ $# -gt 0 ] && { arg2=$1;shift;}
#[ $# -gt 0 ] && { arg3=$1;shift;}
#[ $# -gt 0 ] && { arg4=$1;shift;}

#
# Get last argument
# https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script/1854031#comment8318885_1853991
#
ntharg() {
    shift $1
    printf '%s\n' "$1"
}
LAST_ARG=`ntharg $# "$@"`

#
# Get nice date format
#

DATE=`date +%Y-%m-%d` #20190814

#
# Create random string of N*2 character length
#

RANDOM_STRING=$(hexdump -n N -v -e '/1 "%02X"' /dev/urandom)

#
# Pad number to length 5 (123 => 00123)
#
PADDED=$(printf "%05g" 123)
