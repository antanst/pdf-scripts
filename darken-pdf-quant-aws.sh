#!/usr/bin/env bash
LC_ALL=C # For portability
set -e # Stop on error
#set -x # Echo commands as they are executed

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

check_depends "ssh scp aws2"
file_readable "${1}"
check_depends "aws2"

FAST_SERVER_SSH="root@208.167.245.136"

# Copy PDF to fast server
scp "${1}" "${FAST_SERVER_SSH}:~/1.pdf"

# Create new AWS instance
INSTANCE_TYPE="m4.16xlarge" #t2.micro
TEMP1="$(aws2 ec2 --profile default run-instances --image-id ami-0b0a122e43251a36f --count 1 --instance-type ${INSTANCE_TYPE} --key-name mine --security-group-ids sg-000b990a865817285 --subnet-id subnet-08a9402c4cfe150b9)"
INSTANCE_ID=`remove_double_quotes "$(echo ${TEMP1} | jq .Instances[0].InstanceId)"`
echo "Instance ID: ${INSTANCE_ID}"
echo "Waiting for instance to settle..."
INSTANCE_IP=`remove_double_quotes "$(aws2 ec2 --profile default describe-instances --instance-id ${INSTANCE_ID} | jq .Reservations[0].Instances[0].PublicIpAddress)"`
echo "Instance IP: ${INSTANCE_IP}"
INSTANCE_SSH="admin@${INSTANCE_IP}"
sleep 30

# Copy necessary scripts to instance
scp "${BASEDIR}/lib.sh" "${INSTANCE_SSH}:~/"
scp "${BASEDIR}/split-pdf.sh" "${INSTANCE_SSH}:~/"
scp "${BASEDIR}/darken-pdf-quant.sh" "${INSTANCE_SSH}:~/"

# Copy PDF from fast host to server
echo scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "${FAST_SERVER_SSH}:~/1.pdf" "~/1.pdf" | ssh "${INSTANCE_SSH}"

# Process PDF
echo '~/darken-pdf-quant.sh ~/1.pdf ~/2.pdf' | ssh "${INSTANCE_SSH}"

# Copy darkened PDF to fast host
echo scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "~/2.pdf" "${FAST_SERVER_SSH}:~/2.pdf" | ssh "${INSTANCE_SSH}"

# Delete instance
echo "Deleting instance ${INSTANCE_ID}"
aws2 ec2 --profile default terminate-instances --instance-ids "${INSTANCE_ID}" | jq .

# Copy PDF from fast host to us
scp "${FAST_SERVER_SSH}:~/2.pdf" "${2}"

echo "Done!" >&2
exit 0
