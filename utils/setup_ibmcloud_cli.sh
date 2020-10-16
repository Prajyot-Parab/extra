#!/bin/bash

PLATFORM=$(uname)

function install_ibm_cli {
  if [[ "$PLATFORM" == *Linux* ]]; then
        curl -fsSL https://clis.cloud.ibm.com/install/linux | sh >> install_cli.log 2>&1
        install_plugin
        ibmcloud -v
  elif [[ "$PLATFORM" == *Darwin* ]]; then
          curl -fsSL https://clis.cloud.ibm.com/install/osx | sh >> install_cli.log 2>&1
          install_plugin
          ibmcloud -v
  elif [[ "$PLATFORM" == *MINGW* ]]; then
          install_win
          ./ibmcloud -v
  else
       echo "$PLATFORM not supported"
       exit 0
  fi
}

function install_win {
  CLI_REF=`curl -s https://clis.cloud.ibm.com/download/bluemix-cli/latest/win64/archive`
  CLI_URL=`echo $CLI_REF | sed 's/.*href=\"//' | sed 's/".*//'`
  curl -fsSL $CLI_URL -o IBM_Cloud_CLI_latest.zip
  unzip -o IBM_Cloud_CLI_latest.zip > /dev/null 2>&1
  cd IBM_Cloud_CLI
  echo "Installing power-iaas plugin"
  ./ibmcloud plugin install power-iaas -f -q >> install_plugin.log 2>&1
}

function install_plugin {
  echo "Installing power-iaas plugin"
  ibmcloud plugin install power-iaas -f -q >> install_plugin.log 2>&1
}

function main {
  CLI_PATH=`which ibmcloud >&1`
  if [[ "$CLI_PATH" != "" ]]; then
        echo "Updating IBM-Cloud CLI"
        ibmcloud update -f -q
        install_plugin
  else
        echo "Installing IBM-Cloud CLI"
        install_ibm_cli
  fi
}

main

