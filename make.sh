#!bin/bash

while getopts w:gb flag
do
    case "${flag}" in
        w) WORKDIR=${OPTARG};;
        gb) GIT_BOSIS=${OPTARG};;
    esac
done
if [ -z "${WORKDIR}" ] && WORKDIR=$(mktemp -d -t demoXXXXXX)
if [ -z "${GIT_BOSIS}" ] && GIT_BOSIS="https://github.com/sinkog/BaseOperationSystemInstallScripts.git"


cd ${WORKDIR}
### incude dependencies
if [ -d "BaseOperationSystemInstallScripts" ]; then
  echo "git pull on the BaseOperationSystemInstallScripts directory"
  if !(cd BaseOperationSystemInstallScripts && git pull && cd .. ;); then
    echo "git pull failed" && exit 1
  else 
    echo "pulled"
  fi
else
  echo "git clone BaseOperationSystemInstallScripts"
  if !(git clone ${GIT_BOSIS} BaseOperationSystemInstallScripts); then
    echo "git clone failed"
  fi
fi



#bash nyers/create_vm.sh
