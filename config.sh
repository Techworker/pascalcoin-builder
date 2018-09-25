#!/usr/bin/env bash

# the remote repository
CFG_MAIN_REPOSITORY="git@github.com:PascalCoin/PascalCoin.git"

# the path to the checkout repository
CFG_MAIN_CHECKOUT_PATH="${PWD}/checkout"

# the path to the builds
CFG_MAIN_BUILD_PATH="${PWD}/builds"

# the path to all configs
CFG_MAIN_CONFIG_PATH="${PWD}/config"

# the list of active configuration files
CFG_BRANCH_CONFIG_FILES=( "${CFG_MAIN_CONFIG_PATH}/master.sh" )

# home directory
CFG_MAIN_HOME=$PWD