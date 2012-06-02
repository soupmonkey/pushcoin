#!/bin/bash 
USER_DIR="${PWD}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $SCRIPT_DIR
python ./pushcoin-payment-processor.py

# go back where we came from
cd $USER_DIR
