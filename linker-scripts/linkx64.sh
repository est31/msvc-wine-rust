#!/bin/bash

export TARGET_ARCH=x64

cd "$( dirname "${BASH_SOURCE[0]}" )"

./linker.sh $@
