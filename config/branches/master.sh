#!/usr/bin/env bash

# the branch all mentioned configs will be applied to
CFG_BRANCH_NAME="master"

# the list of build-configs to load
CFG_BRANCH_BUILD_CONFIG_FILES=( "${CFG_MAIN_CONFIG_PATH}/branches/master/linux_x86_64_TESTNET.sh" "${CFG_MAIN_CONFIG_PATH}/branches/master/win64_x86_64_TESTNET.sh" "${CFG_MAIN_CONFIG_PATH}/branches/master/win32_i386_TESTNET.sh" )
