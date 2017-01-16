#!/bin/sh
export PATH=/usr/local/bin:/usr/bin:/bin
set -u
#set -exv
export LANG="C"
KEY=

DEBUG=0

_usage() {
	echo "usage:"
	echo "${0} [-a AWS_ACCESS_KEY_ID] [-s AWS_SECRET_ACCESS_KEY] [-p AWS_DEFAULT_PROFILE] [-r AWS_DEFAULT_REGION] -B S3_BUCKET_NAME -P S3_KEY_PREFIX -K S3_KEY"
	exit 1
}

while getopts ":a:f:n:p:r:s:B:P:K:D" opts
do
	case $opts in
		a) export AWS_ACCESS_KEY_ID=${OPTARG} ;;
		p) export AWS_DEFAULT_PROFILE=${OPTARG} ;;
		r) export AWS_DEFAULT_REGION=${OPTARG} ;;
		s) export AWS_SECRET_ACCESS_KEY=${OPTARG} ;;
		B) export BUCKET=${OPTARG} ;;
		P) export PREFIX=${OPTARG} ;;
		D) export DEBUG=1 ;;
		:|\?)
			echo -e \\n"Option -$OPTARG is not allowed."
			_usage;;
	esac
done

OSREL=$(basename `pwd`)

if [[ -z  ${PREFIX+x} ]]; then export PREFIX=${PREFIX}/ ; fi

packer build vbox.json || exit

tar zxvf *.tar.gz '*.vmdk'
fn=$( ls -1 *.vmdk | tail -n 1) || ( echo "tar.gz not fount";exit)
aws s3 cp ${fn} s3://${BUCKET}/${PREFIX} || exit
DESCRIPTION="CentOS bare AMI ${OSREL}"

cat << EOT > vmimport.json
{
	"DryRun": true, 
	"Description": "${DESCRIPTION}", 
	"DiskContainers": [ {
		"Description": "${DESCRIPTION}", 
		"UserBucket": {
			"S3Bucket": "${BUCKET}",
			"S3Key": "${PREFIX}${fn}"
		}
	} ], 
	"Hypervisor": "xen", 
	"Architecture": "x86_64", 
	"Platform": "Linux"
}
EOT
ImportTaskId=$(aws ec2 import-image \
  --description "${DESCRIPTION}" \
  --cli-input-json file://./vmimport.json \
  --query 'ImportTaskId' \
  --output text \
  --no-dry-run)
ImageId=""
while [ "x${ImageId}" = "x" ];do
  sleep 60
  date
  ImageId=$(aws ec2 describe-import-image-tasks \
    --import-task-ids ${ImportTaskId} \
    --query 'ImportImageTasks[].ImageId' \
    --output text )
done
packer build -var aws_source_ami=${ImageId} ami.json

