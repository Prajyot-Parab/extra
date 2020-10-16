#!/bin/bash

PLATFORM=$(uname)
VERSION=${1:-latest}

function install_ibm_cli {
  if [[ "$PLATFORM" == *Linux* || "$PLATFORM" == *Darwin* || "$PLATFORM" == *MINGW* ]]; then
        install_cli
  else
       echo "$PLATFORM not supported"
       exit 0
  fi
}

function install_cli {
  if [[ "$PLATFORM" == *Linux* ]]; then
        CLI_REF=`curl -s https://clis.cloud.ibm.com/download/bluemix-cli/$VERSION/linux64/archive`
  elif [[ "$PLATFORM" == *Darwin* ]]; then
          CLI_REF=`curl -s https://clis.cloud.ibm.com/download/bluemix-cli/$VERSION/osx/archive`
  else
       CLI_REF=`curl -s https://clis.cloud.ibm.com/download/bluemix-cli/$VERSION/win64/archive`
  fi

  CLI_URL=`echo $CLI_REF | sed 's/.*href=\"//' | sed 's/".*//'`
  ARTIFACT=`basename $CLI_URL`
  curl -fsSL $CLI_URL -o $ARTIFACT

  if [[ "$PLATFORM" == *Linux* || "$PLATFORM" == *Darwin* ]]; then
        tar -xvzf $ARTIFACT > /dev/null 2>&1
  else
       unzip -o $ARTIFACT > /dev/null 2>&1
  fi

  cd IBM_Cloud_CLI
  ./ibmcloud -v
}

function install_plugin {

  CLI_PATH=$1
  PLUGIN_OP=`$CLI_PATH plugin list | grep power-iaas`
  if [[ "$PLUGIN_OP" != "" ]]; then
        echo "power-iaas plugin already installed"
  else
        echo "Installing power-iaas plugin"
        $CLI_PATH plugin install power-iaas -f -q >> install_plugin.log 2>&1
  fi
}

function main {
  CLI_PATH=`which ibmcloud >&1`
  if [[ "$CLI_PATH" != "" ]]; then
        CLI_VER=`$CLI_PATH -v | sed 's/.*version //' | sed 's/+.*//'`
        if [[ "$CLI_VER" == "$VERSION" ]]; then
              echo "IBM-Cloud CLI already installed"
        else
              echo "Installing IBM-Cloud CLI"
              install_ibm_cli
	      CLI_PATH='./ibmcloud'
        fi
  else
        echo "Installing IBM-Cloud CLI"
        install_ibm_cli
        CLI_PATH='./ibmcloud'
  fi

  install_plugin $CLI_PATH
}

main

