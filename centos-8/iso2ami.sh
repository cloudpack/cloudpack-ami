#!/bin/sh
export PATH=/usr/local/bin:/usr/bin:/bin
#alias aws='docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws -v ~/.ssh:/root/ssh $(for _e in AWS_PAGER AWS_ACCESS_KEY_ID AWS_CA_BUNDLE AWS_CONFIG_FILE AWS_DEFAULT_OUTPUT AWS_DEFAULT_REGION AWS_PROFILE AWS_ROLE_SESSION_NAME AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SHARED_CREDENTIALS_FILE;do if [ "x$(eval echo \$$_e)" != "x" ];then echo -n " --env $(echo ${_e})=$(eval echo \$$_e) ";fi;done) amazon/aws-cli'
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

#if [[ -z ${PREFIX} ]]; then export PREFIX=${PREFIX}/ ; fi

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
Status="----"
while [ "${Status}" != "completed" -a "${Status}" != "deleted" ];do
  sleep 60
  date
  Status=$(aws ec2 describe-import-image-tasks \
    --import-task-ids ${ImportTaskId} \
    --query 'ImportImageTasks[].Status' \
    --output text )
done
if [ "${Status}" = "completed" ]; then
  ImageId=$(aws ec2 describe-import-image-tasks \
      --import-task-ids ${ImportTaskId} \
      --query 'ImportImageTasks[].ImageId' \
      --output text )
  packer build -var aws_source_ami=${ImageId} ami.json
else
  StatusMessage=$(aws ec2 describe-import-image-tasks \
    --import-task-ids ${ImportTaskId} \
    --query 'ImportImageTasks[].StatusMessage' \
    --output text )
  echo ${StatusMessage}
fi
