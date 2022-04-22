#!bin/bash
GIT_BOSIS="https://github.com/sinkog/BaseOperationSystemInstallScripts.git"

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
