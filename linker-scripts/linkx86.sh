#!/usr/bin/env bash

export TARGET_ARCH=x86

cd "$( dirname "${BASH_SOURCE[0]}" )"

./linker.sh $@
